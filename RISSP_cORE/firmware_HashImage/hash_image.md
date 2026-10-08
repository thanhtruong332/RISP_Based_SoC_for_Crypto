# firmware_HashImage — Firmware "Hash the Image" cho SoC RISSP+SHA3

Firmware cho hướng paper đã chốt: SoC **chỉ RISSP+SHA3** (đã tháo AES/RSA khỏi
`SE-RISSP_AES_ULTRA` để còn lại `SE-RISSP-SHA3`-class). Firmware này tính
**SHA3-256** của 1 "image" nhúng thẳng trong chương trình, ghi digest ra vùng
debug `0xC0000000`.

## "Image" dùng trong demo

Dùng lại **`firmware_OTA/ota_demo.bin`** (448 byte, đã build ở phiên trước)
làm "image" — không phải ảnh chụp, mà là chính 1 firmware RV32I đã compile
thật. Khớp đúng thuật ngữ "firmware image"/"boot image" trong tài liệu
secure-boot (xem lý do chọn trong hội thoại trước), tránh vấn đề bản quyền
ảnh, và kích thước (448 byte, tràn 4 block SHA3) nằm trong vùng đã verify
RTL multi-block thật (xem `SHA3_Core/SHA3.md`).

## Vì sao là unroll, không phải vòng lặp

`RISSP` chỉ đọc/ghi qua AXI (`axi_rissp_master.v`) tới các peripheral/BRAM
ngoài — **không có đường dữ liệu nối `imem` với `LW`/`SW`** (`fetch_stage.v`
chỉ dùng `imem` để fetch lệnh). Vì vậy không thể viết vòng lặp đọc tuần tự
dữ liệu ảnh từ `imem` — mỗi từ 8-byte của "image" phải nhúng thành 1 cặp
`li`+`sw` cố định trong chương trình (56 cặp cho 448 byte). `imem` của SoC
sâu 8192 từ = 32KB (xem `blk_mem_gen_0_0.xci`), firmware này chỉ tốn 417 từ
(1668 byte) — dư sức chứa.

## Địa chỉ dùng trong firmware (theo đúng Address Editor SoC RISSP+SHA3)

| Peripheral | Base | Ghi chú |
|---|---|---|
| SHA3 | **`0x44A00000`** | Đã đổi so với bản `SE-RISSP_AES_ULTRA` cũ (`0x44000000`) — Vivado tự gán lại địa chỉ sau khi thu gọn AXI Interconnect còn 2 master. **Nếu Address Editor đổi lại lần nữa (validate lại), phải cập nhật hằng số này trong `hash_image.s` và build lại.** |
| BRAM (debug/kết quả) | `0xC0000000` | Không đổi, range 8KB. |

## Bug thật đã bắt được trước khi chốt — thứ tự byte trong từ 64-bit

Lần đầu sinh firmware, đọc byte từ `ota_demo.bin` theo **little-endian** (vì
đó là cách đọc lại đúng mã lệnh RISC-V gốc) rồi nhồi thẳng vào `data_hi`/
`data_lo` của SHA3 — **sai**, vì giao thức SHA3 (`SHA3_Core/SHA3.md`) yêu
cầu byte đầu tiên của message nằm ở `iData[63:56]` (tức bit cao nhất của
`data_hi`) — đây là quy ước **big-endian theo từng chunk 4-byte**, ngược
hẳn với little-endian. Tự phát hiện bằng cách tính tay ví dụ cụ thể
(`0x6bc1bee2` → byte đầu `0x6b` phải nằm ở bit[31:24]) trước khi build,
không đợi simulation báo sai. Đã sửa: nhóm big-endian đúng chuẩn, giữ
nguyên ground-truth Python (`hashlib.sha3_256` trên byte thứ tự file gốc
0..447 — thứ tự NÀY không đổi, chỉ đổi cách nạp vào thanh ghi cho đúng giao
thức phần cứng).

## Verify — không tin suy luận tay, chạy RTL thật

Viết `tb_hash_image_replay.v`: drive thẳng module `Keccak` bằng **đúng
chuỗi 56 từ 64-bit** mà `hash_image.s` sẽ ghi (kể cả từ rỗng kết thúc), đối
chiếu với `hashlib.sha3_256(ota_demo.bin)` tính bằng Python:

```
"F:\vivado\Vivado\2024.2\bin\xvlog.bat" rconst2in1.v round2in1.v F_permutation.v Padder1.v Padder.v Keccak.v tb_hash_image_replay.v
"F:\vivado\Vivado\2024.2\bin\xelab.bat" tb_hash_image_replay -s tb_hi_snap
"F:\vivado\Vivado\2024.2\bin\xsim.bat" tb_hi_snap -R
```

```
[PASS] hash_image replay oData=fdfdfb15c0436e29646bf1e3d4872826ccb099ecaaf67b7dbb415620e0f7cac9 sau 37 chu ky
HASH_IMAGE FIRMWARE SEQUENCE VERIFIED CORRECT
```

Digest kỳ vọng (`hashlib.sha3_256` trên 448 byte `ota_demo.bin` gốc):
```
fdfdfb15c0436e29646bf1e3d4872826ccb099ecaaf67b7dbb415620e0f7cac9
```

## Build (đã làm)

```
riscv-none-elf-as.exe  -march=rv32i -mabi=ilp32 -o hash_image.o hash_image.s
riscv-none-elf-ld.exe  -T link.ld -o hash_image.elf hash_image.o
riscv-none-elf-objcopy.exe -O binary hash_image.elf hash_image.bin
```
→ `hash_image.bin` (1668 byte, 417 từ) → convert `hash_image.coe` (Xilinx
BMG format, khớp `firmware_Aes`/`firmware_OTA`).

## Việc còn lại trong Vivado

1. `blk_mem_gen_0` → đổi `Coe File` sang `hash_image.coe` → Generate Output
   Products.
2. Validate Design lại, kiểm tra Address Editor **vẫn đúng `0x44A00000`**
   cho SHA3 — nếu khác, cập nhật `hash_image.s` và build lại (mục trên).
3. Run Synthesis → Run Implementation **từ đầu** (đã đổi topology, xoá
   AES/RSA, không dùng lại kết quả cũ được).
4. Sau khi có bitstream/kết quả mô phỏng SoC đầy đủ: đọc 8 từ tại
   `0xC0000000-0xC000001C` → phải khớp đúng digest ở trên, cộng `0xC0000020`
   phải là marker `0x600D600D`.

## Việc chưa làm — cần verify tiếp nếu muốn số liệu "chạy thật" cho paper

Giống lưu ý đã ghi ở `firmware_OTA/OTA.md`: `tb_hash_image_replay.v` chỉ
verify **đúng giao thức/dữ liệu** (drive thẳng module Keccak), **chưa** verify
CPU RISSP thật thực thi đúng 417 lệnh này qua AXI thật (chưa có testbench
toàn SoC RISSP+AXI+SHA3). Về lý thuyết không có rủi ro thêm (RISSP đã verify
LOAD/STORE/branch độc lập từ trước, AXI wrapper SHA3 đã verify riêng) nhưng
nên build+run trên Vivado thật (hoặc dựng testbench toàn SoC) trước khi coi
đây là số liệu cuối cùng đưa vào paper.
