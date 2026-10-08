`timescale 1ns / 1ps
//============================================================================
//  rsa_modexp_ws  --  RSA modular exponentiation, WORD-SERIAL Montgomery (CIOS)
//----------------------------------------------------------------------------
//  Thay cho ban 32-bit cu (nhan to hop toan dai "A*B") - ban do KHONG mo rong
//  duoc: chi phi bo nhan tang theo BINH PHUONG do rong (2048-bit -> ~45000 DSP).
//  Ban nay dung DUNG MOT bo MAC 32x32 lap lai:
//     - So bo nhan KHONG doi theo do rong toan hang (chi bo nho tang tuyen tinh)
//     - Do rong bat ky: doi tham so S (so tu 32-bit).  S=64 -> RSA-2048.
//
//  Thuat toan CIOS (Koc et al. 1996), moi phep nhan Montgomery:
//     for i in 0..S-1:
//        C=0; for j in 0..S-1: (C,St)=t[j]+a[j]*b[i]+C ; t[j]=St
//        (C,St)=t[S]+C ; t[S]=St ; t[S+1]=C
//        m = t[0]*n0inv mod 2^WORD
//        (C,St)=t[0]+m*n[0]                       // tu thap = 0 theo cau truc
//        for j in 1..S-1: (C,St)=t[j]+m*n[j]+C ; t[j-1]=St
//        (C,St)=t[S]+C ; t[S-1]=St ; t[S]=t[S+1]+C
//     roi tru co dieu kien neu t >= N.
//
//  CHI PHI ~ 2*S^2 + 6*S chu ky / phep nhan Montgomery
//     S=4  (128-bit)  ->    ~56 ck        S=32 (1024-bit) -> ~2250 ck
//     S=64 (2048-bit) -> ~8600 ck
//  So phep nhan Montgomery cho 1 luy thua:
//     CONST_TIME=1 : 2*e_bits + 3      (e=65537 -> 37)
//     CONST_TIME=0 : e_bits + popcount(e) + 3
//
//  CONST_TIME=1 (mac dinh): LUON thuc hien phep nhan, chi GHI KET QUA co dieu
//  kien -> thoi gian chay KHONG phu thuoc so mu.  (Ban cu co nhanh
//  "if (E[bit_idx])" nen thoi gian lo so bit 1 cua so mu => kenh ke thoi gian.)
//  Dat CONST_TIME=0 neu chi verify bang khoa CONG KHAI va muon nhanh hon.
//
//  Giao dien nap/doc theo TUNG TU 32-bit -> hop AXI4-Lite, khong can cong rong.
//  n0inv = -N^-1 mod 2^WORD (1 tu) ; R2 = 2^(2*S*WORD) mod N (S tu)
//  -> tinh SAN bang Python roi nap vao, giong ban cu.
//============================================================================
module rsa_modexp_ws #(
    parameter WORD       = 32,
    parameter S          = 64,                       // 64 tu -> 2048 bit
    parameter CONST_TIME = 1,
    parameter AW         = (S <= 2) ? 1 : $clog2(S)  // KHONG doi khi instantiate
)(
    input  wire            clk,
    input  wire            rst,        // dong bo, muc cao

    // nap toan hang theo tung tu:  wr_sel 0=M, 1=N, 2=R2
    input  wire            wr_en,
    input  wire [1:0]      wr_sel,
    input  wire [AW-1:0]   wr_addr,
    input  wire [WORD-1:0] wr_data,

    input  wire [WORD-1:0] n0inv,      // -N^-1 mod 2^WORD
    input  wire [WORD-1:0] e,          // so mu (vd 65537)
    input  wire [5:0]      e_bits,     // so bit cua e dung den (vd 17)

    input  wire            start,
    output reg             done,

    input  wire [AW-1:0]   rd_addr,
    output wire [WORD-1:0] rd_data
);
    //------------------------------------------------------------------
    // Bo nho toan hang
    //------------------------------------------------------------------
    reg [WORD-1:0] m_in [0:S-1];
    reg [WORD-1:0] n    [0:S-1];
    reg [WORD-1:0] r2   [0:S-1];
    reg [WORD-1:0] mbar [0:S-1];
    reg [WORD-1:0] res  [0:S-1];
    reg [WORD-1:0] tmpv [0:S-1];
    reg [WORD-1:0] t    [0:S+1];
    reg [WORD-1:0] sb   [0:S-1];

    assign rd_data = res[rd_addr];

    integer k;

    //------------------------------------------------------------------
    // Chon nguon toan hang: 0=res 1=mbar 2=tmpv 3=hang so 1 4=m_in 5=r2
    //------------------------------------------------------------------
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
    //   (2^W-1)^2 + 2*(2^W-1) = 2^2W - 1  -> vua khit, khong tran.
    //------------------------------------------------------------------
    reg  [WORD-1:0]   mac_y, mac_z, mac_x, carry;
    wire [2*WORD-1:0] mac = mac_y * mac_z + {{WORD{1'b0}}, mac_x}
                                          + {{WORD{1'b0}}, carry};

    reg [WORD-1:0] mword, b_i;
    reg            borrow, t_ge_n;

    //------------------------------------------------------------------
    localparam ST_IDLE  = 5'd0,  ST_CLR   = 5'd1,  ST_L1  = 5'd2,
               ST_L1E   = 5'd3,  ST_M     = 5'd4,  ST_L2F = 5'd5,
               ST_L2    = 5'd6,  ST_L2E   = 5'd7,  ST_NEXT= 5'd8,
               ST_SUB   = 5'd9,  ST_CMP   = 5'd10, ST_WR  = 5'd11,
               ST_CPY   = 5'd12, ST_EXP_A = 5'd13, ST_EXP_B = 5'd14;

    reg [4:0] st;
    reg [5:0] ebit_idx;
    reg       ebit;
    reg [2:0] phase;    // 0=convM 1=convR 2=square 3=mult 4=final

    always @(posedge clk) begin
        if (rst) begin
            st <= ST_IDLE; done <= 1'b0; carry <= 0; ii <= 0; jj <= 0;
            phase <= 0; ebit_idx <= 0; borrow <= 0; ebit <= 0;
        end else begin
            done <= 1'b0;

            if (wr_en && st == ST_IDLE) begin
                case (wr_sel)
                    2'd0: m_in[wr_addr] <= wr_data;
                    2'd1: n   [wr_addr] <= wr_data;
                    2'd2: r2  [wr_addr] <= wr_data;
                    default: ;
                endcase
            end

            case (st)
            //---------------------------------------------------------
            ST_IDLE: if (start) begin
                ebit_idx <= e_bits - 6'd1;
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
                mac_y  <= t[0];                // t[0] da cap nhat o vong L1
                mac_z  <= n0inv;
                mac_x  <= {WORD{1'b0}};
                st     <= ST_M;
            end

            ST_M: begin                        // m = t[0]*n0inv mod 2^W
                mword <= mac[WORD-1:0];
                mac_y <= mac[WORD-1:0];
                mac_z <= n[0];
                mac_x <= t[0];
                carry <= {WORD{1'b0}};
                st    <= ST_L2F;
            end

            ST_L2F: begin                      // j=0: chi giu carry
                carry <= mac[2*WORD-1:WORD];
                jj    <= 1;
                mac_y <= mword;
                mac_z <= (S > 1) ? n[1] : {WORD{1'b0}};
                mac_x <= (S > 1) ? t[1] : {WORD{1'b0}};
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
                    mac_z <= n[jj+1];
                    mac_x <= t[jj+1];
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

            ST_SUB: begin                      // sb = t - N (mang tu thap len)
                {borrow, sb[jj]} <= {1'b0, t[jj]} - {1'b0, n[jj]}
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
                    3'd0: mbar[jj] <= tmpv[jj];
                    3'd1: res [jj] <= tmpv[jj];
                    3'd2: res [jj] <= tmpv[jj];
                    3'd3: res [jj] <= ebit ? tmpv[jj] : res[jj];
                    default: res[jj] <= tmpv[jj];
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
                    ebit  <= e[ebit_idx];
                    sel_a <= 3'd0; sel_b <= 3'd0;            // MonMul(res,res)
                    st    <= ST_CLR;
                end
                3'd2: begin                                  // xong binh phuong
                    if (CONST_TIME != 0 || ebit) begin
                        phase <= 3'd3;
                        sel_a <= 3'd0; sel_b <= 3'd1;        // MonMul(res,mbar)
                        st    <= ST_CLR;
                    end else st <= ST_EXP_B;
                end
                3'd3: st <= ST_EXP_B;
                default: begin done <= 1'b1; st <= ST_IDLE; end
                endcase
            end

            ST_EXP_B: begin
                if (ebit_idx == 0) begin
                    phase <= 3'd4;
                    sel_a <= 3'd0; sel_b <= 3'd3;            // MonMul(res, 1)
                    st    <= ST_CLR;
                end else begin
                    ebit_idx <= ebit_idx - 6'd1;
                    ebit     <= e[ebit_idx - 6'd1];
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
