`timescale 1ns / 1ps
module rissp_top (
    input clk, rst_n,
    output [31:0] imem_addr, input [31:0] imem_rdata,
    output [31:0] m_axi_awaddr, output [2:0] m_axi_awprot, output m_axi_awvalid, input m_axi_awready,
    output [31:0] m_axi_wdata, output [3:0] m_axi_wstrb, output m_axi_wvalid, input m_axi_wready,
    input [1:0] m_axi_bresp, input m_axi_bvalid, output m_axi_bready,
    output [31:0] m_axi_araddr, output [2:0] m_axi_arprot, output m_axi_arvalid, input m_axi_arready,
    input [31:0] m_axi_rdata, input [1:0] m_axi_rresp, input m_axi_rvalid, output m_axi_rready
);
    wire [31:0] int_dmem_addr, int_dmem_wdata, int_dmem_rdata;
    wire [31:0] pc, next_pc, insn, rs1_data, rs2_data, rdest_data;
    wire [3:0]  int_dmem_wstrb;
    wire [4:0]  rs1_addr, rs2_addr, rdest_addr;
    wire        int_dmem_read, stall_from_bridge, rf_wen_raw;

    // FIX CHÍ MẠNG: Ép next_pc về 0 khi đang reset để BRAM nạp đúng lệnh đầu tiên
    wire [31:0] safe_next_pc = (!rst_n) ? 32'h0 : (stall_from_bridge ? pc : next_pc);
    wire rf_wen_final = rf_wen_raw && !stall_from_bridge;

    axi_rissp_master u_bridge (
        .clk(clk), .rst_n(rst_n),
        .dmem_addr(int_dmem_addr), .dmem_wdata(int_dmem_wdata),
        .dmem_wstrb(int_dmem_wstrb),
        .dmem_read(int_dmem_read), .dmem_rdata(int_dmem_rdata),
        .stall_cpu(stall_from_bridge),
        .m_axi_awaddr(m_axi_awaddr), .m_axi_awvalid(m_axi_awvalid), .m_axi_awready(m_axi_awready),
        .m_axi_wdata(m_axi_wdata),   .m_axi_wstrb(m_axi_wstrb),
        .m_axi_wvalid(m_axi_wvalid), .m_axi_wready(m_axi_wready),
        .m_axi_bvalid(m_axi_bvalid), .m_axi_bready(m_axi_bready),
        .m_axi_araddr(m_axi_araddr), .m_axi_arvalid(m_axi_arvalid), .m_axi_arready(m_axi_arready),
        .m_axi_rdata(m_axi_rdata),   .m_axi_rvalid(m_axi_rvalid),   .m_axi_rready(m_axi_rready)
    );

    modular_ex mex (
        .pc(pc), .insn(insn),
        .rs1_data(rs1_data), .rs2_data(rs2_data), .dmem_rdata(int_dmem_rdata),
        .next_pc(next_pc), .rdest_data(rdest_data), .rdest_addr(rdest_addr),
        .rf_wen(rf_wen_raw), .rs1_addr(rs1_addr), .rs2_addr(rs2_addr),
        .dmem_addr(int_dmem_addr), .dmem_wdata(int_dmem_wdata),
        .dmem_wstrb(int_dmem_wstrb), .dmem_read(int_dmem_read)
    );

    fetch_stage fetch (
        .clk(clk), .rst_n(rst_n),
        .stall(stall_from_bridge),
        .next_pc(safe_next_pc),
        .imem_addr(imem_addr),
        .imem_rdata(imem_rdata),
        .pc(pc), .insn(insn)
    );

    register_file rf (
        .clk(clk), .rst_n(rst_n),
        .wen(rf_wen_final),
        .rs1_addr(rs1_addr), .rs2_addr(rs2_addr),
        .rdest_addr(rdest_addr), .rdest_data(rdest_data),
        .rs1_data(rs1_data), .rs2_data(rs2_data)
    );
endmodule