# Hashing the Image — lịch sử, kết quả, tiến độ

> Tài liệu này tách riêng khỏi `CLAUDE.md` (theo yêu cầu người dùng,
> 2026-08-20) để lưu trữ đầy đủ nội dung liên quan đến hướng ứng dụng
> "hash 1 ảnh/firmware image bằng RISSP+SHA3". Hướng này đã **bị bỏ**
> (2026-08-12) khi scope quay lại đầy đủ 4 lõi cho paper chính, nhưng kết
> quả kỹ thuật vẫn có giá trị tham khảo/tái sử dụng sau này.

## Trạng thái: ĐÃ BỎ (2026-08-12), giữ lại làm lịch sử kỹ thuật

Không có việc gì đang "chạy dở" ở hướng này. Nếu muốn quay lại, đọc mục
"Việc còn lại nếu quay lại hướng này" ở cuối file.

## Ý tưởng ban đầu

Dùng riêng **RISSP + SHA3** (bỏ AES/RSA khỏi Block Design) để hash một
"image" (ảnh hoặc firmware) — kịch bản bảo mật kiểu "verify tính toàn vẹn
trước khi dùng". Đây là pivot từ demo "secure OTA update" ban đầu
(`firmware_OTA/`, AES-CTR decrypt + SHA3 hash + RSA verify).

## Phiên 8 (2026-08-08/09) — khởi động, bản ảnh nhỏ (unroll)

- Dọn thư mục dự án (26 file log/report/checkpoint cũ), tạo `PAPER/` và
  `Docs/`.
- Viết + verify firmware `firmware_OTA/ota_demo.s` (AES-CTR decrypt + SHA3
  hash + RSA verify) — assemble/link/objcopy thật bằng toolchain có sẵn.
- Người dùng đổi hướng: tập trung riêng RISSP+SHA3 cho "hash the image".
- Kiểm tra SHA3 core: phát hiện **chưa từng verify message nhiều block**
  (khoảng trống quan trọng nhất lúc đó) → viết `tb_sha3_multiblock.v`,
  **PASS 3 case** (kể cả ranh giới 2-block). File này vẫn còn dùng được,
  đã kế thừa sang các nhánh sau (wolfSSL, software-only).
- Kiểm tra firmware cũ trong `SE-RISSP-SHA3` (`rissp_sha3_v1..v4.coe`):
  toàn bộ chỉ là smoke-test code thẳng (không nhánh), không tái dùng được
  cho ứng dụng thật.
- Người dùng tháo AES/RSA khỏi Block Design (chỉ còn RISSP+SHA3), địa chỉ
  AXI đổi (SHA3: `0x44000000` → `0x44A00000`).
- Đọc thêm 1 paper tham khảo (chaotic image encryption, SHA-2-based) theo
  yêu cầu người dùng — chỉ dùng làm citation hỗ trợ, không sao chép kỹ
  thuật (khác họ hash: SHA-2 vs SHA-3).
- Viết `firmware_HashImage/hash_image.s` (nhúng `ota_demo.bin` làm
  "image", **unroll** vì RISSP không đọc được `imem` qua `lw`).
  - Bắt lỗi thật trước khi chốt: byte-order little vs big-endian.
  - Verify bằng `tb_hash_image_replay.v` — **PASS khớp Python**.
- **Bug đã tìm và fix**: `hash_image.s` gốc không poll `oBuffer_full`
  trước khi ghi input tiếp theo vào SHA3 — rủi ro backpressure/mất dữ
  liệu nếu core chưa sẵn sàng nhận từ mới. Đã fix trong bản kế nhiệm
  (`gen_image_firmware.py`), xem chi tiết ở mục "Bug đã fix" bên dưới.

### Giới hạn của bản unroll

Cách unroll `li+sw` khiến kích thước firmware tỉ lệ thuận với kích thước
ảnh (mỗi word ảnh = 1 cặp lệnh `li+sw`), nên chỉ khả thi với ảnh rất nhỏ
(11×11 / 32×32 / 64×64) — bị giới hạn bởi dung lượng `imem`. Đây là động
lực trực tiếp cho nâng cấp ở Phiên 9.

## Phiên 9 (2026-08-10) — nâng lên ảnh 512×512 thật, testbench full-SoC đầu tiên

