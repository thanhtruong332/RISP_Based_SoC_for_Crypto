#!/usr/bin/env python3
"""
gen_image_firmware.py - Sinh firmware .s + testbench replay .v cho RISSP+SHA3
tu 1 anh raw grayscale bat ky (hoac tu synthetic pattern neu khong co anh that).

Tai sao can script nay (khong viet tay nhu hash_image.s cu):
- RISSP khong co duong LW doc du lieu tu imem -> phai unroll toan bo anh
  thanh cac cum li+li+sw+sw+sw co dinh trong chuong trinh (xem CLAUDE.md,
  hash_image.md).
- Them ban sua loi so voi hash_image.s ban dau: CO poll oBuffer_full
  (STATUS bit1, offset 0x0C) TRUOC moi lan ghi tu moi - hash_image.s cu
  KHONG lam dieu nay (xem SHA3_Core/SHA3.md muc "Gioi han quy mo" va
  memory project_axi_backpressure_risk) - voi anh nhieu block (32x32,
  64x64 tran hang chuc block SHA3-256) rui ro mat du lieu am tham cao hon
  han ban demo 448-byte cu (~3 block), nen bat buoc phai poll.

Quy uoc dong goi (dung SHA3_Core/SHA3.md + tb_sha3_multiblock.v):
- Moi tu 64-bit = 8 byte message, dong goi big-endian theo tung chunk
  4-byte: data_hi = byte[0..3] big-endian, data_lo = byte[4..7] big-endian.
- Tu cuoi neu con du < 8 byte: cac byte hop le dat o dau (MSB) cua
  data_hi/data_lo, phan con lai = 0, iByte_num = so byte du (1-7).
- Neu do dai la boi so dung cua 8: gui them 1 tu RONG voi iLast=1,
  iByte_num=0 (khop hash_image.s cu).
- CTRL (offset 0x08) = iReady(bit0) | iLast(bit1) | iByte_num(bit[4:2])
  (da xac nhan dung file AXI wrapper that, xem comment trong hash_test_abc.s).
"""
import hashlib
import struct
import sys
from pathlib import Path

SHA3_BASE = 0x44A00000
BRAM_BASE = 0xC0000000

HERE = Path(__file__).parent


def synth_image(n: int) -> bytes:
    """Anh grayscale n x n synthetic, deterministic (khong phu thuoc anh that
    ben ngoai) - dung lam placeholder demo, thay bang anh that neu can bang
    cach doi ham nay sang doc file."""
    data = bytearray(n * n)
    for y in range(n):
        for x in range(n):
            data[y * n + x] = (x * 17 + y * 29 + 7) & 0xFF
    return bytes(data)


def pack_words(data: bytes):
    """Tra ve list cac (data_hi, data_lo, is_last, byte_num) theo dung
    giao thuc SHA3 core."""
    n = len(data)
    nwords = n // 8
    rem = n % 8
    words = []
    for i in range(nwords):
        chunk = data[i * 8:(i + 1) * 8]
        hi = struct.unpack(">I", chunk[0:4])[0]
        lo = struct.unpack(">I", chunk[4:8])[0]
        words.append((hi, lo, False, 0))
    if rem == 0:
        words.append((0, 0, True, 0))
    else:
        chunk = data[nwords * 8:nwords * 8 + rem] + b"\x00" * (8 - rem)
        hi = struct.unpack(">I", chunk[0:4])[0]
        lo = struct.unpack(">I", chunk[4:8])[0]
        words.append((hi, lo, True, rem))
    return words


