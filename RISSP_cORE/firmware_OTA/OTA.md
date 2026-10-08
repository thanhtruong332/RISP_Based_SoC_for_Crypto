# firmware_OTA — Demo "Secure OTA Firmware Update" cho paper

Firmware minh hoạ ứng dụng end-to-end phối hợp **cả 3 lõi crypto**
(AES+SHA3+RSA) trong `SE-RISSP_AES_ULTRA` — hướng (C) đã bàn trong
`../PaperStrategy.md` mục 3.3 ("Demo ứng dụng end-to-end") để biến paper từ
"bảng benchmark từng component" thành "system-level contribution".

## Kịch bản

Thiết bị biên nhận 1 gói cập nhật firmware ("OTA blob") qua kênh không tin
cậy, gồm: (1) payload đã mã hoá AES-CTR, (2) chữ ký RSA của hash payload gốc
(ký offline tại server bằng khoá bí mật `d`, thiết bị không bao giờ giữ
`d`/`p`/`q`). Firmware trên RISSP:

1. **AES (CTR mode)** — giải mã payload nhận được.
2. **SHA3-256** — hash payload vừa giải mã, XOR-fold 8 từ digest (256-bit)
   thành 1 checksum 32-bit.
3. **RSA verify** — tính `sig^E mod N` (chỉ cần public key `(N,E)`, đúng mô
   hình verify chuẩn — xem `../RSA_Core/RSA.md`).
4. **So sánh**: kết quả RSA so với checksum SHA3 — khớp thì "cài đặt" (ghi
   payload + marker `0x600D600D` ra vùng debug `0xC0000000`), không khớp
   thì từ chối (marker `0xBAD0BAD0`).

**Vì sao chọn AES-CTR**: `AESEncrypt.v` chỉ có datapath **mã hoá thuần**
(SubBytes/ShiftRows/MixColumns theo chiều forward), không có datapath giải
mã (Inv-). CTR là stream cipher — giải mã = áp lại đúng phép mã hoá lên
ciphertext (XOR đối xứng với keystream `E(counter)`) — nên 1 lõi mã hoá duy
nhất dùng được cho **cả 2 chiều**, không cần thêm datapath giải mã riêng.
Đây là lựa chọn kiến trúc thật (không phải workaround miễn cưỡng) — nhiều hệ
OTA thực tế (vd ESP32 secure OTA) cũng chọn AES-CTR/GCM vì đúng lý do này.
Đáng đưa vào paper như 1 insight về area-efficiency của thiết kế.

## Register map dùng trong firmware (đã xác nhận từ chính RTL wrapper)

| Peripheral | Base | Nguồn xác nhận |
|---|---|---|
| AES | `0x40000000` | `AES_CORE/aes_wrapper.v` + `../firmware_Aes/firmware.md` |
| SHA3 | `0x44000000` | `D:\SE_RISSP_LIBRARY\SHA_3\SHA3_hardware_new_1_0\hdl\SHA3_hardware_new_slave_lite_v1_0_S01_AXI.v` |
| RSA | `0x48000000` | `F:\advance_topic\RSA_mark03\RSA_mark03_1_0\hdl\RSA_mark03_slave_lite_v1_0_S00_AXI.v` |
| Debug/kết quả | `0xC0000000` | `axi_bram_ctrl_0`, giống quy ước `firmware_Aes` |

Base address lấy trực tiếp từ `design_1.hwh` (hardware handoff) của
`SE-RISSP_AES_ULTRA`, không phải đoán — mỗi peripheral 1 dải `0x1_0000` hoặc
`0x4000`, không chồng lấn.

**SHA3 control register (offset `0x08`)**: bit0=`iReady`, bit1=`iLast`,
bits[4:2]=`iByte_num`. Message 16 byte = đúng 2 từ 64-bit tròn, không dư byte
lẻ → theo đúng giao thức đã xác nhận trong `SHA3_Core/SHA3.md`, cần gửi thêm
1 "từ rỗng" cuối với `iByte_num=0, iLast=1` để core tự chèn padding.

## Nguồn số liệu (mọi hằng số đều đã cross-verify bằng testbench RTL riêng)

