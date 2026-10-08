# SE-RISSP_FULL — firmware + testbench cho SoC `SE-RISSP_AES_ULTRA`

SoC: **RISSP + AES + SHA3 + RSA** (`F:\advance_topic\SE-RISSP_AES_ULTRA`,
Zynq xc7z020, 40MHz). Mỗi chức năng có **1 bộ riêng**: 1 file `.coe` nạp vào
`blk_mem_gen_0` (imem) + 1 testbench chạy trên `design_1_wrapper` thật.

## ✅ Yêu cầu: imem phải 1 chu kỳ (đã sửa xong)

Block Design đã **bỏ tick "Register PortA Output of Memory Primitives"** trên
`blk_mem_gen_0` → imem 1 chu kỳ, đúng hợp đồng của `fetch_stage.v`. Firmware
dùng vòng lặp poll (có lệnh nhánh rẽ) nên **bắt buộc** cấu hình này.

## Phạm vi: mỗi mode test 1 case

Mỗi firmware mã hoá/băm **1 case duy nhất** theo test vector chuẩn
(AES: NIST SP800-38A 1 block 128-bit; SHA3: 16 byte; RSA: 1 phép modexp).

### Firmware đã tối ưu để số liệu phản ánh đúng hiệu năng

| Vấn đề bản đầu | Đã sửa thành |
|---|---|
| Chờ lõi bằng NOP padding (40/60/220 NOP) — 37% cửa sổ đo là NOP rỗng | **Poll STATUS** — chờ đúng bằng thời gian lõi cần |
| 40 NOP chờ sau khi ghi KEY | **Bỏ hẳn** — `AESEncrypt` tự đợi `keys_valid` qua `start_req` |
| Đọc mỗi thanh ghi 2 lần (workaround imem 2 chu kỳ) | **Đọc 1 lần** |
| Testbench chốt mốc CT theo *số lần đọc* → sai khi đọc lặp | Chốt theo **địa chỉ từ cuối** (`0x3C`) |

Kết quả (ECB, đo thật trên SoC): PURE 120→**98** ck (42,67→**52,24** Mbps),
FULL 200→**138** ck (25,60→**37,10** Mbps). Firmware ngắn hơn nhiều:
172→**43** từ.

## Cách chạy từng bộ

Với mỗi chức năng, làm 3 bước:

1. **Nạp firmware**: double-click `blk_mem_gen_0` → tick **Load Init File** →
   **Coe File** = file `.coe` tương ứng → OK → Validate → **Generate Output
   Products**.
2. **Đặt testbench**: add file `.v` tương ứng vào `sim_1`, set làm **Top**.
3. **Run Simulation** → xem kết quả ở **Tcl Console**.

| Chức năng | Nạp file | Testbench (top) | Chu kỳ¹ |
|---|---|---|---:|
| AES-128 **ECB** | `aes_ecb.coe` | `tb_aes_ecb` | 145 |
| AES-128 **CBC** | `aes_cbc.coe` | `tb_aes_cbc` | 177 |
| AES-128 **CFB** | `aes_cfb.coe` | `tb_aes_cfb` | 177 |
| AES-128 **CTR** | `aes_ctr.coe` | `tb_aes_ctr` | 177 |
| **SHA3-256** (128 byte) | `sha3.coe` | `tb_sha3` | 523 |
| **RSA** verify | `rsa.coe` | `tb_rsa` | 261 |

¹ Tổng chu kỳ đo trên mô phỏng RTL (CPU thật + lõi thật, imem 1 chu kỳ;
imem 2 chu kỳ chỉ hơn đúng 1 chu kỳ).

> **QUAN TRỌNG**: file `.coe` đã được sinh lại (dài hơn bản cũ do thêm kỹ
> thuật đọc 2 lần). Phải **nạp lại** vào `blk_mem_gen_0` + Generate Output
> Products, không dùng lại bản `.coe` cũ.

## Kết quả kỳ vọng (đã verify bằng RTL thật, không phải suy đoán)

Mỗi mode dùng **1 vector khác nhau** (cho phong phú) nhưng đều truy vết được
về chuẩn — không phải số tự bịa. Giá trị kỳ vọng do `gen_all.py` **tự tính**
bằng pycryptodome, nên đổi `key`/`pt`/`iv` trong `AES_CASE` là `ct` tự cập
nhật, không phải tra bảng tay.