def gen_asm(name: str, data: bytes, words) -> str:
    digest = hashlib.sha3_256(data).hexdigest()
    lines = []
    lines.append(f"# {name}.s - RISSP+SHA3 SoC: hash anh test {len(data)} byte")
    lines.append("# bang SHA3-256, ghi digest ra vung debug 0xC0000000.")
    lines.append("#")
    lines.append("# Sinh TU DONG boi gen_image_firmware.py - khong sua tay file nay,")
    lines.append("# sua script roi chay lai neu can doi anh/kich thuoc.")
    lines.append("#")
    lines.append("# KHAC hash_image.s ban dau: co POLL oBuffer_full (STATUS bit1)")
    lines.append("# TRUOC moi lan ghi tu moi de tranh mat du lieu am tham khi anh")
    lines.append("# tran nhieu block SHA3 (xem SHA3_Core/SHA3.md).")
    lines.append("#")
    lines.append(f"# Ground truth (Python hashlib.sha3_256, {len(data)} byte):")
    lines.append(f"#   {digest}")
    lines.append("")
    lines.append(".section .text")
    lines.append(".globl _start")
    lines.append("")
    lines.append("_start:")
    lines.append(f"    li   a1, {SHA3_BASE:#010x}       # SHA3 base")
    lines.append(f"    li   s0, {BRAM_BASE:#010x}       # vung debug/ket qua (BRAM)")
    lines.append("    li   t2, 1                 # CTRL tu thuong: iReady=1,iLast=0,ibyte=0")
    lines.append("")

    for i, (hi, lo, is_last, byte_num) in enumerate(words):
        lines.append(f"poll_buf_{i}:")
        lines.append(f"    lw   t4, 0x0C(a1)          # STATUS")
        lines.append(f"    andi t4, t4, 2             # bit1 = oBuffer_full")
        lines.append(f"    bnez t4, poll_buf_{i}")
        if not is_last:
            lines.append(f"    li   t0, {hi:#010x}")
            lines.append(f"    li   t1, {lo:#010x}")
            lines.append(f"    sw   t0, 0(a1)             # tu {i}: data_hi")
            lines.append(f"    sw   t1, 4(a1)             # tu {i}: data_lo")
            lines.append(f"    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)")
        else:
            ctrl = 1 | (1 << 1) | (byte_num << 2)
            lines.append(f"    li   t0, {hi:#010x}")
            lines.append(f"    li   t1, {lo:#010x}")
            lines.append(f"    li   t3, {ctrl:#04x}                # CTRL: iReady=1,iLast=1,ibyte={byte_num}")
            lines.append(f"    sw   t0, 0(a1)             # tu cuoi ({i}): data_hi")
            lines.append(f"    sw   t1, 4(a1)             # tu cuoi ({i}): data_lo")
            lines.append(f"    sw   t3, 8(a1)             # absorb + bao ket thuc")
        lines.append("")

    lines.append("poll_sha3:")
    lines.append("    lw   t0, 0x0C(a1)          # STATUS: bit0=oReady")
    lines.append("    andi t0, t0, 1")
    lines.append("    beqz t0, poll_sha3")
    lines.append("")
    lines.append("    # ---- Doc 8 tu digest (0x10..0x2C, MSB truoc), ghi ra BRAM ----")
    for i in range(8):
        off = 0x10 + i * 4
        doff = i * 4
        lines.append(f"    lw   t0, {off:#04x}(a1)")
        lines.append(f"    sw   t0, {doff:#04x}(s0)          # digest word {i}")
    lines.append("")
    lines.append("    li   t0, 0x600d600d       # marker: hash xong")
    lines.append(f"    sw   t0, {0x20:#04x}(s0)")
    lines.append("")
    lines.append("halt:")
    lines.append("    j    halt")
    lines.append("")
    return "\n".join(lines)


