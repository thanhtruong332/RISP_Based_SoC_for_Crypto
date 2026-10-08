#!/usr/bin/env python3
"""
gen_loop_firmware.py - Sinh firmware kieu VONG LAP (khong unroll) cho anh
lon (256x256/512x512), doc du lieu tu 1 BRAM AXI rieng (axi_bram_ctrl_1)
thay vi nhoi tung byte thanh lenh li.

Khac han gen_image_firmware.py (ban unroll, chi hop voi anh nho <=~96x96):
firmware o day co KICH THUOC CO DINH (~40 lenh) khong phu thuoc kich thuoc
anh, vi CPU tu doc tuan tu qua 'lw' tu 1 vung BRAM rieng danh cho anh.

Dieu kien tien quyet (da xac nhan trong RTL that):
- axi_rissp_master.v la cau AXI4 TONG QUAT, chuyen thang moi dmem_addr/
  dmem_read/dmem_wstrb ra AXI - khong gioi han theo dia chi, nen CPU da
  'lw' duoc tu bat ky peripheral AXI nao (khong chi SHA3), xem RISSP+SHA3.md
  hoac hoi thoai da phan tich axi_rissp_master.v.
- Padder.v: 'assign update = (iReady|state) & ~(oBufferFull|done);' - iReady
  la TIN HIEU MUC (level), khong phai canh - neu giu iReady=1 nhieu chu ky
  se hap thu LAP LAI cung 1 tu -> BAT BUOC iReady chi duoc cao dung 1 chu ky
  moi lan ghi CTRL (giong het cach tb_hash_image_replay.v da lam voi
  send_word task). Model hanh vi nay trong testbench full-SoC di kem.

Quy uoc dong goi image .coe: MOI DONG la 1 tu 32-bit, gia tri = 4 byte
anh lien tiep dong goi BIG-ENDIAN (byte dau o bit[31:24]) - giong het quy
uoc data_hi/data_lo cua SHA3 core. Vi BRAM la WORD-addressed (khong phai
byte-addressed that), 'lw' tu dia chi nay se tra ve DUNG gia tri da dong
goi, KHONG can byte-swap them trong firmware.
"""
import hashlib
import struct
import sys
from pathlib import Path

SHA3_BASE = 0x44A00000
BRAM_DEBUG_BASE = 0xC0000000
IMAGE_BASE = 0xC2000000

HERE = Path(__file__).parent


def pack_words(data: bytes):
    n = len(data)
    nwords = n // 8
    rem = n % 8
    return nwords, rem


