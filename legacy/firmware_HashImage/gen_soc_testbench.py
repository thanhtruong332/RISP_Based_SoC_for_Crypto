#!/usr/bin/env python3
"""
gen_soc_testbench.py - Sinh testbench FULL-SoC (RISSP that + Keccak that +
mo hinh AXI4-Lite hanh vi cho 2 BRAM + SHA3 register map) de verify firmware
kieu vong lap thuc su chay dung tren CPU that, khong chi "replay" du lieu
thang vao Keccak nhu tb_hash_image_replay.v truoc day.

Vi sao can ban nay (khac han replay cu): voi firmware vong lap, digest dung
hay sai phu thuoc CPU thuc thi dung 'lw'/'bltu' hay khong - khong the verify
chi bang cach replay 1 chuoi tu tinh san. Day la testbench dau tien trong
repo thuc su chay ca fetch_stage+modular_ex+register_file+axi_rissp_master
CUNG 1 mo phong voi SHA3 core that.

Gia dinh mo hinh hoa QUAN TRONG (chua co source that cua
SHA3_hardware_new_slave_lite_v1_0_S01_AXI.v de doi chieu, xem RISSP+SHA3.md):
CTRL (offset 0x08) tao ra XUNG iReady/iLast dung 1 chu ky (tu dong ha ve 0
o chu ky sau), khong phai muc (level) giu nguyen cho toi lan ghi ke tiep.
Day la hanh vi BAT BUOC phai co de Padder.v hoat dong dung (xem
Padder.v dong 68: 'assign update = (iReady|state) & ...' la mach to hop
theo MUC, giu iReady=1 nhieu chu ky se hap thu lap lai cung 1 tu). Neu AXI
wrapper that trong Vivado KHONG lam dung nhu vay, day se la 1 bug can sua -
ghi ro dieu nay khi doi chieu ket qua mo phong voi board that.
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent

SHA3_BASE = 0x44A00000
BRAM_DEBUG_BASE = 0xC0000000
IMAGE_BASE = 0xC2000000

TEMPLATE = """\
`timescale 1ns / 1ps
// Sinh TU DONG boi gen_soc_testbench.py - full-SoC: rissp_top that (fetch_stage +
// modular_ex + register_file + axi_rissp_master that) + Keccak that, drive qua
// mo hinh hanh vi AXI4-Lite cho 2 BRAM (debug + anh) va thanh ghi SHA3.
// Firmware: {prog_hex} ; Anh: {img_hex} ({img_bytes} byte)
// Ground truth (Python hashlib.sha3_256): {digest}
module {tb_name};
    reg clk = 0;
    reg rst_n = 0;
    always #5 clk = ~clk;

    // ---------------- IMEM (dong bo, 1-cycle latency giong BRAM that) ----------------
    reg [31:0] imem_mem [0:{imem_depth_m1}];
    wire [31:0] imem_addr;
    reg  [31:0] imem_rdata_r;
    always @(posedge clk) imem_rdata_r <= imem_mem[imem_addr[{imem_bits}:2]];
    initial $readmemh("{prog_hex}", imem_mem);

    // ---------------- AXI4-Lite master tu DUT ----------------
    wire [31:0] m_axi_awaddr;  wire [2:0] m_axi_awprot;  wire m_axi_awvalid; reg m_axi_awready;
    wire [31:0] m_axi_wdata;   wire [3:0] m_axi_wstrb;   wire m_axi_wvalid;  reg m_axi_wready;
    reg  [1:0]  m_axi_bresp;   reg m_axi_bvalid;         wire m_axi_bready;
    wire [31:0] m_axi_araddr;  wire [2:0] m_axi_arprot;  wire m_axi_arvalid; reg m_axi_arready;
    reg  [31:0] m_axi_rdata;   reg  [1:0] m_axi_rresp;   reg m_axi_rvalid;   wire m_axi_rready;

    // ---------------- Debug BRAM (8KB = 2048 tu) @ {dbg_base_hex} ----------------
    reg [31:0] dbg_mem [0:2047];
    integer dk;
    initial for (dk = 0; dk < 2048; dk = dk + 1) dbg_mem[dk] = 32'h0;

    // ---------------- Anh BRAM (256KB = 65536 tu) @ {img_base_hex} ----------------
    reg [31:0] img_mem [0:65535];
    initial $readmemh("{img_hex}", img_mem);

    // ---------------- SHA3 core THAT (Keccak.v) ----------------
    reg  [31:0] sha3_data_hi, sha3_data_lo;
    reg         sha3_iready_pulse, sha3_ilast_pulse;
    reg  [2:0]  sha3_ibyte_reg;
    wire        sha3_obuffer_full, sha3_oready, sha3_f_oack;
    wire [255:0] sha3_odata;

    Keccak #(.b(1600), .nr(24), .Length(4), .lbits(3)) u_keccak (
        .iClk(clk), .iRst(!rst_n),
        .iData({{sha3_data_hi, sha3_data_lo}}),
        .iReady(sha3_iready_pulse), .iLast(sha3_ilast_pulse), .iByte_num(sha3_ibyte_reg),
        .oBuffer_full(sha3_obuffer_full), .f_oAck(sha3_f_oack),
        .oData(sha3_odata), .oReady(sha3_oready)
    );

    // ---------------- Dia chi giai ma (address decode) ----------------
    localparam [31:0] SHA3_BASE = {sha3_base_hex};
    localparam [31:0] DBG_BASE  = {dbg_base_hex};
    localparam [31:0] IMG_BASE  = {img_base_hex};

    wire sel_w_sha3 = (m_axi_awaddr >= SHA3_BASE) && (m_axi_awaddr < SHA3_BASE + 32'h10000);
    wire sel_w_dbg  = (m_axi_awaddr >= DBG_BASE)  && (m_axi_awaddr < DBG_BASE  + 32'h2000);
    wire [10:0] dbg_widx = (m_axi_awaddr - DBG_BASE) >> 2;

    wire sel_r_sha3 = (m_axi_araddr >= SHA3_BASE) && (m_axi_araddr < SHA3_BASE + 32'h10000);
    wire sel_r_dbg  = (m_axi_araddr >= DBG_BASE)  && (m_axi_araddr < DBG_BASE  + 32'h2000);
    wire sel_r_img  = (m_axi_araddr >= IMG_BASE)  && (m_axi_araddr < IMG_BASE  + 32'h40000);
    wire [10:0] dbg_ridx = (m_axi_araddr - DBG_BASE) >> 2;
    wire [15:0] img_ridx = (m_axi_araddr - IMG_BASE) >> 2;

    // ---------------- AXI4-Lite write channel (luon san sang, giong tb_rissp_top.v) ----------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            m_axi_awready <= 1'b1; m_axi_wready <= 1'b1; m_axi_bvalid <= 1'b0; m_axi_bresp <= 2'b00;
            sha3_data_hi <= 32'h0; sha3_data_lo <= 32'h0;
            sha3_iready_pulse <= 1'b0; sha3_ilast_pulse <= 1'b0; sha3_ibyte_reg <= 3'h0;
        end else begin
            // Mac dinh xung ha ve 0 moi chu ky - chi len 1 chu ky dung luc ghi CTRL (0x08)
            sha3_iready_pulse <= 1'b0;
            sha3_ilast_pulse  <= 1'b0;
            if (m_axi_awvalid && m_axi_wvalid) begin
                if (sel_w_sha3) begin
                    case (m_axi_awaddr[7:0])
                        8'h00: sha3_data_hi <= m_axi_wdata;
                        8'h04: sha3_data_lo <= m_axi_wdata;
                        8'h08: begin
                            sha3_iready_pulse <= m_axi_wdata[0];
                            sha3_ilast_pulse  <= m_axi_wdata[1];
                            sha3_ibyte_reg    <= m_axi_wdata[4:2];
                        end
                        default: ;
                    endcase
                end else if (sel_w_dbg) begin
                    if (m_axi_wstrb[0]) dbg_mem[dbg_widx][7:0]   <= m_axi_wdata[7:0];
                    if (m_axi_wstrb[1]) dbg_mem[dbg_widx][15:8]  <= m_axi_wdata[15:8];
                    if (m_axi_wstrb[2]) dbg_mem[dbg_widx][23:16] <= m_axi_wdata[23:16];
                    if (m_axi_wstrb[3]) dbg_mem[dbg_widx][31:24] <= m_axi_wdata[31:24];
                end
                m_axi_bvalid <= 1'b1;
            end else if (m_axi_bvalid && m_axi_bready) begin
                m_axi_bvalid <= 1'b0;
            end
        end
    end

    // ---------------- AXI4-Lite read channel ----------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            m_axi_arready <= 1'b1; m_axi_rvalid <= 1'b0; m_axi_rresp <= 2'b00; m_axi_rdata <= 32'h0;
        end else begin
            if (m_axi_arvalid && !m_axi_rvalid) begin
                if (sel_r_sha3) begin
                    case (m_axi_araddr[7:0])
                        8'h0C: m_axi_rdata <= {{30'b0, sha3_obuffer_full, sha3_oready}};
                        8'h10: m_axi_rdata <= sha3_odata[255:224];
                        8'h14: m_axi_rdata <= sha3_odata[223:192];
                        8'h18: m_axi_rdata <= sha3_odata[191:160];
                        8'h1C: m_axi_rdata <= sha3_odata[159:128];
                        8'h20: m_axi_rdata <= sha3_odata[127:96];
                        8'h24: m_axi_rdata <= sha3_odata[95:64];
                        8'h28: m_axi_rdata <= sha3_odata[63:32];
                        8'h2C: m_axi_rdata <= sha3_odata[31:0];
                        default: m_axi_rdata <= 32'h0;
                    endcase
                end else if (sel_r_dbg) begin
                    m_axi_rdata <= dbg_mem[dbg_ridx];
                end else if (sel_r_img) begin
                    m_axi_rdata <= img_mem[img_ridx];
                end else begin
                    m_axi_rdata <= 32'hDEADBEEF;
                end
                m_axi_rvalid <= 1'b1;
            end else if (m_axi_rvalid && m_axi_rready) begin
                m_axi_rvalid <= 1'b0;
            end
        end
    end

    // ---------------- DUT: rissp_top THAT (khong sua gi) ----------------
    rissp_top dut (
        .clk(clk), .rst_n(rst_n),
        .imem_addr(imem_addr), .imem_rdata(imem_rdata_r),
        .m_axi_awaddr(m_axi_awaddr), .m_axi_awprot(m_axi_awprot), .m_axi_awvalid(m_axi_awvalid), .m_axi_awready(m_axi_awready),
        .m_axi_wdata(m_axi_wdata), .m_axi_wstrb(m_axi_wstrb), .m_axi_wvalid(m_axi_wvalid), .m_axi_wready(m_axi_wready),
        .m_axi_bresp(m_axi_bresp), .m_axi_bvalid(m_axi_bvalid), .m_axi_bready(m_axi_bready),
        .m_axi_araddr(m_axi_araddr), .m_axi_arprot(m_axi_arprot), .m_axi_arvalid(m_axi_arvalid), .m_axi_arready(m_axi_arready),
        .m_axi_rdata(m_axi_rdata), .m_axi_rresp(m_axi_rresp), .m_axi_rvalid(m_axi_rvalid), .m_axi_rready(m_axi_rready)
    );

    // ---------------- Chay + kiem tra ----------------
    integer cyc;
    integer errors = 0;
    localparam [255:0] EXPECTED = 256'h{digest};

    initial begin
        rst_n = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;

        cyc = 0;
        while (dbg_mem[8] !== 32'h600d600d && cyc < {timeout_cycles}) begin
            @(posedge clk);
            cyc = cyc + 1;
        end

        if (dbg_mem[8] !== 32'h600d600d) begin
            $display("[FAIL] TIMEOUT sau %0d chu ky - chua thay marker 0x600d600d", cyc);
            errors = errors + 1;
        end else begin
            if ({{dbg_mem[0],dbg_mem[1],dbg_mem[2],dbg_mem[3],dbg_mem[4],dbg_mem[5],dbg_mem[6],dbg_mem[7]}} !== EXPECTED) begin
                $display("[FAIL] digest=%h expected=%h",
                    {{dbg_mem[0],dbg_mem[1],dbg_mem[2],dbg_mem[3],dbg_mem[4],dbg_mem[5],dbg_mem[6],dbg_mem[7]}}, EXPECTED);
                errors = errors + 1;
            end else begin
                $display("[PASS] {tb_name} FULL-SOC (CPU that thuc thi vong lap that) digest=%h sau %0d chu ky",
                    {{dbg_mem[0],dbg_mem[1],dbg_mem[2],dbg_mem[3],dbg_mem[4],dbg_mem[5],dbg_mem[6],dbg_mem[7]}}, cyc);
            end
        end

        if (errors == 0) $display("FULL-SOC HASH_IMAGE VERIFIED CORRECT (CPU that, khong phai replay)");
        else $display("%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule
"""


def build(prog_hex: str, img_hex: str, img_bytes: int, digest: str, tb_name: str, timeout_cycles: int = 4_000_000):
    content = TEMPLATE.format(
        tb_name=tb_name,
        prog_hex=prog_hex,
        img_hex=img_hex,
        img_bytes=img_bytes,
        digest=digest,
        sha3_base_hex=f"32'h{SHA3_BASE:08X}",
        dbg_base_hex=f"32'h{BRAM_DEBUG_BASE:08X}",
        img_base_hex=f"32'h{IMAGE_BASE:08X}",
        imem_depth_m1=1023,
        imem_bits=11,
        timeout_cycles=timeout_cycles,
    )
    out_path = HERE / f"tb_{tb_name}.v"
    out_path.write_text(content, encoding="utf-8")
    print(f"-> {out_path}")


if __name__ == "__main__":
    if len(sys.argv) < 6:
        print("usage: gen_soc_testbench.py <prog_hex> <img_hex> <img_bytes> <digest_hex> <tb_name> [timeout_cycles]")
        sys.exit(1)
    prog_hex, img_hex, img_bytes, digest, tb_name = sys.argv[1:6]
    timeout = int(sys.argv[6]) if len(sys.argv) > 6 else 4_000_000
    build(prog_hex, img_hex, int(img_bytes), digest, tb_name, timeout)
