# SHA3_Core — Kiểm tra & xác nhận

Lõi Keccak/SHA3-256 phần cứng, copy từ
`D:\SE_RISSP_LIBRARY\SHA_3\SHA3_hardware_new_1_0\src` (bản gốc mã nguồn mở
của Homer Hsing, Apache-2.0, xem header từng file). Kiểm tra theo đúng
phương pháp đã dùng cho `AES_CORE`: đọc code + **mô phỏng thực tế bằng
Vivado xsim**, đối chiếu với digest tính bởi `hashlib.sha3_256` của Python
(không dùng test vector nhớ từ trí nhớ — bài học rút ra từ vụ gõ thiếu 1 ký
tự hex khi audit AES trước đó).

## Cấu trúc file

- `Keccak.v` — module top: ghép `Padder` + `F_permutation`, đảo byte-order
  input/output (chuyển giữa quy ước "đọc tự nhiên" bên ngoài và quy ước
  little-endian nội bộ của Keccak lane).
- `Padder.v` + `Padder1.v` (`InEnd`) — bộ đệm hấp thụ (absorb) 1088-bit
  (17 word × 64-bit, đúng rate của SHA3-256), tự động chèn padding
  `pad10*1` + domain separator `0x06` khi gặp `iLast`.
- `F_permutation.v` — FSM chạy Keccak-f[1600] (24 round), gọi `round2in1` +
  `rconst2in1`.
- `round2in1.v` — 1 round Keccak-f: theta → rho → pi → chi → iota, xử lý
  toàn bộ state 1600-bit tổ hợp (không có thanh ghi trung gian giữa các
  bước trong 1 round).
- `rconst2in1.v` — round constant (dạng "2-in-1", chọn 1 trong 2 bảng theo
  bit chẵn/lẻ của bộ đếm round).
- `tb_sha3_core.v` — **testbench mới thêm**, drive thẳng module `Keccak`
  (không qua AXI), 3 test case đối chiếu `hashlib.sha3_256`.

## Tham số dùng (khớp với AXI wrapper thật)

Theo `SHA3_hardware_new_slave_lite_v1_0_S01_AXI.v` (ngoài phạm vi thư mục
này nhưng đã đọc để xác nhận cách core được dùng thật):
`Keccak #(.b(1600), .nr(24), .Length(4), .lbits(3))` → `Length=4` nghĩa là
**SHA3-256** (output = 4×64 = 256 bit), `Block = b/64 - 2*Length = 17` word
= đúng rate 1088-bit của SHA3-256 theo chuẩn FIPS-202.

Giao thức stream (từ comment gốc + đọc code):
- Mỗi chu kỳ `iReady=1`, 1 word 64-bit (`iData`) được hấp thụ (byte đầu ở
  `iData[63:56]`, theo đúng thứ tự đọc tự nhiên của message).
- Chunk cuối cùng: `iLast=1`, `iByte_num` = số byte hợp lệ còn lại trong
  `iData` (0-7; nếu message vừa hết ở ranh giới 8-byte thì trình bày thêm
  1 word "rỗng" `iByte_num=0` để core tự chèn padding).
- Sau `iLast`, module **tự động** tiếp tục đệm zero-fill + bit kết thúc
  `0x80` cho đủ 17 word — không cần user can thiệp thêm.
- `oReady=1` khi digest sẵn sàng ở `oData` (256-bit, `Length*64`).

## Bug tìm thấy & sửa

### 1. Thiếu `` `timescale`` ở cả 6 file — bug thật, chặn mô phỏng
Giống hệt tình trạng gặp ở `AES_CORE` (và ở `RISSP_CORE` trước đó): không
file nào trong 6 file gốc có `` `timescale``, khiến `xelab` báo lỗi cứng:
```
ERROR: [XSIM 43-4099] "Keccak.v" Line 21. Module Keccak_default doesn't
have a timescale but at least one module in design has a timescale.
```
→ Đã thêm `` `timescale 1ns / 1ps`` vào đầu cả 6 file, không đổi logic nào.