| Mode | Nguồn vector | key | plaintext | IV / counter | ciphertext kỳ vọng |
|---|---|---|---|---|---|
| ECB | FIPS-197 App. C.1 | `000102…0e0f` | `00112233…ccddeeff` | — | `69c4e0d8 6a7b0430 d8cdb780 70b4c55a` |
| CBC | SP800-38A F.2.1 blk3 | `2b7e1516…` | `30c81c46…1a0a52ef` | `5086cb9b…917678b2` | `73bed6b8 e3c1743b 7116e69e 22229516` |
| CFB | SP800-38A F.3.13 blk4 | `2b7e1516…` | `f69f2445…e66c3710` | `26751f67…87a4f4df` | `c04b0535 7c5d1c0e eac4c66f 9ff7f2e6` |
| CTR | SP800-38A F.5.1 blk3 | `2b7e1516…` | `30c81c46…1a0a52ef` | `f0f1f2f3…fcfdff01` | `5ae4df3e dbd5d35e 5b4f0902 0db03eab` |

**SHA3-256** — message **128 byte** (4 block plaintext NIST lặp 2 lần).
Chọn 128 byte vì rate SHA3-256 là 136 byte: 128 + 8 byte padding = đúng
**1 block** ⇒ khai thác tối đa 1 lần permutation. (Bản cũ 16 byte chỉ dùng
11,8% năng lực, làm throughput đo được thấp hơn thật ~8,4 lần.)

| | Giá trị |
|---|---|
| digest | `d1985c30 73f0ff34 c1717893 0e28f04e ac5d6db5 dd5ff147 bea7b4a7 87176cc7` |
| XOR-fold (`0x20`) | `25836f4b` |

**RSA** `M^E mod N` → `25836f4b` — **bằng đúng XOR-fold của SHA3** ⇒ chữ ký
hợp lệ. Chữ ký được `gen_all.py` **tự ký lại** theo fold hiện tại (hàm dùng
khoá `d` tính tại chỗ cho tiện demo), nên đổi `SHA3_MSG` thì chuỗi
SHA3→RSA luôn nhất quán, không phải sửa tay.

### Muốn đổi số test

Sửa `AES_CASE` ở đầu `gen_all.py` rồi chạy `python gen_all.py`. Ciphertext
kỳ vọng trong firmware **và** trong testbench đều tự tính lại — không có chỗ
nào phải sửa tay, không sợ lệch.

Testbench tự đối chiếu và in `[PASS]`/`[FAIL]` cho từng giá trị.

## Bản đồ bộ nhớ BRAM debug (`0xC0000000`)

| Firmware | Offset | Nội dung |
|---|---|---|
| AES (cả 4 mode) | `0x00-0x0C` | ciphertext 4 từ |
| | `0x10` | marker `600D0001`/`0002`/`0003`/`0004` (ECB/CBC/CFB/CTR) |
| SHA3 | `0x00-0x1C` | digest 8 từ |
| | `0x20` | XOR-fold |
| | `0x30` | marker `600D0005` |
| RSA | `0x00` | RESULT |
| | `0x10` | marker `600D0006` |

## Tốc độ mô phỏng

Testbench **ép thẳng xung 40MHz** vào net clock nội bộ của Block Design
(`clk_wiz_0_clk_out1`) thay vì chờ MMCM lock. Lý do: MMCM cần khoảng **2ms
thời gian mô phỏng** mới lock xong và bắt đầu phát clock, trong khi CPU chỉ
cần ~300 chu kỳ (~7µs) để chạy xong — tức là hơn 99% thời gian mô phỏng là
ngồi chờ MMCM. Về chức năng hoàn toàn tương đương, chỉ bỏ qua phần mô hình
hoá quá trình khởi động MMCM.

**Lưu ý**: `force` vào net nội bộ chỉ hoạt động khi elaborate có
`-debug typical` — Vivado GUI mặc định đã bật, nên chạy trong GUI không cần
làm gì. Nếu chạy `xelab` bằng dòng lệnh mà thiếu cờ này, clock sẽ không chạy;
testbench có timeout tuyệt đối 1ms và sẽ báo đúng nguyên nhân đó thay vì treo.