def gen_tb(name: str, data: bytes, words) -> str:
    digest = hashlib.sha3_256(data).hexdigest()
    lines = []
    lines.append("`timescale 1ns / 1ps")
    lines.append(f"// Verify dung chuoi tu ma {name}.s se ghi ({len(data)} byte, sinh boi")
    lines.append("// gen_image_firmware.py) - drive thang vao Keccak, doi chieu Python hashlib.")
    lines.append(f"module tb_{name}_replay;")
    lines.append("    reg clk = 0;")
    lines.append("    reg rst = 1;")
    lines.append("    reg [63:0] iData;")
    lines.append("    reg        iReady, iLast;")
    lines.append("    reg [2:0]  iByte_num;")
    lines.append("    wire oBuffer_full, f_oAck, oReady;")
    lines.append("    wire [255:0] oData;")
    lines.append("")
    lines.append("    always #5 clk = ~clk;")
    lines.append("")
    lines.append("    Keccak #(.b(1600), .nr(24), .Length(4), .lbits(3)) dut (")
    lines.append("        .iClk(clk), .iRst(rst), .iData(iData),")
    lines.append("        .iReady(iReady), .iLast(iLast), .iByte_num(iByte_num),")
    lines.append("        .oBuffer_full(oBuffer_full), .f_oAck(f_oAck),")
    lines.append("        .oData(oData), .oReady(oReady)")
    lines.append("    );")
    lines.append("")
    lines.append("    task send_word;")
    lines.append("        input [63:0] w;")
    lines.append("        input is_last;")
    lines.append("        input [2:0] byte_num;")
    lines.append("        begin")
    lines.append("            @(negedge clk);")
    lines.append("            while (oBuffer_full) @(negedge clk);")
    lines.append("            iData = w; iLast = is_last; iByte_num = byte_num; iReady = 1'b1;")
    lines.append("            @(negedge clk);")
    lines.append("            iReady = 1'b0; iLast = 1'b0;")
    lines.append("        end")
    lines.append("    endtask")
    lines.append("")
    lines.append("    integer errors = 0;")
    lines.append("    integer cyc;")
    lines.append(f"    localparam [255:0] EXPECTED = 256'h{digest};")
    lines.append("")
    lines.append("    initial begin")
    lines.append("        rst = 1; iReady = 0; iLast = 0; iByte_num = 0; iData = 0;")
    lines.append("        repeat (5) @(posedge clk);")
    lines.append("        rst = 0;")
    lines.append("        @(posedge clk);")
    lines.append("")
    for hi, lo, is_last, byte_num in words:
        w = (hi << 32) | lo
        last_bit = "1'b1" if is_last else "1'b0"
        lines.append(f"        send_word(64'h{w:016x}, {last_bit}, 3'd{byte_num});")
    lines.append("")
    lines.append("        cyc = 0;")
    lines.append("        while (!oReady && cyc < 20000) begin @(posedge clk); cyc = cyc + 1; end")
    lines.append("        if (!oReady) begin")
    lines.append('            $display("[FAIL] TIMEOUT sau %0d chu ky", cyc);')
    lines.append("            errors = errors + 1;")
    lines.append("        end else if (oData !== EXPECTED) begin")
    lines.append('            $display("[FAIL] oData=%h expected=%h", oData, EXPECTED);')
    lines.append("            errors = errors + 1;")
    lines.append("        end else begin")
    lines.append(f'            $display("[PASS] {name} replay (%0d byte) oData=%h sau %0d chu ky", {len(data)}, oData, cyc);')
    lines.append("        end")
    lines.append("")
    lines.append("        if (errors == 0) $display(\"REPLAY VERIFIED CORRECT\");")
    lines.append('        else $display("%0d TEST(S) FAILED", errors);')
    lines.append("        $finish;")
    lines.append("    end")
    lines.append("endmodule")
    lines.append("")
    return "\n".join(lines)


def build_one(n: int):
    name = f"hash_image_{n}x{n}"
    data = synth_image(n)
    words = pack_words(data)
    digest = hashlib.sha3_256(data).hexdigest()

    (HERE / f"test_image_{n}x{n}.raw").write_bytes(data)
    (HERE / f"{name}.s").write_text(gen_asm(name, data, words), encoding="utf-8")
    (HERE / f"tb_{name}_replay.v").write_text(gen_tb(name, data, words), encoding="utf-8")

    nwords = len(data) // 8
    rem = len(data) % 8
    print(f"[{name}] {len(data)} byte anh, {nwords} tu tron + {rem} byte du, "
          f"{len(words)} tu SHA3 tong cong")
    print(f"[{name}] ground truth sha3_256 = {digest}")
    return name, digest


if __name__ == "__main__":
    sizes = [int(a) for a in sys.argv[1:]] or [11, 32, 64]
    for n in sizes:
        build_one(n)
