`timescale 1ns / 1ps
// ================================================================
//  ibex_axi_top - drop-in Ibex replacement for rissp_top
//
//  Muc dich: cho Ibex "vao dung 1 khuon" voi rissp_top.v de so sanh
//  cong bang trong CUNG 1 SoC (cung kieu imem BRAM 1-cycle, cung
//  dung axi_rissp_master.v KHONG SUA GI - giu AXI bridge y het giua
//  2 core, chi core CPU la bien so duy nhat).
//
//  Port list (clk/rst_n, imem_addr/imem_rdata, AXI4 m_axi_*) copy
//  dung ten/be rong tu rissp_top.v de co the thay the truc tiep
//  trong Vivado Block Design (cung custom-IP interface).
//
//  2 shim ben trong:
//   1) imem: instr_req_o/instr_gnt_i/instr_rvalid_i cua Ibex la giao
//      thuc OBI (req/gnt/rvalid). Voi BRAM 1-cong, 1-chu-ky, luon san
//      sang nhan dia chi moi -> gnt = req (to hop), rvalid = req tre
//      1 chu ky. Dung y mau tham chieu cua chinh Ibex
//      (examples/simple_system/rtl/ibex_simple_system.sv: "assign
//      instr_gnt = instr_req;").
//   2) dmem: axi_rissp_master.v KHONG co cong gnt/rvalid rieng (chi co
//      dmem_addr/wdata/wstrb/read vao va dmem_rdata/stall_cpu ra). Suy
//      ra gnt/rvalid tu CANH cua stall_cpu (xem chu thich trong chinh
//      axi_rissp_master.v): stall_cpu bat 0->1 dung luc FSM roi khoi
//      IDLE va latch dia chi (= luc gnt phai bat), stall_cpu tat 1->0
//      dung luc DONE (= luc du lieu doc/ghi da xong, dmem_rdata da
//      chac chan dung). Khong dung vao bat ky signal noi bo nao cua
//      axi_rissp_master - chi suy ra tu 2 cong da cong bo cua no.
//
//  BAT BUOC khi add vao Vivado project (ca Synthesis lan Simulation
//  fileset, Project Settings -> General -> Verilog Options -> Verilog
//  Define): "FPGA_XILINX=1" va "SYNTHESIS=1".
//   - FPGA_XILINX=1: dung target Vivado chinh chu cua Ibex (khop
//     "tool_vivado ? (FPGA_XILINX=true)" trong ibex_top.core).
//   - SYNTHESIS=1: bat buoc cho MO PHONG (khong chi "nen") - thieu no,
//     xelab CRASH that (loi thuc te da gap va sua trong sandbox nay):
//     ibex_if_stage.sv co 1 khoi `ifndef SYNTHESIS` (DPI-export shim
//     cho co-sim testbench rieng cua Ibex, tu nhan la "slightly ugly
//     hack" trong chinh comment goc) sinh ra 1 ten ham C khong hop le
//     (co dau cham) khi nam trong generate-block - xelap's C-codegen
//     khong xu ly duoc. Voi Run Synthesis that, Vivado TU DONG define
//     SYNTHESIS san (hanh vi chuan cua synth_design), nen thuong khong
//     bao gio dung loi nay - chi mo phong (xsim, ca IP nay rieng le lan
//     mo phong Block Design sau nay) moi can set tay. Da verify: RTL
//     phia sau `ifndef SYNTHESIS` nay va cac cho khac dung SYNTHESIS
//     trong toan bo IBEX_CORE 100% la code kiem tra/DV (FCOV, assertion
//     tu-check LFSR, "synopsys translate_off") - dinh nghia SYNTHESIS
//     KHONG lam mat logic chuc nang nao.
//
//  Da verify BANG MO PHONG HANH VI THAT (khong chi static elaboration):
//  xem sim/tb_ibex_axi_top.v - boot dung tai boot_addr_i+0x80 (xem
//  tham so BootAddr ben duoi), fetch/decode/execute, SW/LW qua AXI dmem
//  shim, branch loop - ALL PASS (xsim thuc su chay, 2026-08-13).
// ================================================================
module ibex_axi_top #(
    // RV32M/RV32B/RV32ZC dung kieu `int` (khong dung thang
    // ibex_pkg::rv32m_e/rv32b_e/rv32zc_e nhu ibex_top) VI Vivado IP
    // Packager (IP-XACT Customization Parameters) KHONG parse duoc tham
    // so kieu package-scoped enum o MODULE TOP DUOC PACKAGE - da gap
    // loi that "XPath expression failed: Undefined parameter ibex_pkg"
    // khi chay ipx::package_project (xvlog/xelab/xsim thi khong sao, chi
    // rieng IP Packager moi bi). Gia tri = dung so nguyen ben trong cua
    // tung enum (xem ibex_pkg.sv), duoc ep kieu (cast) lai truoc khi dua
    // vao ibex_top ben duoi.
    //   RV32M : 0=None 1=Slow      2=Fast(default)     3=SingleCycle
    //   RV32B : 0=None(default) 1=Balanced 2=OTEarlGrey 3=Full
    //   RV32ZC: 0=Zca 1=ZcaZcb 2=ZcaZcmp 3=ZcaZcbZcmp(default)
    // Gia tri mac dinh la SO NGUYEN LITERAL (khong phai bieu thuc cast) -
    // IP-XACT parser cua Vivado cung khong hieu cu phap cast SV
    // "int'(ibex_pkg::X)" trong gia tri mac dinh tham so, da gap loi that
    // "Default value does not match format long" khi thu.
    parameter int                 RV32M     = 2, // 2 = RV32MFast
    parameter int                 RV32B     = 0, // 0 = RV32BNone
    parameter int                 RV32ZC    = 3, // 3 = RV32ZcaZcbZcmp
    parameter bit                RV32E     = 1'b0,
    // ⚠️ ICache=1 HIEN KHONG CHAY DUOC - LOI RTL THAT CUA CHINH IBEX o
    // commit c6edaa4060 (khong phai loi wrapper nay): ibex_top.sv dong
    // 756-757 gan `icache_tag_alert`/`icache_data_alert` (CA MANG) o BEN
    // TRONG vong lap generate theo tung "way", trong khi IC_NUM_WAYS=2
    // (ibex_pkg.sv dong 386, khong the doi tu ben ngoai) -> 2 driver
    // dong thoi cho cung 1 bien. Da tu verify bang xelab that: "ERROR:
    // [VRFC 10-3823] variable 'icache_tag_alert' might have multiple
    // concurrent drivers". PMPEnable=1 rieng le (ICache=0) DA verify
    // sach (elaborate OK). Chi dung ICache=0 (mac dinh) cho toi khi bug
    // nay duoc sua o ban Ibex moi hon.
    parameter bit                ICache    = 1'b0,
    parameter bit                PMPEnable = 1'b0,
    parameter int unsigned       MHPMCounterNum = 0,
    // LUU Y: lenh dau tien Ibex fetch la BootAddr+0x80, KHONG phai
    // BootAddr (reset vector co dinh cua ibex_if_stage.sv, khac RISSP
    // boot thang PC=0) - chuong trinh trong imem phai dat tai offset
    // byte 0x80 tro di. BootAddr[7:0] phai = 0 (co assertion RTL check).
    parameter [31:0]             BootAddr  = 32'h0,
    parameter [31:0]             HartId    = 32'h0
) (
    input  clk, rst_n,

    output [31:0] imem_addr,
    input  [31:0] imem_rdata,

    output [31:0] m_axi_awaddr,  output [2:0] m_axi_awprot,
    output        m_axi_awvalid, input        m_axi_awready,
    output [31:0] m_axi_wdata,   output [3:0] m_axi_wstrb,
    output        m_axi_wvalid,  input        m_axi_wready,
    input  [1:0]  m_axi_bresp,   input        m_axi_bvalid, output m_axi_bready,
    output [31:0] m_axi_araddr,  output [2:0] m_axi_arprot,
    output        m_axi_arvalid, input        m_axi_arready,
    input  [31:0] m_axi_rdata,   input  [1:0] m_axi_rresp,
    input         m_axi_rvalid,  output       m_axi_rready
);

  // ------------------------------------------------------------
  // Ibex core <-> imem shim (raw 1-cycle BRAM port, giong fetch_stage.v)
  // ------------------------------------------------------------
  wire        instr_req;
  wire        instr_gnt;
  reg         instr_rvalid_q;
  wire [31:0] instr_addr;

  assign imem_addr   = instr_addr;
  assign instr_gnt    = instr_req;      // BRAM 1 cong, luon san sang nhan dia chi moi

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) instr_rvalid_q <= 1'b0;
    else        instr_rvalid_q <= instr_req; // gnt==req nen rvalid = req tre 1 chu ky
  end

  // ------------------------------------------------------------
  // Ibex core <-> dmem shim (AXI4 qua axi_rissp_master.v, KHONG SUA)
  // ------------------------------------------------------------
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

  wire data_gnt_w    =  stall_cpu_w & ~stall_prev_q; // canh len: IDLE+req vua duoc nhan (latch dia chi)
  wire data_rvalid_w =  stall_prev_q & ~stall_cpu_w; // canh xuong: DONE, du lieu/ghi da xong

  axi_rissp_master u_dmem_bridge (
      .clk(clk), .rst_n(rst_n),
      .dmem_addr(data_addr), .dmem_wdata(data_wdata),
      .dmem_wstrb(dmem_wstrb_w),
      .dmem_read(dmem_read_w), .dmem_rdata(dmem_rdata_w),
      .stall_cpu(stall_cpu_w),
      .m_axi_awaddr(m_axi_awaddr), .m_axi_awprot(m_axi_awprot),
      .m_axi_awvalid(m_axi_awvalid), .m_axi_awready(m_axi_awready),
      .m_axi_wdata(m_axi_wdata),   .m_axi_wstrb(m_axi_wstrb),
      .m_axi_wvalid(m_axi_wvalid), .m_axi_wready(m_axi_wready),
      .m_axi_bresp(m_axi_bresp),   .m_axi_bvalid(m_axi_bvalid), .m_axi_bready(m_axi_bready),
      .m_axi_araddr(m_axi_araddr), .m_axi_arprot(m_axi_arprot),
      .m_axi_arvalid(m_axi_arvalid), .m_axi_arready(m_axi_arready),
      .m_axi_rdata(m_axi_rdata),   .m_axi_rresp(m_axi_rresp),
      .m_axi_rvalid(m_axi_rvalid), .m_axi_rready(m_axi_rready)
  );

  // ------------------------------------------------------------
  // Ibex core instantiation
  // ------------------------------------------------------------
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

      // Interrupts - khong dung trong SoC nay (giong RISSP, khong co IRQ controller)
      .irq_software_i(1'b0),
      .irq_timer_i   (1'b0),
      .irq_external_i(1'b0),
      .irq_fast_i    (15'h0),
      .irq_nm_i      (1'b0),

      // Scrambling - tat (ICacheScramble mac dinh = 0)
      .scramble_key_valid_i(1'b0),
      .scramble_key_i      ('0),
      .scramble_nonce_i    ('0),
      .scramble_req_o      (),

      // Debug - khong dung
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

      // Lockstep/shadow - khong dung (SecureIbex=0)
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