## Testbench đo gì

Mỗi testbench instantiate **`design_1_wrapper` thật** (dùng nguyên
`axi_interconnect_0`, `clk_wiz_0`, `proc_sys_reset_0`, `axi_bram_ctrl_0`),
chỉ drive `clk_in1_0` (100MHz) + `reset_0`. Đọc kết quả bằng cách snoop
`BRAM_PORTA` giữa `axi_bram_ctrl_0` và `blk_mem_gen_1` (không `$readmemh`
được vào `blk_mem_gen` vì là IP mã hoá).

Có `force clk_wiz_0.locked = 1'b1` ngay đầu để **bỏ qua thời gian lock
MMCM** — nếu không, mô phỏng chạy rất lâu mới thấy CPU bắt đầu.

Chỉ số in ra:
- **AES**: 4 mốc throughput (AES core / PURE `PT→CT` / FULL `KEY→CT` /
  END-TO-END `PT→BRAM`) theo Mbps, Energy/block, Energy/bit, Mbps/W.
- **SHA3**: Keccak permutation (`iLast→oReady`), end-to-end, Energy.
- **RSA**: latency `start→done` (µs), số verify/giây, Energy/verify.

## Register map (đọc trực tiếp từ RTL, không đoán)

| Lõi | Base | Thanh ghi |
|---|---|---|
| AES | `0x40000000` | DATA_IN `0x00-0x0C`, KEY `0x10-0x1C`, **CTRL `0x20`**, STATUS `0x24`, DATA_OUT `0x30-0x3C`, IV `0x40-0x4C` |
| SHA3 | `0x44000000` | data_hi `0x00`, data_lo `0x04`, **CTRL `0x08`**, STATUS `0x0C`, digest `0x10-0x2C` |
| RSA | `0x48000000` | M `0x00`, E `0x04`, N `0x08`, N_INV `0x0C`, R2 `0x10`, **CTRL `0x14`**, STATUS `0x18`, RESULT `0x1C` |
| BRAM | `0xC0000000` | 8KB vùng debug |

**AES CTRL**: bit0 = start, bit[2:1] = mode →
`0x1`=ECB, `0x3`=CBC, `0x5`=CTR, `0x7`=CFB.
`mode_reg` **không đọc lại được qua AXI** (`aes_wrapper.v` không có case đọc
nó) — nên 4 mode phân biệt bằng file `.coe` riêng, không phải bằng thanh ghi.

**SHA3 CTRL**: bit0 = iReady, bit1 = iLast, bit[4:2] = iByte_num →
`0x1` = absorb 1 từ, `0x3` = từ cuối (kích padding + permutation).

## Số chu kỳ lõi (đo thật trên RTL — dùng để tính số NOP chờ)

| Lõi | Chu kỳ |
|---|---:|
| AES KeyExpansion (1 lần) | 11 |
| AES mã hoá 1 block | 12 |
| SHA3 `iLast` → `oReady` | 39 |
| RSA `start` → `done` (E=65537) | 182 |

Firmware chờ dư an toàn: AES 40 NOP, SHA3 60 NOP, RSA 220 NOP.

## File trong thư mục

```
gen_all.py            script sinh lai TOAN BO (sua o day roi chay lai,
                      dung sua tay file .s/.coe/.v)
link.ld               linker script (đặt chương trình tại 0x0)

aes_ecb.s/.coe/.hex   +  tb_aes_ecb.v
aes_cbc.s/.coe/.hex   +  tb_aes_cbc.v
aes_cfb.s/.coe/.hex   +  tb_aes_cfb.v
aes_ctr.s/.coe/.hex   +  tb_aes_ctr.v
sha3.s/.coe/.hex      +  tb_sha3.v
rsa.s/.coe/.hex       +  tb_rsa.v
```

`.hex` là bản `$readmemh` (dùng nếu muốn mô phỏng không qua Block Design).

Sinh lại toàn bộ: `python gen_all.py`
(cần toolchain `F:\xpack-riscv-none-elf-gcc-15.2.0-1\bin`).