### 2. Bug trong **testbench tự viết** (không phải RTL) — double-shift do pulse tràn giữa 2 lần gọi task
Lần chạy đầu: test digest rỗng (`""`) và `"abc"` (chỉ 1 word) PASS ngay,
nhưng test message 56-byte (7 word thật + 1 word padding) FAIL. Debug bằng
cách in `dut.padder_.i` (thanh ghi đếm shift dạng thermometer-code) sau mỗi
lần gọi task `drive_chunk` thì phát hiện: mỗi word bị **shift vào bộ đệm 2
lần** thay vì 1 lần — do task chỉ set `iReady=1` rồi chờ 1 negedge, KHÔNG
hạ `iReady` xuống trước khi trả về, nên trong khoảng hở giữa lần gọi task
này và lần gọi kế tiếp (nơi giá trị mới chưa được gán) vẫn còn 1 cạnh
dương nữa lấy mẫu **lại đúng dữ liệu cũ**. Vì `EMPTY`/`ABC` chỉ gọi task 1
lần nên không bao giờ rơi vào khoảng hở này — đó là lý do 2 case đơn-word
PASS ngay từ đầu trong khi case nhiều-word thì sai. Đã sửa: `drive_chunk`
tự hạ `iReady`/`iLast` về 0 ngay trong task trước khi trả về. Sau khi sửa,
cả 3 case PASS.

Không phát hiện bug thuật toán nào trong RTL (`Keccak.v` và các module con)
— toàn bộ sai lệch nằm ở cách drive testbench, đã sửa và xác nhận lại.

## Kết quả mô phỏng — đối chiếu `hashlib.sha3_256`

```
"F:\vivado\Vivado\2024.2\bin\xvlog.bat" rconst2in1.v round2in1.v F_permutation.v Padder1.v Padder.v Keccak.v tb_sha3_core.v
"F:\vivado\Vivado\2024.2\bin\xelab.bat" tb_sha3_core -s tb_sha3_snap
"F:\vivado\Vivado\2024.2\bin\xsim.bat" tb_sha3_snap -R
```

3 test case, phủ 3 nhánh khác nhau của padding (rỗng / còn dư byte lẻ /
đúng 1 block-boundary cần thêm word đệm), digest kỳ vọng lấy từ
`python -c "import hashlib; hashlib.sha3_256(msg).hexdigest()"`:

| Message | Digest kỳ vọng (Python `hashlib.sha3_256`) | Kết quả RTL |
|---|---|---|
| `""` (0 byte) | `a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a` | **PASS** |
| `"abc"` (3 byte) | `3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532` | **PASS** |
| chuỗi 56 byte (`"abcdbcde...nopq"`, 7 word tròn) | `41c0dba2a9d6240849100376a8235e2c82e1b9998a999e21db32dd97496d3376` | **PASS** |

```
[PASS] EMPTY  oData=a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a
[PASS] ABC   oData=3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532
[PASS] MSG56  oData=41c0dba2a9d6240849100376a8235e2c82e1b9998a999e21db32dd97496d3376
ALL 3 SHA3-256 TEST VECTORS PASS - khop hashlib.sha3_256
```

→ **Kết luận: lõi SHA3-256 (`Keccak.v` + toàn bộ module con) đúng chuẩn
FIPS-202**, đã phủ cả 3 nhánh padding (message rỗng, message có phần dư
< 8 byte, message tròn bội số 8-byte cần thêm word đệm) và đường hấp thụ
nhiều word liên tiếp trong 1 block.

## Verify multi-block (2026-08-08) — khoảng trống quan trọng nhất đã lấp

3 test case PASS ở trên (rỗng, `"abc"`, 56-byte) **đều nằm trong 1 block**
(rate SHA3-256 = 1088-bit = 136 byte = 17 từ 64-bit) — **chưa từng kiểm tra**
message dài hơn 1 block, trong khi đây là trường hợp **bắt buộc xảy ra** với
mọi ứng dụng "hash 1 file/image" thật (gần như chắc chắn > 136 byte).

Đọc kỹ `Padder.v`: buffer 17 từ, `oBuffer_full` lên 1 khi đầy, và
**`update` (chốt nhận từ mới) bị GATE OFF hoàn toàn khi buffer đầy** — nhận
dữ liệu mới trở lại chỉ sau khi `F_permutation` xử lý xong block hiện tại và
báo `f_oAck`. Đây là cơ chế backpressure đúng đắn cho multi-block, **nhưng
im lặng bỏ qua dữ liệu** nếu bên ngoài (firmware) cứ ghi từ mới mà không
kiểm tra `oBuffer_full` trước — không có cờ lỗi nào cảnh báo mất dữ liệu.

