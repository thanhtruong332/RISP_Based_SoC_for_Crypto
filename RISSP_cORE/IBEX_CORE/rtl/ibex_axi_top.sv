`timescale 1ns / 1ps
module ibex_axi_top #(
    parameter int                 RV32M     = 2, // 2 = RV32MFast
    parameter int                 RV32B     = 0, // 0 = RV32BNone
    parameter int                 RV32ZC    = 3, // 3 = RV32ZcaZcbZcmp
    parameter bit                RV32E     = 1'b0,
    parameter bit                ICache    = 1'b0,
    parameter bit                PMPEnable = 1'b0,
    parameter int unsigned       MHPMCounterNum = 0,
    parameter [31:0]             BootAddr  = 32'h0,
    parameter [31:0]             HartId    = 32'h0
) (
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

  wire        instr_req;
  wire        instr_gnt;
  reg         instr_rvalid_q;
  wire [31:0] instr_addr;

  assign imem_addr   = instr_addr;
  assign instr_gnt    = instr_req;      

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) instr_rvalid_q <= 1'b0;
    else        instr_rvalid_q <= instr_req; 
  end

  wire        data_req, data_we;
  wire [3:0]  data_be;
  wire [31:0] data_addr, data_wdata;
  wire [31:0] dmem_rdata_w;
  wire        stall_cpu_w;
  reg         stall_prev_q;

  wire        dmem_read_w  = data_req & ~data_we;
  wire [3:0]  dmem_wstrb_w = data_we ? data_be : 4'h0;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) stall_prev_q <= 1'b0;
    else        stall_prev_q <= stall_cpu_w;
  end

  wire data_gnt_w    =  stall_cpu_w & ~stall_prev_q; 
  wire data_rvalid_w =  stall_prev_q & ~stall_cpu_w; 

axi_rissp_master u_dmem_bridge (
        // Global Signals
        .clk           (clk),
        .rst_n         (rst_n),

        // CPU Data Memory Interface
        .dmem_addr     (data_addr),
        .dmem_wdata    (data_wdata),
        .dmem_wstrb    (dmem_wstrb_w),
        .dmem_read     (dmem_read_w),
        .dmem_rdata    (dmem_rdata_w),
        .stall_cpu     (stall_cpu_w),

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

  // Ibex core instantiation
  ibex_top #(
      .PMPEnable      (PMPEnable),
      .MHPMCounterNum (MHPMCounterNum),
      .RV32E          (RV32E),
      .RV32M          (ibex_pkg::rv32m_e'(RV32M)),
      .RV32B          (ibex_pkg::rv32b_e'(RV32B)),
      .RV32ZC         (ibex_pkg::rv32zc_e'(RV32ZC)),
      .RegFile        (ibex_pkg::RegFileFF),
      .ICache         (ICache),
      .SecureIbex     (1'b0)
  ) u_ibex_top (
      .clk_i (clk),
      .rst_ni(rst_n),

      .test_en_i(1'b0),
      .ram_cfg_icache_tag_i ('{default: prim_ram_1p_pkg::RAM_1P_CFG_REQ_DEFAULT}),
      .ram_cfg_icache_tag_o (),
      .ram_cfg_icache_data_i('{default: prim_ram_1p_pkg::RAM_1P_CFG_REQ_DEFAULT}),
      .ram_cfg_icache_data_o(),

      .hart_id_i  (HartId),
      .boot_addr_i(BootAddr),

      // Instruction memory interface
      .instr_req_o        (instr_req),
      .instr_gnt_i        (instr_gnt),
      .instr_rvalid_i     (instr_rvalid_q),
      .instr_addr_o       (instr_addr),
      .instr_rdata_i      (imem_rdata),
      .instr_rdata_intg_i (7'h0),
      .instr_err_i        (1'b0),

      // Data memory interface
      .data_req_o        (data_req),
      .data_gnt_i        (data_gnt_w),
      .data_rvalid_i     (data_rvalid_w),
      .data_we_o         (data_we),
      .data_be_o         (data_be),
      .data_addr_o       (data_addr),
      .data_wdata_o      (data_wdata),
      .data_wdata_intg_o (),
      .data_rdata_i      (dmem_rdata_w),
      .data_rdata_intg_i (7'h0),
      .data_err_i        (1'b0),

      // Interrupts 
      .irq_software_i(1'b0),
      .irq_timer_i   (1'b0),
      .irq_external_i(1'b0),
      .irq_fast_i    (15'h0),
      .irq_nm_i      (1'b0),

      // Scrambling - turn off (ICacheScramble define = 0)
      .scramble_key_valid_i(1'b0),
      .scramble_key_i      ('0),
      .scramble_nonce_i    ('0),
      .scramble_req_o      (),

      // Debug - Not utilized
      .debug_req_i        (1'b0),
      .crash_dump_o       (),
      .double_fault_seen_o(),

      // CPU control
      .fetch_enable_i       (ibex_pkg::IbexMuBiOn),
      .mcounteren_writable_i(ibex_pkg::IbexMuBiOn),
      .alert_minor_o         (),
      .alert_major_internal_o(),
      .alert_major_bus_o     (),
      .core_sleep_o          (),

      .scan_rst_ni(1'b1),

      // Lockstep/shadow - Not utilized (SecureIbex=0)
      .lockstep_cmp_en_o      (),
      .data_req_shadow_o      (),
      .data_we_shadow_o       (),
      .data_be_shadow_o       (),
      .data_addr_shadow_o     (),
      .data_wdata_shadow_o    (),
      .data_wdata_intg_shadow_o(),
      .instr_req_shadow_o     (),
      .instr_addr_shadow_o    ()
  );

endmodule