def gen_asm(name: str, image_size: int, nwords: int, rem: int, digest_hex: str) -> str:
    image_end_full = IMAGE_BASE + nwords * 8
    lines = []
    lines.append(f"# {name}.s - RISSP+SHA3 SoC: hash anh {image_size} byte BANG VONG LAP")
    lines.append("# (khong unroll) - doc tu BRAM anh rieng qua axi_bram_ctrl_1.")
    lines.append("#")
    lines.append("# Sinh TU DONG boi gen_loop_firmware.py - khong sua tay, sua script")
    lines.append("# roi chay lai neu doi anh/dia chi.")
    lines.append("#")
    lines.append(f"# IMAGE_BASE = {IMAGE_BASE:#010x} (axi_bram_ctrl_1, kiem tra lai Address")
    lines.append("#   Editor moi lan Validate Design - neu doi, sua hang so duoi va build lai)")
    lines.append(f"# SHA3_BASE  = {SHA3_BASE:#010x}")
    lines.append(f"# DEBUG_BRAM = {BRAM_DEBUG_BASE:#010x}")
    lines.append("#")
    lines.append(f"# Ground truth (Python hashlib.sha3_256, {image_size} byte):")
    lines.append(f"#   {digest_hex}")
    lines.append("")
    lines.append(".section .text")
    lines.append(".globl _start")
    lines.append("")
    lines.append("_start:")
    lines.append(f"    li   a0, {IMAGE_BASE:#010x}       # con tro dau anh (image BRAM)")
    lines.append(f"    li   a2, {image_end_full:#010x}       # dia chi cuoi cung TRON 8-byte")
    lines.append(f"    li   a1, {SHA3_BASE:#010x}       # SHA3 base")
    lines.append(f"    li   s0, {BRAM_DEBUG_BASE:#010x}       # debug BRAM (ghi ket qua)")
    lines.append("    li   t2, 1                 # CTRL tu thuong: iReady=1,iLast=0,ibyte=0")
    lines.append("")
    lines.append("loop:")
    lines.append("poll_buf_loop:")
    lines.append("    lw   t4, 0x0C(a1)          # STATUS")
    lines.append("    andi t4, t4, 2             # bit1 = oBuffer_full")
    lines.append("    bnez t4, poll_buf_loop")
    lines.append("    lw   t0, 0(a0)             # 4 byte dau -> data_hi (da dong goi big-endian trong .coe)")
    lines.append("    lw   t1, 4(a0)             # 4 byte sau -> data_lo")
    lines.append("    sw   t0, 0(a1)")
    lines.append("    sw   t1, 4(a1)")
    lines.append("    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)")
    lines.append("    addi a0, a0, 8")
    lines.append("    bltu a0, a2, loop")
    lines.append("")

    if rem == 0:
        lines.append("    # ---- Anh la boi so dung cua 8 -> gui 1 tu RONG bao ket thuc ----")
        lines.append("poll_buf_final:")
        lines.append("    lw   t4, 0x0C(a1)")
        lines.append("    andi t4, t4, 2")
        lines.append("    bnez t4, poll_buf_final")
        lines.append("    li   t3, 3                 # CTRL: iReady=1,iLast=1,ibyte_num=0")
        lines.append("    sw   x0, 0(a1)")
        lines.append("    sw   x0, 4(a1)")
        lines.append("    sw   t3, 8(a1)")
    else:
        ctrl = 1 | (1 << 1) | (rem << 2)
        lines.append(f"    # ---- {rem} byte du cuoi anh: doc rieng, dat MSB, bao iLast ----")
        lines.append("poll_buf_final:")
        lines.append("    lw   t4, 0x0C(a1)")
        lines.append("    andi t4, t4, 2")
        lines.append("    bnez t4, poll_buf_final")
        lines.append(f"    lw   t0, 0(a0)             # tu chua {rem} byte hop le o MSB (da dong goi san trong .coe)")
        lines.append("    lw   t1, 4(a0)")
        lines.append(f"    li   t3, {ctrl:#04x}                # CTRL: iReady=1,iLast=1,ibyte_num={rem}")
        lines.append("    sw   t0, 0(a1)")
        lines.append("    sw   t1, 4(a1)")
        lines.append("    sw   t3, 8(a1)")

    lines.append("")
    lines.append("poll_sha3:")
    lines.append("    lw   t0, 0x0C(a1)          # STATUS: bit0=oReady")
    lines.append("    andi t0, t0, 1")
    lines.append("    beqz t0, poll_sha3")
    lines.append("")
    lines.append("    # ---- Doc 8 tu digest (0x10..0x2C, MSB truoc), ghi ra debug BRAM ----")
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


def image_words(data: bytes):
    """Tra ve list 32-bit word values (dong goi big-endian per-4-byte-chunk)
    de ghi vao image .coe - 1 word = 4 byte anh, KHONG phai 1 word = 1 tu
    SHA3 64-bit (khac voi gen_image_firmware.py). Padding byte cuoi = 0."""
    n = len(data)
    words = []
    i = 0
    while i < n:
        chunk = data[i:i + 4]
        if len(chunk) < 4:
            chunk = chunk + b"\x00" * (4 - len(chunk))
        words.append(struct.unpack(">I", chunk)[0])
        i += 4
    return words


def write_coe(words, path: Path):
    with open(path, "w") as f:
        f.write("memory_initialization_radix=16;\n")
        f.write("memory_initialization_vector=\n")
        for i, w in enumerate(words):
            sep = ";" if i == len(words) - 1 else ","
            f.write(f"{w:08X}{sep}\n")


def write_readmemh_hex(words, path: Path):
    with open(path, "w") as f:
        for w in words:
            f.write(f"{w:08X}\n")


def build(image_path: str, out_prefix: str):
    data = Path(image_path).read_bytes()
    digest = hashlib.sha3_256(data).hexdigest()
    nwords, rem = pack_words(data)

    asm = gen_asm(out_prefix, len(data), nwords, rem, digest)
    (HERE / f"{out_prefix}.s").write_text(asm, encoding="utf-8")

    img_words = image_words(data)
    write_coe(img_words, HERE / f"{out_prefix}_imagedata.coe")
    write_readmemh_hex(img_words, HERE / f"{out_prefix}_imagedata.hex")

    print(f"[{out_prefix}] anh: {len(data)} byte, {nwords} tu SHA3 tron + {rem} byte du")
    print(f"[{out_prefix}] image .coe: {len(img_words)} tu 32-bit (cho axi_bram_ctrl_1 @ {IMAGE_BASE:#010x})")
    print(f"[{out_prefix}] ground truth sha3_256 = {digest}")
    return digest


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("usage: gen_loop_firmware.py <image_raw_file> <out_prefix>")
        sys.exit(1)
    build(sys.argv[1], sys.argv[2])