Viết `tb_sha3_multiblock.v` (testbench mới, mô phỏng đúng hành vi firmware
PHẢI làm: kiểm tra `oBuffer_full` trước mỗi lần ghi từ), test 3 case:

| Case | Độ dài | Đặc điểm | Kết quả |
|---|---:|---|---|
| `300byte_3block` | 300 byte | tràn 3 block, không tròn ranh giới | **PASS** (41 chu kỳ) |
| `272byte_2block_boundary` | 272 byte | đúng `2×136` — cần thêm block 3 toàn padding | **PASS** (47 chu kỳ) |
| `137byte_justover1block` | 137 byte | vừa qua 1 block đúng 1 byte | **PASS** (47 chu kỳ) |

Cả 3 khớp `hashlib.sha3_256` Python, kể cả case ranh giới 2-block (trường
hợp dễ lộ bug padding nhất, tương tự bug ranh giới 1-block `MSG56` đã bắt
được trong lần audit trước).

→ **Kết luận: core SHA3 (Keccak.v + Padder + F_permutation) xử lý đúng
message nhiều block**, đủ tiêu chuẩn RTL để làm nền cho ứng dụng "hash toàn
bộ 1 image/firmware" — miễn là **firmware phải poll `oBuffer_full` (STATUS
bit1, offset `0x0C`) trước MỖI lần ghi từ mới** khi message > 136 byte, nếu
không sẽ mất dữ liệu âm thầm (không lỗi, không treo — chỉ ra hash sai).

### Firmware hiện có KHÔNG dùng được cho "hash image" — cần viết mới

Đã kiểm tra 5 file firmware đã tồn tại trong project SoC
`SE-RISSP-SHA3` (`rissp_sha3.coe` gốc + `_v2/_v3/_v4.coe`, 157-516 từ lệnh):
disassemble ngược bằng `objdump -b binary -m riscv:rv32` thì **không có bất
kỳ lệnh nhánh nào** (`beq/bne/blt/bge/jal`) trong toàn bộ 5 file — nghĩa là
tất cả đều là code thẳng (straight-line), hash 1-2 từ dữ liệu hardcode cố
định (`0x1122334455667788...`), chờ bằng khối NOP cố định (không poll
STATUS) — **đúng dạng smoke-test tay cho SHA3 core, không phải ứng dụng
"hash N byte đọc từ bộ nhớ"**. Không tái sử dụng được cho hướng "hash the
image" — cần viết firmware mới có **vòng lặp** (đọc tuần tự từ vùng nhớ
`0xC0000000`, ghép cặp 32-bit thành từ 64-bit, poll `oBuffer_full` trước mỗi
lần ghi, poll `oReady` ở cuối).

### Giới hạn quy mô cần biết trước khi viết paper

Vùng nhớ dữ liệu `axi_bram_ctrl_0` (nơi "image" phải nằm sẵn trước khi
firmware chạy) chỉ rộng **8KB** (`0xC0000000-0xC0001FFF`, xem
`design_1.hwh`). Đủ cho demo/proof-of-concept trong paper (tương tự cách
RSA `WIDTH=32` đã được đóng khung là "quy mô nghiên cứu, không phải sản
phẩm thương mại" ở `RSA_Core/RSA.md`), nhưng cần ghi rõ giới hạn này —
không claim hash được firmware image cỡ thật (hàng trăm KB-MB) nếu chưa mở
rộng vùng nhớ.

## Ghi chú tích hợp SoC (chưa kiểm tra ở audit này)

Thư mục này chỉ chứa lõi thuật toán thuần (`src/`), **không** bao gồm AXI
wrapper (`SHA3_hardware_new_slave_lite_v1_0_S01_AXI.v`, nằm ở thư mục
`hdl/` bên nguồn, không nằm trong phạm vi copy lần này). Đã đọc file đó
để xác nhận tham số hoá (`Length=4`, `lbits=3`) và cách map thanh ghi
(offset `0x00/0x04`=data hi/lo, `0x08`=control iReady/iLast/iByte_num,
`0x0C`=status, `0x10-0x2C`=8 word digest) — nếu sau này tích hợp vào RISSP
SoC theo đúng mô hình AES, nên copy luôn 2 file `hdl/` đó vào
`SHA3_Core/` để có bản đầy đủ giống `AES_CORE` (có cả core lẫn AXI
wrapper).
