`timescale 1ns / 1ps
//============================================================================
// RSA core - timing-fixed version
//
// Thay the toan bo phep nhan/chia to hop 64-bit bang cac khoi tuan tu
// (1 bit / clock). Logic to hop dai nhat con lai chi la chuoi cong/tru
// 66-bit -> de dang dat 40 MHz (25 ns), du cho ca 100 MHz.
//
// Interface cua module `control` GIU NGUYEN 100% so voi ban goc:
// AXI wrapper (RSA_mark02_slave_lite_v1_0_S00_AXI) va firmware KHONG doi.
//
// Cac module cu can XOA khoi IP: mod, mod_exp, inverter, control
// (file nay thay the tat ca).
//============================================================================


//----------------------------------------------------------------------------
// mod_div_seq : bo chia restoring tuan tu, WIDTH bit / WIDTH chu ky
//   quot = num / den ; rem = num % den
//   (thay the cho module `mod` to hop cu)
//----------------------------------------------------------------------------
module mod_div_seq #(
    parameter WIDTH = 64
)(
    input                  clk,
    input                  reset,     // sync, active-high
    input                  start,     // xung 1 chu ky
    input  [WIDTH-1:0]     num,       // so bi chia
    input  [WIDTH-1:0]     den,       // so chia
    output reg             busy,
    output reg             done,      // xung 1 chu ky, quot/rem hop le tu day
    output [WIDTH-1:0]     quot,
    output [WIDTH-1:0]     rem
);
    localparam CW = 7; // du cho WIDTH <= 127

    reg [WIDTH-1:0] A, N;
    reg [WIDTH:0]   P;
    reg [CW-1:0]    cnt;

    // 1 buoc restoring division / clock: chi 1 phep tru (WIDTH+1)-bit
    wire [WIDTH:0] p_shift = {P[WIDTH-1:0], A[WIDTH-1]};
    wire [WIDTH:0] p_diff  = p_shift - {1'b0, N};

    assign quot = A;
    assign rem  = P[WIDTH-1:0];

    always @(posedge clk) begin
        if (reset) begin
            busy <= 1'b0;
            done <= 1'b0;
        end else begin
            done <= 1'b0;
            if (start && !busy) begin
                A    <= num;
                N    <= den;
                P    <= {(WIDTH+1){1'b0}};
                cnt  <= WIDTH[CW-1:0];
                busy <= 1'b1;
            end else if (busy) begin
                if (p_diff[WIDTH]) begin        // p_shift < N : restore
                    P <= p_shift;
                    A <= {A[WIDTH-2:0], 1'b0};
                end else begin                  // p_shift >= N : tru
                    P <= p_diff;
                    A <= {A[WIDTH-2:0], 1'b1};
                end
                cnt <= cnt - 1'b1;
                if (cnt == 7'd1) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                end
            end
        end
    end
endmodule


//----------------------------------------------------------------------------
// mod_mult_seq : (a * b) mod n theo Blakley (interleaved shift-add)
//   Dieu kien: a < n va b < n. WIDTH chu ky.
//   Khong bao gio tao tich 128-bit -> sua luon bug tran/cat 64-bit cua ban cu.
//----------------------------------------------------------------------------
module mod_mult_seq #(
    parameter WIDTH = 64
)(
    input                  clk,
    input                  reset,
    input                  start,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    input  [WIDTH-1:0]     n,
    output reg             busy,
    output reg             done,
    output [WIDTH-1:0]     r        // giu gia tri den lan start ke tiep
);
    localparam CW = 7;

    reg [WIDTH-1:0] A, B, N;
    reg [WIDTH+1:0] R;              // R < n, trung gian < 3n -> can WIDTH+2 bit
    reg [CW-1:0]    cnt;

    // Moi buoc: R = 2R + a*b[msb], roi tru n toi da 2 lan de dua ve < n.
    // Duong to hop dai nhat: 1 cong + 2 tru 66-bit noi tiep (~10 ns tren 7-series)
    wire [WIDTH+1:0] sum  = {R[WIDTH:0], 1'b0}
                          + (B[WIDTH-1] ? {2'b00, A} : {(WIDTH+2){1'b0}});
    wire [WIDTH+1:0] sub1 = sum  - {2'b00, N};
    wire [WIDTH+1:0] red1 = sub1[WIDTH+1] ? sum  : sub1;
    wire [WIDTH+1:0] sub2 = red1 - {2'b00, N};
    wire [WIDTH+1:0] red2 = sub2[WIDTH+1] ? red1 : sub2;

    assign r = R[WIDTH-1:0];

    always @(posedge clk) begin
        if (reset) begin
            busy <= 1'b0;
            done <= 1'b0;
        end else begin
            done <= 1'b0;
            if (start && !busy) begin
                A    <= a;
                B    <= b;
                N    <= n;
                R    <= {(WIDTH+2){1'b0}};
                cnt  <= WIDTH[CW-1:0];
                busy <= 1'b1;
            end else if (busy) begin
                R   <= red2;
                B   <= {B[WIDTH-2:0], 1'b0};
                cnt <= cnt - 1'b1;
                if (cnt == 7'd1) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                end
            end
        end
    end
endmodule


//----------------------------------------------------------------------------
// mult_seq : nhan shift-add tuan tu, lay WIDTH bit thap cua a*b
//   (thay cho `quotient * y` to hop trong inverter). Ket thuc som khi B == 0
//   nen voi quotient nho chi mat vai chu ky.
//----------------------------------------------------------------------------
module mult_seq #(
    parameter WIDTH = 64
)(
    input                  clk,
    input                  reset,
    input                  start,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output reg             busy,
    output reg             done,
    output [WIDTH-1:0]     p
);
    reg [WIDTH-1:0] A, B, ACC;
    assign p = ACC;

    always @(posedge clk) begin
        if (reset) begin
            busy <= 1'b0;
            done <= 1'b0;
        end else begin
            done <= 1'b0;
            if (start && !busy) begin
                A    <= a;
                B    <= b;
                ACC  <= {WIDTH{1'b0}};
                busy <= 1'b1;
            end else if (busy) begin
                if (B == {WIDTH{1'b0}}) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                end else begin
                    if (B[0]) ACC <= ACC + A;
                    A <= {A[WIDTH-2:0], 1'b0};
                    B <= {1'b0, B[WIDTH-1:1]};
                end
            end
        end
    end
endmodule


//----------------------------------------------------------------------------
// inverter : Extended Euclid tim e (va d), phien ban FSM tuan tu.
//   Thuat toan / trinh tu GIONG HET ban goc, chi khac: moi vong lap Euclid
//   dung bo chia + bo nhan tuan tu thay vi to hop.
//   Chu y: nhan `totient` da tinh san tu `control` (khong nhan p*q o day nua).
//----------------------------------------------------------------------------
module inverter #(
    parameter WIDTH = 32
)(
    input  [WIDTH*2-1:0] totient,   // (p-1)*(q-1), tinh san o control
    input                clk,
    input                reset,
    output               finish,
    output [WIDTH*2-1:0] e,
    output [WIDTH*2-1:0] d
);
    localparam DW = WIDTH*2;

    localparam [2:0] S_DIV   = 3'd0,
                     S_DIVW  = 3'd1,
                     S_MULW  = 3'd2,
                     S_CHECK = 3'd3,
                     S_HOLD  = 3'd4;

    reg [2:0]    state;
    reg [DW-1:0] totient_reg, a, b, y, y_prev;
    reg [DW-1:0] quot_r, b_next_r;
    reg [DW-1:0] e_reg;
    reg          div_start, mul_start;

    wire         div_busy, div_done, mul_busy, mul_done;
    wire [DW-1:0] div_q, div_r, mul_p;

    mod_div_seq #(.WIDTH(DW)) u_div (
        .clk(clk), .reset(reset), .start(div_start),
        .num(a), .den(b),
        .busy(div_busy), .done(div_done),
        .quot(div_q), .rem(div_r)
    );

    mult_seq #(.WIDTH(DW)) u_mul (
        .clk(clk), .reset(reset), .start(mul_start),
        .a(quot_r), .b(y),
        .busy(mul_busy), .done(mul_done),
        .p(mul_p)
    );

    assign finish = (state == S_HOLD);
    assign e      = e_reg;
    assign d      = y_prev;

    always @(posedge clk) begin
        if (reset) begin
            totient_reg <= totient;
            a           <= totient;
            b           <= {{(DW-2){1'b0}}, 2'd3};
            e_reg       <= {{(DW-2){1'b0}}, 2'd3};
            y           <= {{(DW-1){1'b0}}, 1'b1};
            y_prev      <= {DW{1'b0}};
            div_start   <= 1'b0;
            mul_start   <= 1'b0;
            state       <= S_DIV;
        end else begin
            div_start <= 1'b0;
            mul_start <= 1'b0;
            case (state)
                // GCD loop: (quot, b_next) = a divmod b
                S_DIV: begin
                    if (b == {DW{1'b0}})
                        state <= S_CHECK;
                    else begin
                        div_start <= 1'b1;
                        state     <= S_DIVW;
                    end
                end
                S_DIVW: if (div_done) begin
                    quot_r    <= div_q;
                    b_next_r  <= div_r;
                    mul_start <= 1'b1;       // y_next = y_prev - quot*y
                    state     <= S_MULW;
                end
                S_MULW: if (mul_done) begin
                    a      <= b;
                    b      <= b_next_r;
                    y      <= y_prev - mul_p;
                    y_prev <= y;
                    state  <= S_DIV;
                end
                // gcd == 1 va d khong am -> xong; nguoc lai thu e + 2
                S_CHECK: begin
                    if (a == {{(DW-1){1'b0}}, 1'b1} && y_prev[DW-1] == 1'b0)
                        state <= S_HOLD;
                    else begin
                        a      <= totient_reg;
                        b      <= e_reg + 2'd2;
                        e_reg  <= e_reg + 2'd2;
                        y      <= {{(DW-1){1'b0}}, 1'b1};
                        y_prev <= {DW{1'b0}};
                        state  <= S_DIV;
                    end
                end
                S_HOLD: ;
                default: state <= S_HOLD;
            endcase
        end
    end
endmodule


//----------------------------------------------------------------------------
// mod_exp : binh phuong-va-nhan (square-and-multiply), FSM tuan tu.
//   Hai phep (result*base) mod n va (base*base) mod n chay SONG SONG
//   tren 2 khoi Blakley -> moi bit exponent ton dung WIDTH*2 chu ky.
//   Co buoc rut gon base = msg mod n truoc khi vao vong lap
//   (ban cu bo qua buoc nay -> sai khi msg >= n).
//----------------------------------------------------------------------------
module mod_exp #(
    parameter WIDTH = 32
)(
    input  [WIDTH*2-1:0] base,      // Message (M)
    input  [WIDTH*2-1:0] modulo,    // n = p*q
    input  [WIDTH*2-1:0] exponent,  // e
    input                clk,
    input                reset,     // giu muc cao de nap input, ha xuong de chay
    output               finish,
    output [WIDTH*2-1:0] result
);
    localparam DW = WIDTH*2;

    localparam [2:0] S_RED  = 3'd0,
                     S_REDW = 3'd1,
                     S_BIT  = 3'd2,
                     S_MULW = 3'd3,
                     S_HOLD = 3'd4;

    reg [2:0]    state;
    reg [DW-1:0] base_in_reg, base_reg, mod_reg, exp_reg, res_reg;
    reg          red_start, mm_start;

    wire          red_busy, red_done;
    wire [DW-1:0] red_r;
    wire          mm1_busy, mm1_done, mm2_busy, mm2_done;
    wire [DW-1:0] mm1_r, mm2_r;

    // base = msg mod n
    mod_div_seq #(.WIDTH(DW)) u_red (
        .clk(clk), .reset(reset), .start(red_start),
        .num(base_in_reg), .den(mod_reg),
        .busy(red_busy), .done(red_done),
        .quot(), .rem(red_r)
    );

    // (result * base) mod n
    mod_mult_seq #(.WIDTH(DW)) u_mm1 (
        .clk(clk), .reset(reset), .start(mm_start),
        .a(res_reg), .b(base_reg), .n(mod_reg),
        .busy(mm1_busy), .done(mm1_done), .r(mm1_r)
    );

    // (base * base) mod n
    mod_mult_seq #(.WIDTH(DW)) u_mm2 (
        .clk(clk), .reset(reset), .start(mm_start),
        .a(base_reg), .b(base_reg), .n(mod_reg),
        .busy(mm2_busy), .done(mm2_done), .r(mm2_r)
    );

    assign finish = (state == S_HOLD);
    assign result = res_reg;

    always @(posedge clk) begin
        if (reset) begin
            base_in_reg <= base;
            mod_reg     <= modulo;
            exp_reg     <= exponent;
            res_reg     <= {{(DW-1){1'b0}}, 1'b1};
            red_start   <= 1'b0;
            mm_start    <= 1'b0;
            state       <= S_RED;
        end else begin
            red_start <= 1'b0;
            mm_start  <= 1'b0;
            case (state)
                S_RED: begin
                    red_start <= 1'b1;
                    state     <= S_REDW;
                end
                S_REDW: if (red_done) begin
                    base_reg <= red_r;
                    state    <= S_BIT;
                end
                S_BIT: begin
                    if (exp_reg == {DW{1'b0}})
                        state <= S_HOLD;
                    else begin
                        mm_start <= 1'b1;   // chay song song 2 khoi Blakley
                        state    <= S_MULW;
                    end
                end
                S_MULW: if (mm1_done) begin // mm2 xong cung chu ky (cung so buoc)
                    if (exp_reg[0])
                        res_reg <= mm1_r;
                    base_reg <= mm2_r;
                    exp_reg  <= {1'b0, exp_reg[DW-1:1]};
                    state    <= S_BIT;
                end
                S_HOLD: ;
                default: state <= S_HOLD;
            endcase
        end
    end
endmodule


//----------------------------------------------------------------------------
// control : top cua loi RSA. PORT LIST GIU NGUYEN so voi ban goc
//   -> AXI wrapper va firmware khong can sua.
// Thay doi ben trong:
//   1. n = p*q va totient = (p-1)*(q-1) duoc PIPELINE 2 tang thanh ghi
//      (32x32 DSP + register) thay vi wire to hop keo dai vao datapath.
//   2. Them 1 nhip tre cho co inverter_done truoc khi tha reset cua mod_exp,
//      dam bao mod_exp nap DUNG exp_reg/mod_reg/msg_reg da cap nhat
//      (ban goc co race: mod_exp co the nap gia tri cu roi chay voi exp = 0).
//----------------------------------------------------------------------------
module control #(
    parameter WIDTH = 32
)(
    input  [WIDTH-1:0]   p, q,
    input                clk,
    input                reset,
    input  [WIDTH-1:0]   msg_in,
    output [WIDTH*2-1:0] msg_out,
    output               mod_exp_finish
);
    wire inverter_finish;
    wire raw_mod_exp_finish;
    wire [WIDTH*2-1:0] e_val;

    // --- Pipeline tinh n va totient (CPU giu reset=1 qua nhieu chu ky AXI
    //     nen 2 tang nay luon on dinh truoc khi reset duoc tha) ---
    reg [WIDTH-1:0]   p_m1, q_m1;
    reg [WIDTH*2-1:0] n_r, totient_r;
    always @(posedge clk) begin
        p_m1      <= p - 1'b1;
        q_m1      <= q - 1'b1;
        n_r       <= p * q;          // 32x32 -> DSP, 1 tang thanh ghi rieng
        totient_r <= p_m1 * q_m1;    // 32x32 -> DSP, 1 tang thanh ghi rieng
    end

    reg inverter_done_latch, inverter_done_d, final_done_latch;
    reg [WIDTH*2-1:0] exp_reg, msg_reg, mod_reg;

    // 1. INVERTER (nhan totient da tinh san)
    inverter #(.WIDTH(WIDTH)) i_inst (
        .totient(totient_r),
        .clk(clk),
        .reset(reset),
        .finish(inverter_finish),
        .e(e_val),
        .d()
    );

    // 2. Chot ket qua inverter + du lieu cho mod_exp
    always @(posedge clk) begin
        if (reset) begin
            exp_reg             <= {(WIDTH*2){1'b0}};
            mod_reg             <= {(WIDTH*2){1'b0}};
            msg_reg             <= {(WIDTH*2){1'b0}};
            inverter_done_latch <= 1'b0;
            inverter_done_d     <= 1'b0;
        end else begin
            if (inverter_finish && !inverter_done_latch) begin
                exp_reg <= e_val;
                mod_reg <= n_r;
                msg_reg <= {{WIDTH{1'b0}}, msg_in};
                inverter_done_latch <= 1'b1;
            end
            // tre 1 nhip: dam bao mod_exp nap gia tri MOI o canh clock cuoi
            // truoc khi reset cua no duoc tha
            inverter_done_d <= inverter_done_latch;
        end
    end

    // 3. mod_exp bi giu reset cho toi khi du lieu da san sang
    wire wait_for_inverter = reset | (~inverter_done_d);

    // 4. MOD_EXP
    mod_exp #(.WIDTH(WIDTH)) m_inst (
        .base(msg_reg),
        .modulo(mod_reg),
        .exponent(exp_reg),
        .clk(clk),
        .reset(wait_for_inverter),
        .finish(raw_mod_exp_finish),
        .result(msg_out)
    );

    // 5. Chot co DONE cuoi cung cho AXI doc
    always @(posedge clk) begin
        if (reset)
            final_done_latch <= 1'b0;
        else if (raw_mod_exp_finish)
            final_done_latch <= 1'b1;
    end
    assign mod_exp_finish = final_done_latch;
endmodule