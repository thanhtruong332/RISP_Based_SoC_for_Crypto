//Author       : Thanh Truong
`timescale 1ns / 1ps
module rissp_top (
   // Global Signals
    input  wire        clk,
    input  wire        rst_n,

    // Instruction Memory Interface (IMEM)
    output wire [31:0] imem_addr,
    input  wire [31:0] imem_rdata,

    // AXI4-Lite Master Interface
    
    // Write Address Channel (AW)
    output wire [31:0] m_axi_awaddr,
    output wire [ 2:0] m_axi_awprot,
    output wire        m_axi_awvalid,
    input  wire        m_axi_awready,

    // Write Data Channel (W)
    output wire [31:0] m_axi_wdata,
    output wire [ 3:0] m_axi_wstrb,
    output wire        m_axi_wvalid,
    input  wire        m_axi_wready,

    // Write Response Channel (B)
    input  wire [ 1:0] m_axi_bresp,
    input  wire        m_axi_bvalid,
    output wire        m_axi_bready,

    // Read Address Channel (AR)
    output wire [31:0] m_axi_araddr,
    output wire [ 2:0] m_axi_arprot,
    output wire        m_axi_arvalid,
    input  wire        m_axi_arready,

    // Read Data Channel (R)
    input  wire [31:0] m_axi_rdata,
    input  wire [ 1:0] m_axi_rresp,
    input  wire        m_axi_rvalid,
    output wire        m_axi_rready
);
    wire [31:0] int_dmem_addr, int_dmem_wdata, int_dmem_rdata;
    wire [31:0] pc, next_pc, insn, rs1_data, rs2_data, rdest_data;
    wire [3:0]  int_dmem_wstrb;
    wire [4:0]  rs1_addr, rs2_addr, rdest_addr;
    wire        int_dmem_read, stall_from_bridge, rf_wen_raw;
    wire [31:0] safe_next_pc = (!rst_n) ? 32'h0 : (stall_from_bridge ? pc : next_pc);
    wire rf_wen_final = rf_wen_raw && !stall_from_bridge;

    axi_rissp_master u_bridge (
     // Global Signals
    .clk           (clk),
    .rst_n         (rst_n),

    // CPU Data Memory Interface
    .dmem_addr     (int_dmem_addr),
    .dmem_wdata    (int_dmem_wdata),
    .dmem_wstrb    (int_dmem_wstrb),
    .dmem_read     (int_dmem_read),
    .dmem_rdata    (int_dmem_rdata),
    .stall_cpu     (stall_from_bridge),

    // AXI4-Lite Master Interface
    
    // Write Address Channel (AW)
    .m_axi_awaddr  (m_axi_awaddr),
    .m_axi_awvalid (m_axi_awvalid),
    .m_axi_awready (m_axi_awready),

    // Write Data Channel (W)
    .m_axi_wdata   (m_axi_wdata),
    .m_axi_wstrb   (m_axi_wstrb),
    .m_axi_wvalid  (m_axi_wvalid),
    .m_axi_wready  (m_axi_wready),

    // Write Response Channel (B)
    .m_axi_bvalid  (m_axi_bvalid),
    .m_axi_bready  (m_axi_bready),

    // Read Address Channel (AR)
    .m_axi_araddr  (m_axi_araddr),
    .m_axi_arvalid (m_axi_arvalid),
    .m_axi_arready (m_axi_arready),

    // Read Data Channel (R)
    .m_axi_rdata   (m_axi_rdata),
    .m_axi_rvalid  (m_axi_rvalid),
    .m_axi_rready  (m_axi_rready)
    );

    modular_ex mex (
    // Program Counter & Instruction
    .pc         (pc),
    .next_pc    (next_pc),
    .insn       (insn),

    // Register File Interface
    .rs1_addr   (rs1_addr),
    .rs1_data   (rs1_data),
    .rs2_addr   (rs2_addr),
    .rs2_data   (rs2_data),
    .rdest_addr (rdest_addr),
    .rdest_data (rdest_data),
    .rf_wen     (rf_wen_raw),

    // Data Memory Interface (DMEM)
    .dmem_addr  (int_dmem_addr),
    .dmem_wdata (int_dmem_wdata),
    .dmem_wstrb (int_dmem_wstrb),
    .dmem_read  (int_dmem_read),
    .dmem_rdata (int_dmem_rdata)
    );

    fetch_stage fetch (
    // Global & Control Signals
    .clk        (clk),
    .rst_n      (rst_n),
    .stall      (stall_from_bridge),

    // Program Counter
    .pc         (pc),
    .next_pc    (safe_next_pc),

    // Instruction Memory (IMEM)
    .imem_addr  (imem_addr),
    .imem_rdata (imem_rdata),
    .insn       (insn)
    );

    register_file rf (
     // Global Signals
    .clk        (clk),
    .rst_n      (rst_n),

    // Write Port (Destination)
    .wen        (rf_wen_final),
    .rdest_addr (rdest_addr),
    .rdest_data (rdest_data),

    // Read Ports (Sources)
    .rs1_addr   (rs1_addr),
    .rs1_data   (rs1_data),
    .rs2_addr   (rs2_addr),
    .rs2_data   (rs2_data)
    );
endmodule