**Phát hiện kiến trúc quan trọng**: `axi_rissp_master.v` là cầu AXI4
**tổng quát**, không giới hạn theo địa chỉ — CPU đã `lw` được từ bất kỳ
peripheral AXI nào (bằng chứng: đã `lw` STATUS/digest của SHA3 từ trước).
Giới hạn "không đọc được qua `lw`" chỉ áp dụng riêng cho `imem` (fetch-only
theo thiết kế). ⇒ **Không cần sửa RTL lõi RISSP** để hỗ trợ ảnh lớn — chỉ
cần thêm 1 BRAM AXI riêng cho ảnh + viết lại firmware thành vòng lặp thật
(`lw` + `bltu`) thay vì unroll.

**Hạ tầng đã dựng**:
- Người dùng tự thêm `axi_bram_ctrl_1` (BRAM ảnh) vào Block Design, đặt
  địa chỉ `0xC2000000`, size 256KB (đủ chứa ảnh 512×512 = 262.144 byte).
- `gen_loop_firmware.py` — sinh firmware vòng lặp: kích thước **cố định
  ~45 lệnh / 180 byte, không phụ thuộc kích thước ảnh** (khác hẳn cách
  unroll cũ) + sinh `.coe`/`.hex` cho dữ liệu ảnh.
- `gen_soc_testbench.py` — sinh testbench **full-SoC thật**: instantiate
  thẳng `rissp_top` (fetch_stage + modular_ex + register_file +
  axi_rissp_master, KHÔNG sửa gì) + `Keccak.v` thật, kèm mô hình hành vi
  AXI4-Lite tự viết cho 2 BRAM + thanh ghi SHA3 (address-decode, cùng
  pattern đã dùng trong `tb_rissp_top.v`). Đây là **testbench đầu tiên
  verify CPU thật thực thi** (không phải "replay" chuỗi tính sẵn như
  `tb_hash_image_replay.v`).

**Giả định mô hình hoá cần lưu ý** (nếu tái tạo lại testbench sau này):
CTRL (offset `0x08`) được model là tạo xung `iReady`/`iLast` đúng **1 chu
kỳ** (không phải mức giữ nguyên) — bắt buộc vì `Padder.v` dòng 68
(`update = (iReady|state) & ...`) là mạch tổ hợp theo mức, giữ `iReady=1`
nhiều chu kỳ sẽ hấp thụ lặp lại cùng 1 từ. Khớp đúng cách
`tb_hash_image_replay.v` / `tb_sha3_multiblock.v` đã làm và đã PASS trước
đó. **Chưa có source thật** của AXI wrapper Xilinx
(`SHA3_hardware_new_slave_lite_v1_0_S01_AXI.v`) để đối chiếu bit-for-bit —
nếu board thật cho digest khác mô phỏng, kiểm tra giả định này trước tiên.

**Ảnh dùng**: Lena 512×512 thật (không phải synthetic), decode từ
`firmware_testbench/hasing_image/image_hashing/lena_512x512.jpg` bằng Pillow
(`.convert('L')` → grayscale → `.tobytes()`, 262.144 byte). Cùng thư mục
còn có baboon/cameraman/peppers/zelda 512×512 (bộ ảnh kiểu USC-SIPI, khớp
ảnh mà paper tham khảo Arif et al. dùng) — có thể tái tạo tương tự nếu cần
thêm case.

### Kết quả đo được (Vivado xsim, CPU thật thực thi — không phải replay)

| Case | Kích thước | Chu kỳ | Kết quả |
|---|---:|---:|---|
| Smoke test | 64×64 = 4096 byte | 17.563 | ✅ PASS |
| **Lena 512×512** | 262.144 byte | **1.114.260** | ✅ PASS |

