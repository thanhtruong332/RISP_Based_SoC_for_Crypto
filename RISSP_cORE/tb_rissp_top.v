`timescale 1ns / 1ps
// Self-checking testbench for rissp_top.
//
// Strategy: instead of predicting exact cycle counts (fragile, since LOAD/STORE
// stall for several cycles through the AXI bridge), this TB snoops every
// register-file commit (dut.rf_wen_final / dut.rdest_addr / dut.rdest_data) in
// real time and appends it to a log. At the end, the log is compared, IN ORDER,
// against a hand-built list of expected (addr,data) commits. Branches/JAL/JALR
// correctness is verified indirectly: "poison" instructions placed right after
// a jump/taken-branch must NOT appear in the log (they must never be fetched),
// while for one not-taken branch both the "poison" and the following
// instruction must appear (proving the branch correctly fell through).
module tb_rissp_top;

    reg clk = 0;
    reg rst_n = 0;
    always #5 clk = ~clk;

    // ---------------- IMEM (synchronous ROM, 1-cycle latency like BRAM) ----------------
    reg [31:0] imem_mem [0:255];
    wire [31:0] imem_addr;
    reg  [31:0] imem_rdata_r;
    always @(posedge clk) imem_rdata_r <= imem_mem[imem_addr[9:2]];

    // ---------------- AXI4 master signals from DUT ----------------
    wire [31:0] m_axi_awaddr;  wire [2:0] m_axi_awprot;  wire m_axi_awvalid; reg m_axi_awready;
    wire [31:0] m_axi_wdata;   wire [3:0] m_axi_wstrb;   wire m_axi_wvalid;  reg m_axi_wready;
    reg  [1:0]  m_axi_bresp;   reg m_axi_bvalid;         wire m_axi_bready;
    wire [31:0] m_axi_araddr;  wire [2:0] m_axi_arprot;  wire m_axi_arvalid; reg m_axi_arready;
    reg  [31:0] m_axi_rdata;   reg  [1:0] m_axi_rresp;   reg m_axi_rvalid;   wire m_axi_rready;

    // ---------------- Simple behavioral AXI4 slave (dmem) ----------------
    reg [31:0] dmem_mem [0:63];
    integer dk;
    initial for (dk = 0; dk < 64; dk = dk + 1) dmem_mem[dk] = 32'h0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            m_axi_awready <= 1'b1; m_axi_wready <= 1'b1; m_axi_bvalid <= 1'b0; m_axi_bresp <= 2'b00;
            m_axi_arready <= 1'b1; m_axi_rvalid <= 1'b0; m_axi_rresp <= 2'b00; m_axi_rdata <= 32'h0;
        end else begin
            // Write: awvalid & wvalid always asserted together by axi_rissp_master, readies fixed high.
            if (m_axi_awvalid && m_axi_wvalid) begin
                if (m_axi_wstrb[0]) dmem_mem[m_axi_awaddr[7:2]][7:0]   <= m_axi_wdata[7:0];
                if (m_axi_wstrb[1]) dmem_mem[m_axi_awaddr[7:2]][15:8]  <= m_axi_wdata[15:8];
                if (m_axi_wstrb[2]) dmem_mem[m_axi_awaddr[7:2]][23:16] <= m_axi_wdata[23:16];
                if (m_axi_wstrb[3]) dmem_mem[m_axi_awaddr[7:2]][31:24] <= m_axi_wdata[31:24];
                m_axi_bvalid <= 1'b1;
            end else if (m_axi_bvalid && m_axi_bready) begin
                m_axi_bvalid <= 1'b0;
            end

            // Read
            if (m_axi_arvalid && !m_axi_rvalid) begin
                m_axi_rdata  <= dmem_mem[m_axi_araddr[7:2]];
                m_axi_rvalid <= 1'b1;
            end else if (m_axi_rvalid && m_axi_rready) begin
                m_axi_rvalid <= 1'b0;
            end
        end
    end

    // ---------------- DUT ----------------
    rissp_top dut (
        .clk(clk), .rst_n(rst_n),
        .imem_addr(imem_addr), .imem_rdata(imem_rdata_r),
        .m_axi_awaddr(m_axi_awaddr), .m_axi_awprot(m_axi_awprot), .m_axi_awvalid(m_axi_awvalid), .m_axi_awready(m_axi_awready),
        .m_axi_wdata(m_axi_wdata), .m_axi_wstrb(m_axi_wstrb), .m_axi_wvalid(m_axi_wvalid), .m_axi_wready(m_axi_wready),
        .m_axi_bresp(m_axi_bresp), .m_axi_bvalid(m_axi_bvalid), .m_axi_bready(m_axi_bready),
        .m_axi_araddr(m_axi_araddr), .m_axi_arprot(m_axi_arprot), .m_axi_arvalid(m_axi_arvalid), .m_axi_arready(m_axi_arready),
        .m_axi_rdata(m_axi_rdata), .m_axi_rresp(m_axi_rresp), .m_axi_rvalid(m_axi_rvalid), .m_axi_rready(m_axi_rready)
    );

    // ---------------- Encoders ----------------
    function [31:0] enc_r; input [6:0] f7; input [4:0] rs2; input [4:0] rs1; input [2:0] f3; input [4:0] rd;
        begin enc_r = {f7, rs2, rs1, f3, rd, 7'b0110011}; end
    endfunction

    function [31:0] enc_i; input [11:0] imm; input [4:0] rs1; input [2:0] f3; input [4:0] rd; input [6:0] op;
        begin enc_i = {imm, rs1, f3, rd, op}; end
    endfunction

    function [31:0] enc_ishift; input arith; input [4:0] shamt; input [4:0] rs1; input [2:0] f3; input [4:0] rd;
        begin enc_ishift = {arith ? 7'b0100000 : 7'b0000000, shamt, rs1, f3, rd, 7'b0010011}; end
    endfunction

    function [31:0] enc_s; input [11:0] imm; input [4:0] rs2; input [4:0] rs1; input [2:0] f3;
        begin enc_s = {imm[11:5], rs2, rs1, f3, imm[4:0], 7'b0100011}; end
    endfunction

    function [31:0] enc_b; input [12:0] imm; input [4:0] rs2; input [4:0] rs1; input [2:0] f3;
        begin enc_b = {imm[12], imm[10:5], rs2, rs1, f3, imm[4:1], imm[11], 7'b1100011}; end
    endfunction

    function [31:0] enc_u; input [19:0] imm20; input [4:0] rd; input [6:0] op;
        begin enc_u = {imm20, rd, op}; end
    endfunction

    function [31:0] enc_j; input [20:0] imm; input [4:0] rd;
        begin enc_j = {imm[20], imm[10:1], imm[11], imm[19:12], rd, 7'b1101111}; end
    endfunction

    // ---------------- Expected-commit log ----------------
    reg [4:0]  exp_addr [0:127];
    reg [31:0] exp_data [0:127];
    integer    exp_n;
    task push_exp; input [4:0] a; input [31:0] d;
        begin exp_addr[exp_n] = a; exp_data[exp_n] = d; exp_n = exp_n + 1; end
    endtask

    integer ip;      // instruction byte pointer (assembler)
    integer here;    // scratch: address of "current" instruction being emitted
    integer errors;

    initial begin
        ip = 0; exp_n = 0;

        // --- basic operands ---
        imem_mem[ip>>2] = enc_i(12'd5, 5'd0, 3'b000, 5'd1, 7'b0010011); ip=ip+4; push_exp(5'd1, 32'd5);   // ADDI x1,x0,5
        imem_mem[ip>>2] = enc_i(12'd10,5'd0, 3'b000, 5'd2, 7'b0010011); ip=ip+4; push_exp(5'd2, 32'd10);  // ADDI x2,x0,10

        // --- R-type ---
        imem_mem[ip>>2] = enc_r(7'b0000000,5'd2,5'd1,3'b000,5'd3); ip=ip+4; push_exp(5'd3, 32'd15);       // ADD x3,x1,x2
        imem_mem[ip>>2] = enc_r(7'b0100000,5'd1,5'd2,3'b000,5'd3); ip=ip+4; push_exp(5'd3, 32'd5);        // SUB x3,x2,x1
        imem_mem[ip>>2] = enc_r(7'b0000000,5'd1,5'd2,3'b001,5'd3); ip=ip+4; push_exp(5'd3, 32'd320);      // SLL x3,x2,x1 (10<<5)

        // --- I-type ALU incl. shifts ---
        imem_mem[ip>>2] = enc_ishift(1'b0, 5'd3, 5'd2, 3'b001, 5'd3); ip=ip+4; push_exp(5'd3, 32'd80);    // SLLI x3,x2,3
        imem_mem[ip>>2] = enc_ishift(1'b0, 5'd1, 5'd2, 3'b101, 5'd3); ip=ip+4; push_exp(5'd3, 32'd5);     // SRLI x3,x2,1
        imem_mem[ip>>2] = enc_i(-12'sd8, 5'd0, 3'b000, 5'd5, 7'b0010011); ip=ip+4; push_exp(5'd5, 32'hFFFFFFF8); // ADDI x5,x0,-8
        imem_mem[ip>>2] = enc_ishift(1'b1, 5'd1, 5'd5, 3'b101, 5'd3); ip=ip+4; push_exp(5'd3, 32'hFFFFFFFC); // SRAI x3,x5,1 (-4)
        imem_mem[ip>>2] = enc_i(12'd1, 5'd0, 3'b000, 5'd4, 7'b0010011); ip=ip+4; push_exp(5'd4, 32'd1);   // ADDI x4,x0,1
        imem_mem[ip>>2] = enc_r(7'b0100000,5'd4,5'd5,3'b101,5'd3); ip=ip+4; push_exp(5'd3, 32'hFFFFFFFC); // SRA x3,x5,x4 (-4)

        // --- compares ---
        imem_mem[ip>>2] = enc_r(7'b0000000,5'd0,5'd5,3'b010,5'd3); ip=ip+4; push_exp(5'd3, 32'd1);        // SLT x3,x5,x0 (-8<0)
        imem_mem[ip>>2] = enc_r(7'b0000000,5'd0,5'd5,3'b011,5'd3); ip=ip+4; push_exp(5'd3, 32'd0);        // SLTU x3,x5,x0
        imem_mem[ip>>2] = enc_i(12'd1, 5'd0, 3'b010, 5'd3, 7'b0010011); ip=ip+4; push_exp(5'd3, 32'd1);   // SLTI x3,x0,1
        imem_mem[ip>>2] = enc_i(12'd1, 5'd0, 3'b011, 5'd3, 7'b0010011); ip=ip+4; push_exp(5'd3, 32'd1);   // SLTIU x3,x0,1

        // --- bitwise (R-type) ---
        imem_mem[ip>>2] = enc_i(12'd5, 5'd0, 3'b000, 5'd6, 7'b0010011); ip=ip+4; push_exp(5'd6, 32'd5);   // ADDI x6,x0,5
        imem_mem[ip>>2] = enc_i(12'd6, 5'd0, 3'b000, 5'd7, 7'b0010011); ip=ip+4; push_exp(5'd7, 32'd6);   // ADDI x7,x0,6
        imem_mem[ip>>2] = enc_r(7'b0000000,5'd7,5'd6,3'b111,5'd3); ip=ip+4; push_exp(5'd3, 32'd4);        // AND x3,x6,x7
        imem_mem[ip>>2] = enc_r(7'b0000000,5'd7,5'd6,3'b110,5'd3); ip=ip+4; push_exp(5'd3, 32'd7);        // OR  x3,x6,x7
        imem_mem[ip>>2] = enc_r(7'b0000000,5'd7,5'd6,3'b100,5'd3); ip=ip+4; push_exp(5'd3, 32'd3);        // XOR x3,x6,x7

        // --- bitwise immediate ---
        imem_mem[ip>>2] = enc_i(12'd3, 5'd2, 3'b111, 5'd3, 7'b0010011); ip=ip+4; push_exp(5'd3, 32'd2);   // ANDI x3,x2,3 (10&3)
        imem_mem[ip>>2] = enc_i(12'd7, 5'd0, 3'b110, 5'd3, 7'b0010011); ip=ip+4; push_exp(5'd3, 32'd7);   // ORI x3,x0,7
        imem_mem[ip>>2] = enc_i(12'd15,5'd2, 3'b100, 5'd3, 7'b0010011); ip=ip+4; push_exp(5'd3, 32'd5);   // XORI x3,x2,15 (10^15)

        // --- U-type ---
        imem_mem[ip>>2] = enc_u(20'h12345, 5'd3, 7'b0110111); ip=ip+4; push_exp(5'd3, 32'h12345000);      // LUI x3,0x12345
        here = ip; imem_mem[ip>>2] = enc_u(20'd1, 5'd3, 7'b0010111); ip=ip+4; push_exp(5'd3, here + 32'h1000); // AUIPC x3,1

        // --- STORE / LOAD (also exercises the SB/SH/LB/LBU bug fixes) ---
        imem_mem[ip>>2] = enc_s(12'd0, 5'd1, 5'd0, 3'b010); ip=ip+4;                                       // SW x1,0(x0) -> mem[0]=5
        imem_mem[ip>>2] = enc_s(12'd4, 5'd2, 5'd0, 3'b010); ip=ip+4;                                       // SW x2,4(x0) -> mem[1]=10
        imem_mem[ip>>2] = enc_i(12'd0, 5'd0, 3'b010, 5'd3, 7'b0000011); ip=ip+4; push_exp(5'd3, 32'd5);    // LW x3,0(x0)
        imem_mem[ip>>2] = enc_i(12'd0, 5'd0, 3'b000, 5'd3, 7'b0000011); ip=ip+4; push_exp(5'd3, 32'd5);    // LB x3,0(x0)
        imem_mem[ip>>2] = enc_s(12'd8, 5'd2, 5'd0, 3'b000); ip=ip+4;                                       // SB x2,8(x0) -> mem[2] byte0=10
        imem_mem[ip>>2] = enc_i(12'd8, 5'd0, 3'b100, 5'd3, 7'b0000011); ip=ip+4; push_exp(5'd3, 32'd10);   // LBU x3,8(x0)
        imem_mem[ip>>2] = enc_s(12'd12,5'd2, 5'd0, 3'b001); ip=ip+4;                                       // SH x2,12(x0) -> mem[3] lo16=10
        imem_mem[ip>>2] = enc_i(12'd12,5'd0, 3'b010, 5'd3, 7'b0000011); ip=ip+4; push_exp(5'd3, 32'd10);   // LW x3,12(x0)

        // --- JAL ---
        here = ip; imem_mem[ip>>2] = enc_j(21'sd8, 5'd3); ip=ip+4; push_exp(5'd3, here+4);                 // JAL x3,+8
        imem_mem[ip>>2] = enc_i(12'd999,5'd0,3'b000,5'd8, 7'b0010011); ip=ip+4;                             // poison (must be skipped)
        imem_mem[ip>>2] = enc_i(12'd222,5'd0,3'b000,5'd3, 7'b0010011); ip=ip+4; push_exp(5'd3, 32'd222);   // landing

        // --- JALR (via AUIPC to get a safe, in-range base) ---
        here = ip; imem_mem[ip>>2] = enc_u(20'd0, 5'd5, 7'b0010111); ip=ip+4; push_exp(5'd5, here);         // AUIPC x5,0 (x5=here)
        imem_mem[ip>>2] = enc_i(12'd12, 5'd5, 3'b000, 5'd3, 7'b1100111); ip=ip+4; push_exp(5'd3, (ip)+0);  // JALR x3,x5,12 ; link = pc_of_jalr+4 = ip (already advanced by 4 above)
        imem_mem[ip>>2] = enc_i(12'd888,5'd0,3'b000,5'd9, 7'b0010011); ip=ip+4;                             // poison (must be skipped)
        imem_mem[ip>>2] = enc_i(12'd333,5'd0,3'b000,5'd3, 7'b0010011); ip=ip+4; push_exp(5'd3, 32'd333);   // landing

        // --- Branches: taken cases must skip the poison entirely ---
        // NOTE: marker values must stay within ADDI's signed 12-bit immediate range
        // (-2048..2047) or they'd be silently truncated by the encoder.
        // NOTE: x5 was repurposed above (AUIPC x5,0 for the JALR base) and no longer
        // holds -8, so reload a negative value into a fresh register (x9) for BLT.
        imem_mem[ip>>2] = enc_b(13'sd8, 5'd1, 5'd1, 3'b000); ip=ip+4;                                       // BEQ x1,x1,+8 (true)
        imem_mem[ip>>2] = enc_i(12'd10,5'd0,3'b000,5'd3, 7'b0010011); ip=ip+4;                              // poison
        imem_mem[ip>>2] = enc_i(12'd11,5'd0,3'b000,5'd3, 7'b0010011); ip=ip+4; push_exp(5'd3, 32'd11);      // landing

        imem_mem[ip>>2] = enc_b(13'sd8, 5'd2, 5'd1, 3'b001); ip=ip+4;                                       // BNE x1,x2,+8 (5!=10 true)
        imem_mem[ip>>2] = enc_i(12'd20,5'd0,3'b000,5'd3, 7'b0010011); ip=ip+4;                              // poison
        imem_mem[ip>>2] = enc_i(12'd21,5'd0,3'b000,5'd3, 7'b0010011); ip=ip+4; push_exp(5'd3, 32'd21);

        imem_mem[ip>>2] = enc_i(-12'sd8, 5'd0, 3'b000, 5'd9, 7'b0010011); ip=ip+4; push_exp(5'd9, 32'hFFFFFFF8); // ADDI x9,x0,-8
        imem_mem[ip>>2] = enc_b(13'sd8, 5'd0, 5'd9, 3'b100); ip=ip+4;                                       // BLT x9,x0,+8 (-8<0 true)
        imem_mem[ip>>2] = enc_i(12'd30,5'd0,3'b000,5'd3, 7'b0010011); ip=ip+4;                              // poison
        imem_mem[ip>>2] = enc_i(12'd31,5'd0,3'b000,5'd3, 7'b0010011); ip=ip+4; push_exp(5'd3, 32'd31);

        imem_mem[ip>>2] = enc_b(13'sd8, 5'd0, 5'd1, 3'b101); ip=ip+4;                                       // BGE x1,x0,+8 (5>=0 true)
        imem_mem[ip>>2] = enc_i(12'd40,5'd0,3'b000,5'd3, 7'b0010011); ip=ip+4;                              // poison
        imem_mem[ip>>2] = enc_i(12'd41,5'd0,3'b000,5'd3, 7'b0010011); ip=ip+4; push_exp(5'd3, 32'd41);

        imem_mem[ip>>2] = enc_b(13'sd8, 5'd1, 5'd0, 3'b110); ip=ip+4;                                       // BLTU x0,x1,+8 (0<u5 true)
        imem_mem[ip>>2] = enc_i(12'd50,5'd0,3'b000,5'd3, 7'b0010011); ip=ip+4;                              // poison
        imem_mem[ip>>2] = enc_i(12'd51,5'd0,3'b000,5'd3, 7'b0010011); ip=ip+4; push_exp(5'd3, 32'd51);

        imem_mem[ip>>2] = enc_b(13'sd8, 5'd0, 5'd1, 3'b111); ip=ip+4;                                       // BGEU x1,x0,+8 (5>=u0 true)
        imem_mem[ip>>2] = enc_i(12'd60,5'd0,3'b000,5'd3, 7'b0010011); ip=ip+4;                              // poison
        imem_mem[ip>>2] = enc_i(12'd61,5'd0,3'b000,5'd3, 7'b0010011); ip=ip+4; push_exp(5'd3, 32'd61);

        // Not-taken branch: both instructions after it must execute normally.
        imem_mem[ip>>2] = enc_b(13'sd8, 5'd2, 5'd1, 3'b000); ip=ip+4;                                       // BEQ x1,x2,+8 (5!=10 false)
        imem_mem[ip>>2] = enc_i(12'd70,5'd0,3'b000,5'd3, 7'b0010011); ip=ip+4; push_exp(5'd3, 32'd70);      // falls through -> executes
        imem_mem[ip>>2] = enc_i(12'd71,5'd0,3'b000,5'd3, 7'b0010011); ip=ip+4; push_exp(5'd3, 32'd71);      // then this too

        // Halt: jump to self forever.
        imem_mem[ip>>2] = enc_j(21'sd0, 5'd0); ip=ip+4;                                                    // JAL x0,0 (halt)

        $display("[TB] Program size = %0d bytes, %0d expected commits", ip, exp_n);
    end

    // ---------------- Commit logger / online checker ----------------
    integer got_n;
    initial begin
        rst_n = 0; got_n = 0; errors = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;
    end

    always @(posedge clk) begin
        // x0 writes are architecturally void (register_file itself discards them),
        // so the checker must ignore them too -- otherwise the boot-time NOP and
        // the "JAL x0,0" halt loop both look like spurious extra commits.
        if (rst_n && dut.rf_wen_final && dut.rdest_addr != 5'd0) begin
            if (got_n >= exp_n) begin
                $display("[TB] FAIL: unexpected extra commit #%0d x%0d=%0d (0x%08h)",
                          got_n, dut.rdest_addr, dut.rdest_data, dut.rdest_data);
                errors = errors + 1;
            end else if (dut.rdest_addr !== exp_addr[got_n] || dut.rdest_data !== exp_data[got_n]) begin
                $display("[TB] FAIL commit #%0d: got x%0d=0x%08h, expected x%0d=0x%08h",
                          got_n, dut.rdest_addr, dut.rdest_data, exp_addr[got_n], exp_data[got_n]);
                errors = errors + 1;
            end else begin
                $display("[TB] OK  commit #%0d: x%0d=0x%08h", got_n, dut.rdest_addr, dut.rdest_data);
            end
            got_n = got_n + 1;
        end
    end

    // ---------------- Run & summarize ----------------
    initial begin
        #6000;
        if (got_n < exp_n) begin
            $display("[TB] FAIL: only %0d/%0d expected commits observed", got_n, exp_n);
            errors = errors + 1;
        end
        if (errors == 0) $display("[TB] ==== ALL CHECKS PASSED (%0d commits) ====", got_n);
        else              $display("[TB] ==== %0d CHECK(S) FAILED ====", errors);
        $finish;
    end

endmodule
