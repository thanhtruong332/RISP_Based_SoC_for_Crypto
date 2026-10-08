`timescale 1ns / 1ps
//============================================================================
//  RSA Montgomery core (32-bit)  --  day la core THAT duoc AXI wrapper
//  (RSA_mark03_slave_lite_v1_0_S00_AXI.v, xem RSA_mark03_1_0/hdl/) instantiate
//  trong moi SoC dang dung (SE-RISSP_AES_ULTRA, base AXI 0x48000000).
//
//  SUA LAI 2026-08-07: file nay TRUOC DAY chua ban `control`/`inverter`
//  (Euclid tu do e tu p,q) - da audit va PASS testbench nhung do KHONG PHAI
//  core duoc AXI wrapper thuc su goi. Doc ky RSA_mark03_slave_lite_v1_0_
//  S00_AXI.v thi thay no instantiate `rsa #(.WIDTH(32),.E_BITS(32))` voi
//  port (M,E,N,N_INV,R2_MOD_N) - dung ban Montgomery nay, khong lien quan gi
//  toi `control`/`inverter` ca. Da thay file nay bang dung noi dung core that
//  (copy tu F:\advance_topic\RSA_mark03\RSA_mark03_1_0\src\RSA_core.v) va
//  viet testbench moi verify lai tu dau - xem RSA.md.
//
//  Diem quan trong: core nay nhan M, E, N TRUC TIEP tu ben ngoai (khong tu
//  suy e tu p,q nhu ban cu) - dung mo hinh RSA verify chuan (thiet bi chi
//  can biet public key (N,E), khong bao gio can biet p,q) - phu hop lam
//  chu ky so / secure boot verify. N_INV = -N^{-1} mod 2^32, R2_MOD_N =
//  2^64 mod N deu tinh SAN ngoai bang Python (offline, luc build/release),
//  firmware chi ghi vao nhu hang so - dung quy uoc da ghi trong AXI wrapper.
//
//  Da verify: p=61 q=53 e=17 msg=65 -> C=2790 (dung vi du kinh dien
//  Wikipedia RSA). Nhanh hon ~9x ban tuan tu cu (184 cyc vs 1692 cyc).
//============================================================================
module montgomery_reduce #( parameter WIDTH = 32 )(
    input  wire clk, input wire rst, input wire start,
    input  wire [2*WIDTH-1:0] T,
    input  wire [WIDTH-1:0]   N,
    input  wire [WIDTH-1:0]   N_INV,
    output reg  [WIDTH-1:0]   result,
    output reg                done
);
    reg [WIDTH-1:0] m;
    reg [WIDTH+1:0] t_reg;
    reg [1:0]       state;
    localparam IDLE=0, CALC_M=1, CALC_T=2;
    always @(posedge clk) begin
        if (rst) begin state<=IDLE; done<=0; result<=0; end
        else begin
            done<=0;
            case (state)
            IDLE:   if (start) begin state<=CALC_M; m<=(T[WIDTH-1:0]*N_INV); end
            CALC_M: begin state<=CALC_T; t_reg<=({1'b0,T}+(m*N))>>WIDTH; end
            CALC_T: begin state<=IDLE;
                if (t_reg>=N) result<=t_reg-N; else result<=t_reg;
                done<=1;
            end
            endcase
        end
    end
endmodule

module montgomery_mul #( parameter WIDTH = 32 )(
    input  wire clk, input wire rst, input wire start,
    input  wire [WIDTH-1:0] A, input wire [WIDTH-1:0] B,
    input  wire [WIDTH-1:0] N, input wire [WIDTH-1:0] N_INV,
    output wire [WIDTH-1:0] result, output wire done
);
    wire [2*WIDTH-1:0] T = A*B;
    montgomery_reduce #(.WIDTH(WIDTH)) u_red (
        .clk(clk),.rst(rst),.start(start),.T(T),.N(N),.N_INV(N_INV),
        .result(result),.done(done));
endmodule

module rsa #( parameter WIDTH = 32, parameter E_BITS = 32 )(
    input  wire clk, input wire rst, input wire start,
    input  wire [WIDTH-1:0]  M, input wire [E_BITS-1:0] E,
    input  wire [WIDTH-1:0]  N, input wire [WIDTH-1:0] N_INV,
    input  wire [WIDTH-1:0]  R2_MOD_N,
    output reg  [WIDTH-1:0]  C, output reg done
);
    localparam IDLE=0,CONV_M=1,CONV_R=2,LOOP_START=3,SQUARE_WAIT=4,
               MULT_WAIT=5,REDUCE_START=6,REDUCE_WAIT=7;
    reg [2:0] state;
    reg [31:0] bit_idx;
    reg [WIDTH-1:0] M_bar, res_bar, A_in, B_in;
    reg mont_start;
    wire mont_done; wire [WIDTH-1:0] mont_out;
    montgomery_mul #(.WIDTH(WIDTH)) u_mont (
        .clk(clk),.rst(rst),.start(mont_start),.A(A_in),.B(B_in),
        .N(N),.N_INV(N_INV),.result(mont_out),.done(mont_done));
    always @(posedge clk) begin
        if (rst) begin state<=IDLE; done<=0; bit_idx<=0; C<=0; mont_start<=0; end
        else begin
            mont_start<=0; done<=0;
            case (state)
            IDLE: if (start) begin bit_idx<=E_BITS-1; A_in<=M; B_in<=R2_MOD_N; mont_start<=1; state<=CONV_M; end
            CONV_M: if (mont_done) begin M_bar<=mont_out; A_in<=1; B_in<=R2_MOD_N; mont_start<=1; state<=CONV_R; end
            CONV_R: if (mont_done) begin res_bar<=mont_out; state<=LOOP_START; end
            LOOP_START: begin A_in<=res_bar; B_in<=res_bar; mont_start<=1; state<=SQUARE_WAIT; end
            SQUARE_WAIT: if (mont_done) begin
                res_bar<=mont_out;
                if (E[bit_idx]) begin A_in<=mont_out; B_in<=M_bar; mont_start<=1; state<=MULT_WAIT; end
                else if (bit_idx==0) state<=REDUCE_START;
                else begin bit_idx<=bit_idx-1; state<=LOOP_START; end
            end
            MULT_WAIT: if (mont_done) begin
                res_bar<=mont_out;
                if (bit_idx==0) state<=REDUCE_START;
                else begin bit_idx<=bit_idx-1; state<=LOOP_START; end
            end
            REDUCE_START: begin A_in<=res_bar; B_in<=1; mont_start<=1; state<=REDUCE_WAIT; end
            REDUCE_WAIT: if (mont_done) begin C<=mont_out; done<=1; state<=IDLE; end
            endcase
        end
    end
endmodule
