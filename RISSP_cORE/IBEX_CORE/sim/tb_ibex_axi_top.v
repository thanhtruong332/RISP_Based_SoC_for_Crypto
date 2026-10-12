`timescale 1ns / 1ps
module tb_ibex_axi_top;

  reg clk = 0;
  reg rst_n = 0;

  always #5 clk = ~clk; // 100MHz
  wire [31:0] imem_addr;
  reg  [31:0] imem_rdata;
  reg  [31:0] imem_mem [0:63]; 
  integer     i;

  initial begin
    for (i = 0; i < 64; i = i + 1) imem_mem[i] = 32'h0;
    $readmemh("test_prog.hex", imem_mem, 32, 45);
  end

  always @(posedge clk) begin
    imem_rdata <= imem_mem[imem_addr[31:2]];
  end

// AXI4-Lite Internal Signals
    
    // Write Address Channel (AW)
    wire [31:0] m_axi_awaddr;
    wire [ 2:0] m_axi_awprot;
    wire        m_axi_awvalid;
    reg         m_axi_awready;

    // Write Data Channel (W)
    wire [31:0] m_axi_wdata;
    wire [ 3:0] m_axi_wstrb;
    wire        m_axi_wvalid;
    reg         m_axi_wready;

    // Write Response Channel (B)
    reg  [ 1:0] m_axi_bresp;
    reg         m_axi_bvalid;
    wire        m_axi_bready;

    // Read Address Channel (AR)
    wire [31:0] m_axi_araddr;
    wire [ 2:0] m_axi_arprot;
    wire        m_axi_arvalid;
    reg         m_axi_arready;

    // Read Data Channel (R)
    reg  [31:0] m_axi_rdata;
    reg  [ 1:0] m_axi_rresp;
    reg         m_axi_rvalid;
    wire        m_axi_rready;

    // Internal Memory & Control Flags
    reg  [31:0] dmem_mem [0:63];
    reg         aw_hs;
    reg         w_hs;
    reg         ar_hs;
    reg  [31:0] araddr_q;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      m_axi_awready <= 0; m_axi_wready <= 0; m_axi_bvalid <= 0; m_axi_bresp <= 2'b00;
      aw_hs <= 0; w_hs <= 0;
    end else begin
      m_axi_awready <= m_axi_awvalid && !aw_hs;
      m_axi_wready  <= m_axi_wvalid  && !w_hs;

      if (m_axi_awvalid && m_axi_awready) aw_hs <= 1;
      if (m_axi_wvalid && m_axi_wready) begin
        w_hs <= 1;
        if (m_axi_wstrb[0]) dmem_mem[m_axi_awaddr[7:2]][7:0]   <= m_axi_wdata[7:0];
        if (m_axi_wstrb[1]) dmem_mem[m_axi_awaddr[7:2]][15:8]  <= m_axi_wdata[15:8];
        if (m_axi_wstrb[2]) dmem_mem[m_axi_awaddr[7:2]][23:16] <= m_axi_wdata[23:16];
        if (m_axi_wstrb[3]) dmem_mem[m_axi_awaddr[7:2]][31:24] <= m_axi_wdata[31:24];
      end

      if (aw_hs && w_hs && !m_axi_bvalid) begin
        m_axi_bvalid <= 1; m_axi_bresp <= 2'b00;
      end else if (m_axi_bvalid && m_axi_bready) begin
        m_axi_bvalid <= 0; aw_hs <= 0; w_hs <= 0;
      end
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      m_axi_arready <= 0; m_axi_rvalid <= 0; m_axi_rresp <= 2'b00; ar_hs <= 0;
    end else begin
      m_axi_arready <= m_axi_arvalid && !ar_hs;

      if (m_axi_arvalid && m_axi_arready) begin
        ar_hs <= 1;
        araddr_q <= m_axi_araddr;
      end

      if (ar_hs && !m_axi_rvalid) begin
        m_axi_rvalid <= 1;
        m_axi_rdata  <= dmem_mem[araddr_q[7:2]];
        m_axi_rresp  <= 2'b00;
      end else if (m_axi_rvalid && m_axi_rready) begin
        m_axi_rvalid <= 0; ar_hs <= 0;
      end
    end
  end
  
  ibex_axi_top #(
      .BootAddr(32'h0)
  ) dut (
     // Global Signals
      .clk           (clk),
      .rst_n         (rst_n),

      // Instruction Memory Interface (IMEM)
      .imem_addr     (imem_addr),
      .imem_rdata    (imem_rdata),

      // AXI4-Lite Master Interface
      
      // Write Address Channel (AW)
      .m_axi_awaddr  (m_axi_awaddr),
      .m_axi_awprot  (m_axi_awprot),
      .m_axi_awvalid (m_axi_awvalid),
      .m_axi_awready (m_axi_awready),

      // Write Data Channel (W)
      .m_axi_wdata   (m_axi_wdata),
      .m_axi_wstrb   (m_axi_wstrb),
      .m_axi_wvalid  (m_axi_wvalid),
      .m_axi_wready  (m_axi_wready),

      // Write Response Channel (B)
      .m_axi_bresp   (m_axi_bresp),
      .m_axi_bvalid  (m_axi_bvalid),
      .m_axi_bready  (m_axi_bready),

      // Read Address Channel (AR)
      .m_axi_araddr  (m_axi_araddr),
      .m_axi_arprot  (m_axi_arprot),
      .m_axi_arvalid (m_axi_arvalid),
      .m_axi_arready (m_axi_arready),

      // Read Data Channel (R)
      .m_axi_rdata   (m_axi_rdata),
      .m_axi_rresp   (m_axi_rresp),
      .m_axi_rvalid  (m_axi_rvalid),
      .m_axi_rready  (m_axi_rready)
  );

  integer errors;
  initial begin
    errors = 0;
    rst_n = 0;
    repeat (10) @(posedge clk);
    rst_n = 1;

    repeat (2000) @(posedge clk);

    if (dmem_mem[0] !== 32'd15) begin
      errors = errors + 1;
      $display("[FAIL] mem[0x100] = %0d (Expected: 15)", dmem_mem[0]);
    end else begin
      $display("[PASS] mem[0x100] = 15 (x3 = x1+x2, SW successful)");
    end

    if (dmem_mem[1] !== 32'd115) begin
      errors = errors + 1;
      $display("[FAIL] mem[0x104] = %0d (Expected: 115)", dmem_mem[1]);
    end else begin
      $display("[PASS] mem[0x104] = 115 (LW readback + ADDI successful)");
    end

    if (dmem_mem[2] !== 32'd5) begin
      errors = errors + 1;
      $display("[FAIL] mem[0x108] = %0d (Expected: 5)", dmem_mem[2]);
    end else begin
      $display("[PASS] mem[0x108] = 5 (Branch loop verified: 5 iterations)");
    end

    if (errors == 0) $display("=== ALL PASS: ibex_axi_top boot + fetch + LSU AXI + branch OK");
    else              $display("=== %0d FAIL(S) ===", errors);

    $finish;
  end

  initial begin
    #100000;
    $display("[TIMEOUT] simlation ending");
    $finish;
  end

endmodule
