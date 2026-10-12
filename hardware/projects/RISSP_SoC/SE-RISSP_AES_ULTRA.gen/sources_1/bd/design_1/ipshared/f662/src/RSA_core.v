`timescale 1ns / 1ps
//============================================================================
//  RSA Montgomery core  --  core THAT duoc AXI wrapper
//  (RSA_mark03_slave_lite_v1_0_S00_AXI.v, xem RSA_mark03_1_0/hdl/) instantiate
//  trong SoC dang dung (SE-RISSP_AES_ULTRA, base AXI 0x48000000).
//
//  VIET LAI 2026-08-13: doi tu nhan TO HOP TOAN DAI sang MONTGOMERY WORD-SERIAL
//  (thuat toan CIOS, Koc et al. 1996). GIU NGUYEN 100% port list cua module
//  `rsa` nen wrapper AXI cu van noi duoc, khong sua mot chu nao khi WIDTH=32.
//
//  VI SAO PHAI DOI:
//    Ban cu dung `wire [2*WIDTH-1:0] T = A*B;` - bo nhan to hop TOAN DAI.
//    Chi phi tang theo BINH PHUONG do rong:
//        WIDTH=32   -> ~11 DSP     (dang chay)
//        WIDTH=256  -> ~700 DSP    (vuot xc7z020)
//        WIDTH=2048 -> ~45000 DSP  (khong the)
//    => KHONG the len RSA-2048 bang cach doi tham so. Ban nay dung DUNG MOT
//    bo MAC WORD x WORD lap lai, nen so bo nhan KHONG doi theo do rong;
//    chi bo nho tang tuyen tinh. Da synth OOC xc7z020 voi WIDTH=2048:
//        3571 LUT / 4314 FF / 0 BRAM / 4 DSP / WNS +11.65ns @40MHz (fmax ~75MHz)
//    => RSA-2048 dung IT DSP HON ban 32-bit cu (4 vs ~11).
//
//  SUA THEM 2 LOI CUA BAN CU:
//    1. KENH KE THOI GIAN: ban cu co nhanh `if (E[bit_idx])` nen thoi gian
//       chay lo so bit 1 cua so mu. Voi khoa CONG KHAI (verify) thi vo hai,
//       nhung cung mach do dung de KY/GIAI MA se lam lo khoa bi mat.
//       Ban nay CONST_TIME=1 LUON thuc hien phep nhan, chi GHI KET QUA co
//       dieu kien -> thoi gian BAT BIEN theo so mu. Da do chung minh:
//          e=65537   (2 bit 1) : CONST_TIME=1 -> 2349 ck | =0 -> 1404 ck
//          e=0x1FFFF (17 bit 1): CONST_TIME=1 -> 2349 ck | =0 -> 2349 ck
//    2. LANG PHI 15 VONG LAP: ban cu luon quet du E_BITS=32 bit du e=65537
//       chi can 17 bit -> 15 vong dau la binh phuong so 1, vo ich (~40% thoi
//       gian lo). Ban nay co tham so E_SCAN de chi quet dung so bit can.
//
//  Thuat toan CIOS, moi phep nhan Montgomery:
//     for i in 0..S-1:
//        C=0; for j in 0..S-1: (C,St)=t[j]+a[j]*b[i]+C ; t[j]=St
//        (C,St)=t[S]+C ; t[S]=St ; t[S+1]=C
//        m = t[0]*N_INV mod 2^WORD
//        (C,St)=t[0]+m*n[0]                    // tu thap = 0 theo cau truc
//        for j in 1..S-1: (C,St)=t[j]+m*n[j]+C ; t[j-1]=St
//        (C,St)=t[S]+C ; t[S-1]=St ; t[S]=t[S+1]+C
//     roi tru co dieu kien neu t >= N.
//
//  CHI PHI ~ 2*S^2 + 6*S + 8 chu ky / phep nhan Montgomery  (S = WIDTH/WORD)
//  So phep nhan cho 1 luy thua:
//     CONST_TIME=1 : 2*E_SCAN + 3      (E_SCAN=17 -> 37)
//     CONST_TIME=0 : E_SCAN + popcount(E) + 3
//
//  DA VERIFY bang mo phong that (Vivado xsim), doi chieu pow(M,E,N) cua Python:
//    | Cau hinh                        | Ket qua   | Chu ky  | Ghi chu        |
//    | WIDTH=32  E_SCAN=32 (drop-in)   | 25836f4b  |    837  | ban cu: 186 ck |
//    | WIDTH=32  E_SCAN=17             | 25836f4b  |    462  |                |
//    | WIDTH=128 E_SCAN=17             | PASS      |   2349  |                |
//    | WIDTH=256 E_SCAN=17             | PASS      |   6937  |                |
//    | WIDTH=2048 E_SCAN=17 CT=1       | PASS      | 319809  | 8.00 ms @40MHz |
//    | WIDTH=2048 E_SCAN=17 CT=0       | PASS      | 190164  | 4.75 ms @40MHz |
//  Vector WIDTH=32 la DUNG vector dang chay tren SoC that
//  (M=0c20ed7d E=65537 N=ffe000ff) -> tai tao chinh xac 25836f4b.
//
//  !! DANH DOI PHAI BIET: o WIDTH=32 ban nay CHAM HON ban cu (837 vs 186 ck)
//     vi khi S=1 thi chi phi may trang thai lan at phan tinh toan. Word-serial
//     chi co loi khi WIDTH lon - do la muc dich cua no. Neu van muon giu SoC o
//     32-bit thi DUNG ban cu; ban nay danh cho khi len 1024/2048-bit.
//
//  QUY UOC THAM SO (giu nguyen nhu ban cu):
//     N_INV    = -N^-1 mod 2^WORD   (chi WORD bit thap duoc dung)
//     R2_MOD_N = 2^(2*WIDTH) mod N
//     ca hai tinh SAN offline bang Python luc build/release, firmware chi ghi
//     vao nhu hang so.
//
//  LUU Y KHI DOI WIDTH:
//     - WIDTH phai chia het cho WORD (32).
//     - WIDTH=32 (S=1): tuong thich hoan toan voi wrapper cu (xem bang do o tren).
//     - WIDTH>32: wrapper AXI phai gom WIDTH/32 lan ghi thanh 1 thanh ghi
//       rong roi dua vao port M/N/R2_MOD_N.
//============================================================================
module rsa #(
    parameter WIDTH      = 32,          // do rong toan hang (bit), chia het WORD
    parameter E_BITS     = 32,          // do rong cong E (giu 32 cho drop-in)
    parameter CONST_TIME = 1,           // 1 = thoi gian bat bien theo so mu
    parameter WORD       = 32,          // do rong duong du lieu MAC
    parameter E_SCAN     = E_BITS,      // so bit cua E thuc su quet (65537 -> 17)
    parameter S          = WIDTH / WORD // so tu - KHONG truyen khi instantiate
)(
    input  wire              clk,
    input  wire              rst,
    input  wire              start,
    input  wire [WIDTH-1:0]  M,
    input  wire [E_BITS-1:0] E,
    input  wire [WIDTH-1:0]  N,
    input  wire [WIDTH-1:0]  N_INV,     // chi N_INV[WORD-1:0] duoc dung
    input  wire [WIDTH-1:0]  R2_MOD_N,
    output reg  [WIDTH-1:0]  C,
    output reg               done
);
    //------------------------------------------------------------------
    // Bo nho toan hang (cat tu cong rong luc start)
    //------------------------------------------------------------------
    reg [WORD-1:0] m_in [0:S-1];
    reg [WORD-1:0] nw   [0:S-1];
    reg [WORD-1:0] r2   [0:S-1];
    reg [WORD-1:0] mbar [0:S-1];
    reg [WORD-1:0] res  [0:S-1];
    reg [WORD-1:0] tmpv [0:S-1];
    reg [WORD-1:0] t    [0:S+1];
    reg [WORD-1:0] sb   [0:S-1];

    integer k;

    //------------------------------------------------------------------
    // Chon nguon toan hang: 0=res 1=mbar 2=tmpv 3=hang so 1 4=m_in 5=r2
    //------------------------------------------------------------------
    localparam AW = (S <= 2) ? 1 : $clog2(S);
    reg [2:0]  sel_a, sel_b;
    reg [AW:0] jj, ii;

    function [WORD-1:0] rd_src;
        input [2:0]  s_;
        input [AW:0] idx;
        begin
            case (s_)
                3'd0: rd_src = res [idx[AW-1:0]];
                3'd1: rd_src = mbar[idx[AW-1:0]];
                3'd2: rd_src = tmpv[idx[AW-1:0]];
                3'd3: rd_src = (idx == 0) ? {{(WORD-1){1'b0}}, 1'b1} : {WORD{1'b0}};
                3'd4: rd_src = m_in[idx[AW-1:0]];
                3'd5: rd_src = r2  [idx[AW-1:0]];
                default: rd_src = {WORD{1'b0}};
            endcase
        end
    endfunction

    //------------------------------------------------------------------
    // MAC dung chung: {carry,sum} = x + y*z + carry
    //   (2^W-1)^2 + 2*(2^W-1) = 2^2W - 1 -> vua khit 2W bit, khong tran.
    //------------------------------------------------------------------
    reg  [WORD-1:0]   mac_y, mac_z, mac_x, carry;
    wire [2*WORD-1:0] mac = mac_y * mac_z + {{WORD{1'b0}}, mac_x}
                                          + {{WORD{1'b0}}, carry};

    reg [WORD-1:0] mword, b_i, n0inv_r;
    reg            borrow, t_ge_n;

    //------------------------------------------------------------------
    localparam ST_IDLE  = 4'd0,  ST_CLR   = 4'd1,  ST_L1    = 4'd2,
               ST_L1E   = 4'd3,  ST_M     = 4'd4,  ST_L2F   = 4'd5,
               ST_L2    = 4'd6,  ST_L2E   = 4'd7,  ST_NEXT  = 4'd8,
               ST_SUB   = 4'd9,  ST_CMP   = 4'd10, ST_WR    = 4'd11,
               ST_CPY   = 4'd12, ST_EXP_A = 4'd13, ST_EXP_B = 4'd14;

    reg [3:0] st;
    reg [5:0] ebit_idx;
    reg       ebit;
    reg [2:0] phase;    // 0=convM 1=convR 2=square 3=mult 4=final

    always @(posedge clk) begin
        if (rst) begin
            st <= ST_IDLE; done <= 1'b0; C <= {WIDTH{1'b0}};
            carry <= 0; ii <= 0; jj <= 0; phase <= 0;
            ebit_idx <= 0; borrow <= 0; ebit <= 0;
        end else begin
            done <= 1'b0;

            case (st)
            //---------------------------------------------------------
            ST_IDLE: if (start) begin
                for (k = 0; k < S; k = k + 1) begin
                    m_in[k] <= M       [k*WORD +: WORD];
                    nw  [k] <= N       [k*WORD +: WORD];
                    r2  [k] <= R2_MOD_N[k*WORD +: WORD];
                end
                n0inv_r  <= N_INV[WORD-1:0];
                ebit_idx <= E_SCAN[5:0] - 6'd1;
                phase    <= 3'd0;
                sel_a    <= 3'd4;  sel_b <= 3'd5;      // MonMul(M, R2)
                st       <= ST_CLR;
            end

            //------------------- CIOS -------------------------------
            ST_CLR: begin
                for (k = 0; k <= S+1; k = k + 1) t[k] <= {WORD{1'b0}};
                ii <= 0; jj <= 0; carry <= 0;
                b_i   <= rd_src(sel_b, 0);
                mac_y <= rd_src(sel_a, 0);
                mac_z <= rd_src(sel_b, 0);
                mac_x <= {WORD{1'b0}};
                st    <= ST_L1;
            end

            ST_L1: begin                       // t[j] = t[j] + a[j]*b_i + C
                t[jj] <= mac[WORD-1:0];
                carry <= mac[2*WORD-1:WORD];
                if (jj == S-1) begin
                    jj    <= 0;
                    mac_y <= {WORD{1'b0}};
                    mac_z <= {WORD{1'b0}};
                    mac_x <= t[S];
                    st    <= ST_L1E;
                end else begin
                    jj    <= jj + 1;
                    mac_y <= rd_src(sel_a, jj + 1);
                    mac_z <= b_i;
                    mac_x <= t[jj + 1];
                end
            end

            ST_L1E: begin
                t[S]   <= mac[WORD-1:0];
                t[S+1] <= mac[2*WORD-1:WORD];
                carry  <= {WORD{1'b0}};
                mac_y  <= t[0];                // t[0] da cap nhat trong ST_L1
                mac_z  <= n0inv_r;
                mac_x  <= {WORD{1'b0}};
                st     <= ST_M;
            end

            ST_M: begin                        // m = t[0]*N_INV mod 2^WORD
                mword <= mac[WORD-1:0];
                mac_y <= mac[WORD-1:0];
                mac_z <= nw[0];
                mac_x <= t[0];
                carry <= {WORD{1'b0}};
                st    <= ST_L2F;
            end

            ST_L2F: begin                      // j=0: chi giu carry
                carry <= mac[2*WORD-1:WORD];
                jj    <= 1;
                mac_y <= mword;
                mac_z <= (S > 1) ? nw[1] : {WORD{1'b0}};
                mac_x <= (S > 1) ? t [1] : t[S];
                st    <= (S == 1) ? ST_L2E : ST_L2;
            end

            ST_L2: begin                       // t[j-1] = t[j] + m*n[j] + C
                t[jj-1] <= mac[WORD-1:0];
                carry   <= mac[2*WORD-1:WORD];
                if (jj == S-1) begin
                    mac_y <= {WORD{1'b0}};
                    mac_z <= {WORD{1'b0}};
                    mac_x <= t[S];
                    st    <= ST_L2E;
                end else begin
                    jj    <= jj + 1;
                    mac_y <= mword;
                    mac_z <= nw[jj+1];
                    mac_x <= t [jj+1];
                end
            end

            ST_L2E: begin
                t[S-1] <= mac[WORD-1:0];
                t[S]   <= t[S+1] + mac[2*WORD-1:WORD];
                carry  <= {WORD{1'b0}};
                st     <= ST_NEXT;
            end

            ST_NEXT: begin
                if (ii == S-1) begin
                    jj <= 0; borrow <= 1'b0; st <= ST_SUB;
                end else begin
                    ii    <= ii + 1;
                    jj    <= 0;
                    carry <= {WORD{1'b0}};
                    b_i   <= rd_src(sel_b, ii + 1);
                    mac_y <= rd_src(sel_a, 0);
                    mac_z <= rd_src(sel_b, ii + 1);
                    mac_x <= t[0];
                    st    <= ST_L1;
                end
            end

            ST_SUB: begin                      // sb = t - N (tu thap len)
                {borrow, sb[jj]} <= {1'b0, t[jj]} - {1'b0, nw[jj]}
                                                 - {{WORD{1'b0}}, borrow};
                if (jj == S-1) begin jj <= 0; st <= ST_CMP; end
                else jj <= jj + 1;
            end

            ST_CMP: begin                      // t >= N ?
                t_ge_n <= (t[S] != {WORD{1'b0}}) || !borrow;
                jj <= 0;
                st <= ST_WR;
            end

            ST_WR: begin
                tmpv[jj] <= t_ge_n ? sb[jj] : t[jj];
                if (jj == S-1) begin jj <= 0; st <= ST_CPY; end
                else jj <= jj + 1;
            end

            //--------------- copy tmpv -> dich ----------------------
            ST_CPY: begin
                case (phase)
                    3'd0: mbar[jj] <= tmpv[jj];                  // M_bar
                    3'd1: res [jj] <= tmpv[jj];                  // res = R mod N
                    3'd2: res [jj] <= tmpv[jj];                  // binh phuong
                    3'd3: res [jj] <= ebit ? tmpv[jj] : res[jj]; // nhan (co dk)
                    default: res[jj] <= tmpv[jj];                // ra khoi Montgomery
                endcase
                if (jj == S-1) begin jj <= 0; st <= ST_EXP_A; end
                else jj <= jj + 1;
            end

            //--------------- dieu khien luy thua --------------------
            ST_EXP_A: begin
                case (phase)
                3'd0: begin                                  // xong conv M
                    phase <= 3'd1;
                    sel_a <= 3'd3; sel_b <= 3'd5;            // MonMul(1, R2)
                    st    <= ST_CLR;
                end
                3'd1: begin                                  // xong conv R
                    phase <= 3'd2;
                    ebit  <= E[ebit_idx];
                    sel_a <= 3'd0; sel_b <= 3'd0;            // MonMul(res,res)
                    st    <= ST_CLR;
                end
                3'd2: begin                                  // xong binh phuong
                    if (CONST_TIME != 0 || ebit) begin
                        phase <= 3'd3;
                        sel_a <= 3'd0; sel_b <= 3'd1;        // MonMul(res,M_bar)
                        st    <= ST_CLR;
                    end else st <= ST_EXP_B;
                end
                3'd3: st <= ST_EXP_B;
                default: begin                               // xong tat ca
                    for (k = 0; k < S; k = k + 1)
                        C[k*WORD +: WORD] <= res[k];
                    done <= 1'b1;
                    st   <= ST_IDLE;
                end
                endcase
            end

            ST_EXP_B: begin
                if (ebit_idx == 0) begin
                    phase <= 3'd4;
                    sel_a <= 3'd0; sel_b <= 3'd3;            // MonMul(res, 1)
                    st    <= ST_CLR;
                end else begin
                    ebit_idx <= ebit_idx - 6'd1;
                    ebit     <= E[ebit_idx - 6'd1];
                    phase    <= 3'd2;
                    sel_a <= 3'd0; sel_b <= 3'd0;
                    st    <= ST_CLR;
                end
            end

            default: st <= ST_IDLE;
            endcase
        end
    end
endmodule