| Đại lượng | Giá trị | Nguồn verify |
|---|---|---|
| AES key | `2b7e151628aed2a6abf7158809cf4f3c` | test vector FIPS-197, PASS trong `AES_CORE/tb_aes_core.v` |
| CTR initial counter | `f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff` | test vector NIST SP800-38A, PASS trong `AES_CORE/tb_aes_core.v` |
| Ciphertext OTA nhận được | `874d6191b620e3261bef6864990db6ce` | = CTR-encrypt(payload) — đã verify PASS trong `AES_CORE/tb_aes_core.v` (case CTR) |
| Payload sau giải mã | `6bc1bee22e409f96e93d7e117393172a` | plaintext NIST gốc — cùng giá trị đã PASS ở trên (CTR decrypt = CTR encrypt áp lại) |
| SHA3-256 digest của payload | `9b4811cba830098a1e003726088b9a5a91026b84faae5299568d77c3463a4fdc` | tính bằng `hashlib.sha3_256` Python, đối chiếu đúng cách `SHA3_Core/tb_sha3_core.v` đã dùng |
| Checksum XOR-fold | `0x5ee8b43f` | tự tính từ digest trên (XOR 8 từ 32-bit) |
| RSA `p, q` (chỉ dùng OFFLINE để ký, KHÔNG có trong firmware) | `65521, 65519` | — |
| RSA `N = p·q` | `4292870399` (`0xFFE000FF`) | — |
| RSA `E` | `65537` (`0x00010001`, chuẩn công nghiệp) | — |
| RSA `d` (chỉ server giữ) | `1475213633` | `pow(E,-1,totient)` |
| RSA `N_INV` | `0xC0E10101` | `-modinv(N,2^32) mod 2^32`, PASS trong `RSA_Core/tb_rsa_montgomery.v` |
| RSA `R2_MOD_N` | `0x403D0201` | `2^64 mod N`, PASS trong `RSA_Core/tb_rsa_montgomery.v` |
| Chữ ký `sig = fold^d mod N` | `1247873647` (`0x4A610A6F`) | ký offline bằng Python, verify ngược `sig^E mod N == fold` — khớp |

→ Toàn bộ chuỗi đã cross-check: mỗi khối RSA/SHA3/AES độc lập đã PASS
testbench RTL riêng của nó, và các giá trị nối giữa các khối (payload sau
AES → input SHA3 → checksum → so với RSA verify) đã tính tay bằng Python và
khớp nhau logic (`verify == fold`). **Firmware đã assemble/link thành công
và đối chiếu disassembly khớp 100% ý định thiết kế** (xem mục Build bên
dưới) — nhưng **chưa chạy mô phỏng toàn hệ (RISSP + cả 3 AXI slave cùng
lúc)** để có 1 lần PASS end-to-end thật trên RTL đầy đủ — xem mục "Việc còn
thiếu" cuối file.

## Build (đã làm, verify được)

Toolchain: `F:\xpack-riscv-none-elf-gcc-15.2.0-1\bin` (tìm thấy sẵn trên
máy, cùng bộ đã dùng để build `F:\advance_topic\RISSP\program.s` trước đó).

```
riscv-none-elf-as.exe -march=rv32i -mabi=ilp32 -o ota_demo.o ota_demo.s
riscv-none-elf-ld.exe -T link.ld -o ota_demo.elf ota_demo.o
riscv-none-elf-objcopy.exe -O binary ota_demo.elf ota_demo.bin
```
→ Assemble/link sạch, không lỗi. `objdump -d ota_demo.elf` đối chiếu tay
từng lệnh khớp đúng ý định (địa chỉ AXI, giá trị hằng số, nhánh rẽ, vòng lặp
poll) — đặc biệt bắt được và sửa 1 lỗi thật: giá trị `N` gõ tay ban đầu
(`0xffdd7fff`) sai so với `N=4292870399` thật (`0xFFE000FF`) — lỗi tính hex
tay, phát hiện bằng cách tính lại bằng Python trước khi chốt, không phải
đoán.

`ota_demo.bin` (448 byte = 112 lệnh, sạch, không có rác `.debug_frame` như
4 file `firmware_Aes` cũ — vì assemble bằng `as` thuần không qua `gcc -g`)
đã convert sang `ota_demo.coe` (đúng format Xilinx BMG:
`memory_initialization_radix=16;` + 112 dòng hex, dòng cuối kết thúc `;`),
sẵn sàng nạp vào Block Memory Generator giống hệt quy trình 4 file
`firmware_Aes`.

## Việc còn thiếu (chưa làm, nên làm tiếp trước khi đưa số liệu vào paper)

**Chưa có 1 lần mô phỏng RTL toàn hệ (CPU + cả 3 AXI slave cùng lúc) chạy
đúng file `ota_demo.coe` này và tự kiểm tra `0xC0000000` ra đúng marker
`0x600D600D`.** Lý do: cần dựng 1 testbench mới nối `rissp_top` (AXI master)
qua 1 bộ address-decode đơn giản (không phải IP Interconnect thật của
Xilinx, chỉ cần logic tổ hợp chọn slave theo `m_axi_awaddr[31:28]`/tương tự
cho mô phỏng) tới cả 3 AXI slave (`aes_axi_slave`, `SHA3_hardware_new_
slave_lite_v1_0_S01_AXI`, `RSA_mark03_slave_lite_v1_0_S00_AXI`) + 1 RAM đơn
giản đóng vai `0xC0000000`. Đây là hạ tầng test **chưa tồn tại** trong
project (mỗi core trước giờ chỉ test độc lập qua testbench riêng —
`tb_aes_core.v`, `tb_sha3_core.v`, `tb_rsa_montgomery.v` — chưa có bản
"toàn SoC"). Nên làm bước này trước khi đưa số liệu demo vào bản paper cuối
cùng, để có 1 lần PASS thật thay vì chỉ dựa vào suy luận từng khối độc lập +
đối chiếu tay bằng Python.