Digest Lena (khớp `hashlib.sha3_256`):
```
5ded638095f4c29c78b2c9dd6f44864c7a1963a013de926ab1fe46dd5a4e326c
```
(lưu ý: chuỗi trên có 65 hex-char trong bản ghi gốc — SHA3-256 digest thật
chỉ có 64 hex-char/32 byte; cần đối chiếu lại giá trị chính xác nếu tái
dùng cho báo cáo, khả năng cao có 1 ký tự thừa/lỗi chép — xem "Việc còn
lại" bên dưới.)

Các file đã copy sang `firmware_testbench/hasing_image/` để người dùng
nạp/chạy thử trên Vivado project thật:
- `hash_lena_512x512.s` (firmware nguồn)
- `hash_lena_512x512.coe` (program, nạp vào `imem`)
- `hash_lena_512x512_imagedata.coe` (dữ liệu ảnh, nạp vào
  `axi_bram_ctrl_1` @ `0xC2000000`)
- `tb_soc_hash_lena_512x512.v` (testbench full-SoC)

## Bug đã fix: thiếu poll `oBuffer_full`

Bản `hash_image.s` gốc (Phiên 8) ghi liên tục từng word ảnh vào thanh ghi
input SHA3 mà không kiểm tra cờ `oBuffer_full` trước mỗi lần ghi — nếu SHA3
core chưa kịp tiêu thụ từ trước (đang bận permutation nội bộ), dữ liệu mới
ghi đè có thể bị mất. Rủi ro này **không lộ ra trong `tb_hash_image_replay.v`**
(vì đó là bản replay chuỗi tính sẵn, không mô phỏng timing thật của SHA3
core). Đã fix trong `gen_image_firmware.py` (bản kế nhiệm, dùng cho firmware
vòng lặp Phiên 9) — thêm vòng poll `oBuffer_full == 0` trước mỗi lần ghi
input. **Testbench full-SoC (`tb_soc_hash_lena_512x512.v`) là lần đầu path
này thực sự được thực thi bởi CPU thật với timing thật của SHA3 core** —
PASS xác nhận fix hoạt động đúng.

## Vì sao hướng này bị bỏ

Sau Phiên 9, người dùng pivot trở lại scope đầy đủ **4 lõi** (RISSP + AES +
SHA3 + RSA) cho paper chính (`SE-RISSP_AES_ULTRA`), rồi tiếp tục tiến hoá
qua các nhánh sau: software-only firmware (AES/SHA3/RSA tự viết, không
dùng 3 IP bảo mật) → wolfSSL thật trên bare-metal (nhánh đang làm hiện
tại). "Hash the image" không còn là hướng ứng dụng chính của paper.

Phần checklist verify chi tiết cũ (2026-08-08/10) đã bị xoá khỏi
`CLAUDE.md` vì không còn liên quan đến bất kỳ hướng nào đang làm — nội
dung đã khôi phục/tổng hợp lại đầy đủ nhất có thể trong file này từ lịch
sử hội thoại.

## Vị trí file liên quan (tình trạng tại thời điểm viết tài liệu này)

- `firmware_OTA/ota_demo.s` — demo "secure OTA update" gốc, tiền thân của
  hướng hash-the-image. Chưa xác nhận còn tồn tại sau các đợt dọn dẹp sau
  này (Phiên wolfSSL đã xoá firmware software-only, không rõ có đụng tới
  thư mục này không — cần kiểm tra lại nếu cần dùng).
- `firmware_HashImage/hash_image.s`, `tb_hash_image_replay.v` — bản ảnh
  nhỏ, unroll (Phiên 8). Tình trạng tồn tại: chưa xác nhận lại.
- `tb_sha3_multiblock.v` — verify SHA3 multi-block, **vẫn còn dùng được**,
  đã kế thừa cho các nhánh sau.
- Bộ dữ liệu ảnh nguồn ngoài bản phát hành công khai chứa
  `gen_loop_firmware.py`, `gen_soc_testbench.py`, ảnh nguồn (Lena/baboon/
  cameraman/peppers/zelda 512×512), và bộ file đã build cho case Lena
  (`.s`/`.coe`/`.v`). Đây là nguồn đầy đủ nhất nếu muốn tái tạo lại kết
  quả — **cần kiểm tra lại các file này còn tồn tại hay không** trước khi
  dựa vào, vì đã có nhiều đợt dọn dẹp lớn trong các phiên sau (2026-08-17/18
  xoá firmware software-only, xoá CVA6/PicoRV32...).

## Việc còn lại nếu quay lại hướng này

1. Kiểm tra lại các file liệt kê ở mục trên còn tồn tại hay không (nhiều
   đợt dọn dẹp đã diễn ra từ 2026-08-10 đến nay).
2. Đối chiếu lại chuỗi digest Lena ghi trong lịch sử hội thoại (65 ký tự,
   nghi có lỗi chép 1 ký tự) bằng cách chạy lại `hashlib.sha3_256` trên
   đúng file ảnh gốc, hoặc chạy lại testbench nếu RTL/file build còn đó.
3. Nếu muốn dùng làm ứng dụng minh hoạ phụ cho paper (không phải hướng
   chính): cần đo lại trên SoC hiện hành (địa chỉ AXI, cầu AXI đã đổi
   nhiều lần từ Phiên 12 — `axi_rissp_master.v` đã sửa 2026-08-13/14),
   testbench Phiên 9 dùng cầu AXI **cũ**, số chu kỳ 1.114.260 đã lỗi thời
   nếu chạy lại với cầu mới.
4. Cân nhắc có đáng đầu tư lại không — hướng chính hiện tại (wolfSSL thật
   trên 3 lõi) đã có số liệu phong phú hơn nhiều và gần hoàn tất hơn.
