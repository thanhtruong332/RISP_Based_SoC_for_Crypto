# AES_CORE — Kiểm tra & xác nhận

Tài liệu này ghi lại việc kiểm tra `AES_CORE` (lõi AES-128 mã hoá, gắn vào
RISSP core cũ qua AXI4-Lite, nạp firmware bằng Block Memory Generator) —
kiểm tra bằng cách **mô phỏng thực tế** (Vivado xsim), không chỉ đọc code.

## Cấu trúc file

- `AESEncrypt.v` — FSM chính (IDLE→WORK×10 round→DONE), xử lý input/output
  khác nhau theo `mode_sel` (00=ECB, 01=CBC, 10=CTR, 11=CFB).
- `SubBytes.v`, `ShiftRows.v`, `MixColumns.v`, `AddRoundKey.v` — 4 phép biến
  đổi chuẩn AES mỗi round.
- `SubTable.v` — bảng S-box (256 giá trị, case-based lookup).
- `KeyExpansionRound.v` — chứa **2 module**: `KeyExpansionRound` (1 round
  key schedule) và `KeyExpansion` (lặp 10 lần, sinh đủ 11 round key = 1408
  bit `keys_out`).
- `aes_wrapper.v` — memory-map hoá AES core (control/status/data/key/iv
  register), tự động cập nhật IV cho block kế tiếp khi `done_tick`.
- `aes_axi_slave.v` — bridge AXI4-Lite slave → `aes_wrapper` (decoupled
  handshake, chống treo bus).
- `tb_aes_core.v` — **testbench mới thêm**, mô phỏng độc lập `AESEncrypt` +
  `KeyExpansion` (không qua CPU/AXI) với đúng key/plaintext/IV mà 4 file
  firmware nạp, đối chiếu với test vector chuẩn NIST SP800-38A Appendix F.

## Memory map (`aes_wrapper.v`)

| Offset | Thanh ghi | Ghi chú |
|---|---|---|
| 0x00–0x0C | `REG_DATA_IN_0..3` | Plaintext 128-bit (MSB tại 0x00) |
| 0x10–0x1C | `REG_KEY_0..3` | Key 128-bit |
| 0x20 | `REG_CONTROL` | bit0=start, bit[2:1]=mode (00 ECB,01 CBC,10 CTR,11 CFB) |
| 0x24 | `REG_STATUS` | bit0=done (latched) |
| 0x30–0x3C | `REG_DATA_OUT_0..3` | Ciphertext 128-bit |
| 0x40–0x4C | `REG_IV_0..3` | IV / initial counter 128-bit |

Base address AXI của AES peripheral trong 4 file firmware = `0x40000000`
(nạp vào `x11` bằng `LUI x11,0x40000` ở đầu chương trình).

## Cách 4 mode được xử lý phần cứng (đã xác nhận đúng)

Điểm quan trọng nhất khi audit: trong `aes_wrapper.v`, đoạn XOR
plaintext/IV theo mode ở **wrapper level** đã bị **comment out có chủ đích**
(dòng 114-116, 133-136):
```verilog
//wire [127:0] data_to_core = (core_mode_sel==2'b10||...) ? ILA_IV : ...
wire [127:0] data_to_core = ILA_DATA_IN;   // luôn đưa thẳng plaintext
...
//assign final_ciphertext = (core_mode_sel==2'b10||...) ? (ecb_ciphertext^ILA_DATA_IN) : ...
assign final_ciphertext = ecb_ciphertext;  // lấy thẳng output core
```
Đây **không phải bug** — logic XOR theo mode đã được chuyển hẳn vào bên
trong `AESEncrypt.v` (IDLE branch chọn input, DONE branch chọn output theo
`mode_sel`), nếu wrapper làm thêm XOR nữa sẽ bị **XOR 2 lần** và ra sai. Đã
xác nhận `AESEncrypt.v` tự làm đúng phần này:

```verilog
// IDLE — chọn input trước khi vào 10 round:
CBC      : state_reg = (data_in ^ iv_in) ^ key0      // C = E(P^IV)
CTR/CFB  : state_reg = iv_in ^ key0                  // mã hoá counter/IV, CHƯA đụng data_in
ECB      : state_reg = data_in ^ key0

// DONE — chọn output sau 10 round:
CTR/CFB  : data_out = state_reg ^ data_in            // keystream ^ plaintext
ECB/CBC  : data_out = state_reg                      // lấy thẳng kết quả AES
```
Đối chiếu định nghĩa chuẩn NIST SP800-38A: **cả 4 công thức đều đúng**.

## Đã sửa: thiếu `` `timescale`` ở 7 file (bug thật, chặn mô phỏng)

`SubTable.v`, `SubBytes.v`, `ShiftRows.v`, `MixColumns.v`, `AddRoundKey.v`,
`KeyExpansionRound.v`, `AESEncrypt.v` gốc **không có** `` `timescale`` —
cùng loại lỗi đã gặp và sửa trước đây ở `RISSP_CORE` (xem `CLAUDE.md`).
Hậu quả: `xelab` báo lỗi cứng (không chỉ warning) và **không dựng được
snapshot mô phỏng**:
```
ERROR: [XSIM 43-4099] "KeyExpansionRound.v" Line 54. Module
KeyExpansion_default doesn't have a timescale but at least one module
in design has a timescale.
```
→ Đã thêm `` `timescale 1ns / 1ps`` vào đầu 7 file trên. Không đổi logic
nào khác. (`aes_wrapper.v`, `aes_axi_slave.v` vốn đã có sẵn `` `timescale``.)

## Kết quả mô phỏng — đối chiếu NIST SP800-38A Appendix F

Testbench `tb_aes_core.v` dùng **đúng** key/plaintext/IV mà cả 4 file
firmware nạp vào AES peripheral (key chuẩn FIPS-197:
`2b7e151628aed2a6abf7158809cf4f3c`, plaintext block1 chuẩn NIST:
`6bc1bee22e409f96e93d7e117393172a`), rồi so `data_out` với ciphertext chuẩn
đã công bố:

```
"F:\vivado\Vivado\2024.2\bin\xvlog.bat" SubTable.v SubBytes.v ShiftRows.v MixColumns.v AddRoundKey.v KeyExpansionRound.v AESEncrypt.v tb_aes_core.v
"F:\vivado\Vivado\2024.2\bin\xelab.bat" tb_aes_core -s tb_aes_snap
"F:\vivado\Vivado\2024.2\bin\xsim.bat" tb_aes_snap -R
```

Kết quả (chạy thật, không phải suy đoán):
```
[PASS] ECB   data_out=3ad77bb40d7a3660a89ecaf32466ef97
[PASS] CBC   data_out=7649abac8119b246cee98e9b12e9197d
[PASS] CFB   data_out=3b3fd92eb72dad20333449f8e83cfb4a
[PASS] CTR   data_out=874d6191b620e3261bef6864990db6ce
ALL 4 MODES PASS - khop NIST SP800-38A test vector
```

Đã xác nhận từng khối riêng lẻ trước khi tin kết quả cuối:
- `KeyExpansion`: round-key 1 = `a0fafe1788542cb123a339392a6c7605`, round-key
  10 = `d014f9a8c9ee2589e13f0cc8b6630ca6` — khớp chính xác key schedule
  chuẩn FIPS-197 cho key test vector này.
- `SubTable` (S-box): spot-check `0x00→0x63`, `0x01→0x7c`, `0xff→0x16` —
  khớp bảng S-box chuẩn AES.
- `ShiftRows`, `MixColumns`, `AddRoundKey`: đối chiếu cấu trúc — đúng công
  thức chuẩn (ShiftRows dịch trái 0/1/2/3 theo đúng hàng; MixColumns dùng
  đúng ma trận nhân GF(2^8) `{02,03,01,01;...}`; AddRoundKey chỉ là XOR).

→ **Kết luận: lõi AES-128 đúng cho cả 4 mode ECB/CBC/CTR/CFB**, không phát
hiện bug thuật toán nào trong `AES_CORE`. Bug duy nhất tìm thấy trong quá
trình audit là ở **testbench tự viết** (gõ thiếu 1 ký tự hex cuối của
plaintext test) — đã sửa, không liên quan RTL thật.

## Độ trễ FSM (đối chiếu với delay NOP trong firmware)

Đo trực tiếp từ mô phỏng: từ cạnh xung nhịp `enable` được core lấy mẫu
(round chuyển 0→1) đến khi `done_tick=1`, mất **11 chu kỳ clock** (10 round
+ 1 chu kỳ DONE latch). Cộng thêm ~4-5 chu kỳ cho handshake AXI4-Lite
(AWVALID/WVALID → BVALID) và latch `start_pulse` ở `aes_wrapper`, tổng thời
gian từ lúc CPU ghi xong `REG_CONTROL` đến khi `REG_DATA_OUT` sẵn sàng ước
tính **~15-17 chu kỳ clock**. 4 file firmware đều dùng **60 lệnh NOP** làm
delay cố định trước khi đọc `REG_DATA_OUT` (xem `firmware_Aes/firmware.md`)
— dư khoảng **3.5 lần** so với mức cần thiết, đủ an toàn dù không poll
`REG_STATUS`. Đây là lý do firmware chạy ổn định trên Vivado thật như đã
xác nhận, dù cách chờ bằng đếm lệnh cố định (thay vì polling status) hơi
mong manh về nguyên tắc — xem khuyến nghị bên dưới.

## Bug timing thật — tìm được từ implementation report thật (2026-08-07)

Khi tích hợp vào SoC đầy đủ (`SE-RISSP_AES_ULTRA`, RISSP + AES + SHA3 + RSA
qua AXI4-Lite, clock 40MHz/25ns), `report_timing_summary` sau khi route cho
kết quả: **WNS = -7.998ns, TNS = -909.774ns, 128 endpoint fail setup** (Hold
và Pulse Width đều pass). Đọc chi tiết 10 đường trễ nhất trong
`design_1_wrapper_timing_summary_routed.rpt` thì **toàn bộ 10/10** đều có
dạng:
```
Source:      .../AES_hardware_final_0/inst/aes_inst/key_reg_reg[N]/C
Destination: .../AES_hardware_final_0/inst/aes_inst/aes_core_inst/state_reg_reg[M]/D
Data Path Delay: ~32-33ns (logic ~9ns / route ~23-24ns)
```
Không có đường nào từ SHA3 hay RSA trong danh sách vi phạm — nghi ngờ trước
đó về `round2in1.v` (SHA3) là **sai**, dữ liệu đo thật cho thấy toàn bộ lỗi
nằm ở AES. 128 endpoint fail khớp chính xác độ rộng 128-bit của `state_reg`
— tức gần như MỌI bit của thanh ghi trạng thái AES đều bị ảnh hưởng bởi
cùng 1 đường tổ hợp.

**Nguyên nhân**: `KeyExpansion` (trong `KeyExpansionRound.v`) tính **toàn bộ
10 round key AES-128 bằng 1 khối tổ hợp thuần** (`generate` 10 tầng nối
tiếp bằng `assign`, không có thanh ghi trung gian nào giữa các round). Kết
quả `expanded_keys` này được dùng NGAY LẬP TỨC (tổ hợp) trong nhánh IDLE của
`AESEncrypt.v` (`next_state_reg = data_in ^ all_keys[0+:128]`) — tạo thành 1
đường tổ hợp rất dài xuyên suốt từ `key_reg` (trong `aes_wrapper`) qua 10
tầng S-box/XOR của key schedule, thẳng vào `state_reg`. Route chiếm tới
~72% độ trễ (23ns/32ns) — dấu hiệu of 1 đám mây logic tổ hợp lớn, trải rộng
vật lý trên die, đúng như dự đoán từ 1 chuỗi 10-tầng không pipeline.

**Đã sửa** (`aes_wrapper.v`): thêm 1 tầng thanh ghi (`expanded_keys_reg`)
chốt lại output của `KeyExpansion` trước khi đưa vào `AESEncrypt`, cắt đường
tổ hợp dài thành 2 đoạn ngắn hơn (key_reg→KeyExpansion→thanh ghi mới, rồi
thanh ghi mới→AddRoundKey→state_reg). An toàn về chức năng vì các lệnh ghi
key qua AXI vốn đã cách nhau nhiều chu kỳ (~4-5 chu kỳ/lệnh) — dư thừa để
`expanded_keys_reg` ổn định trước khi `start_pulse` kích hoạt.

Đã sửa thêm 1 bug tiềm ẩn khác lộ ra khi compile `aes_wrapper.v` độc lập lần
đầu (chưa từng compile riêng file này trước đó trong toàn bộ audit): biến
`core_done_tick` được dùng ở dòng 65 nhưng khai báo `wire` ở dòng 106 (sau
chỗ dùng) — `xvlog` báo lỗi cứng "used before declaration". Đã chuyển khai
báo lên đầu file. Không ảnh hưởng logic, chỉ là thứ tự khai báo.

**Đã verify lại bằng regression test** (`tb_aes_wrapper_timing_fix.v`, drive
đúng register map qua `aes_wrapper` như `aes_axi_slave.v` thật gọi) — cả
**4/4 mode** (ECB/CBC/CFB/CTR) đều ra đúng ciphertext chuẩn NIST sau khi
sửa, không phá vỡ chức năng:
```
[PASS] ECB  qua aes_wrapper = 3ad77bb40d7a3660a89ecaf32466ef97
[PASS] CBC  qua aes_wrapper = 7649abac8119b246cee98e9b12e9197d
[PASS] CFB  qua aes_wrapper = 3b3fd92eb72dad20333449f8e83cfb4a
[PASS] CTR  qua aes_wrapper = 874d6191b620e3261bef6864990db6ce
REGRESSION PASS (4/4 mode)
```

### Trạng thái hiện tại của `AES_CORE` (2026-08-07)

Thư mục này **đã chứa sẵn bản đã sửa timing** (`aes_wrapper.v` có
`expanded_keys_reg` + đã sửa thứ tự khai báo `core_done_tick`) — sẵn sàng
để đóng gói thành 1 IP mới trong Vivado. Lưu ý:
- Bản sửa này **chưa** được đồng bộ lại vào `D:\SE_RISSP_LIBRARY\AES_IP`
  (nơi đó đang cố tình giữ nguyên bản gốc chưa sửa, theo yêu cầu trước đó,
  để dành làm nơi tham chiếu "trước khi sửa"). IP mới sẽ đóng gói từ chính
  `AES_CORE` này, không phải từ `D:\SE_RISSP_LIBRARY\AES_IP`.
- File `AESEncrypt.v`, `AddRoundKey.v`, `KeyExpansionRound.v`,
  `MixColumns.v`, `ShiftRows.v`, `SubBytes.v`, `SubTable.v` đã có
  `` `timescale`` (cần cho mô phỏng, không ảnh hưởng logic/timing tổng hợp).
- `aes_axi_slave.v` không đổi gì.

## Bug timing thật — lần 2: fix trước (`expanded_keys_reg`) không đủ (2026-08-07)

Re-đo `SE-RISSP_AES_ULTRA` (RISSP+AES+SHA3+RSA, clk 40MHz/25ns) sau khi đã
tích hợp bản có `expanded_keys_reg` (mục trên): **WNS vẫn -5.249ns**, và số
endpoint fail **tăng từ 128 lên 297**. Đọc `design_1_wrapper_timing_summary_
routed.rpt` thật: 100% path top vẫn dạng
```
Source:      .../aes_inst/key_reg_reg[N]/C
Destination: .../aes_inst/expanded_keys_reg_reg[M]/D
Data Path Delay: ~29.8-29.9ns    Logic Levels: 42-44
```
**Nguyên nhân**: `expanded_keys_reg` chỉ dời điểm KẾT THÚC của khối tổ hợp,
không cắt được bản thân chuỗi 10 tầng bên trong `KeyExpansion`
(`KeyExpansionRound.v`) — module này vẫn nối 10 `KeyExpansionRound` liên
tiếp thuần bằng `generate`/`assign`, không có thanh ghi trung gian nào giữa
các round. Vì vậy Logic Levels không đổi (~42), WNS chỉ nhích nhẹ. Đồng thời
vì `expanded_keys_reg` rộng 1408 bit và bị clock **mỗi chu kỳ vô điều kiện**
(không gate theo key có đổi hay không), số endpoint fail tăng lên (128→297)
so với bản cũ (đích trước đó là `state_reg` 128-bit, chỉ đọc lúc IDLE).

**Đã hỏi lại người dùng 2 hướng fix** (pipeline RTL gốc vs `set_multicycle_
path` không sửa RTL) — người dùng chọn **pipeline RTL gốc** (bền vững ở mọi
tần số, không phụ thuộc giả định thời gian AXI).

### Fix thật: pipeline nội bộ `KeyExpansion` (thay expanded_keys_reg)

`KeyExpansion` (trong `KeyExpansionRound.v`) viết lại hoàn toàn: mỗi round
key giờ là 1 thanh ghi riêng (`round_key[0..10]`), giữa 2 tầng chỉ còn ĐÚNG
1 khối tổ hợp `KeyExpansionRound` (module con giữ nguyên, không đổi) —
critical path 1 tầng chỉ còn ~13 logic level / ~5ns thay vì 42 level/~30ns
của cả chuỗi. Đổi lại: cần **10 chu kỳ** để round key cuối (round 10) ổn
định sau khi `key_in` đổi — thêm output `keys_valid` báo đúng thời điểm đó.

`AESEncrypt.v` thêm input `keys_valid` + 1 thanh ghi `start_req`: nếu
`enable` đến TRƯỚC khi `keys_valid=1` (key vừa ghi xong, pipeline chưa đầy),
request được giữ lại (`start_req<=1`) và tự động bắt đầu ngay khi
`keys_valid` lên 1 — **không phụ thuộc firmware phải chờ đủ N chu kỳ giữa
lúc ghi key và lúc ghi start** (khác với cách tiếp cận "tin vào khoảng cách
AXI" đã dùng cho bản `expanded_keys_reg` cũ) — an toàn bất kể thứ tự/khoảng
cách các lệnh ghi AXI sau này.

`aes_wrapper.v`: bỏ hẳn `expanded_keys_reg` (không cần nữa vì `keys_out` của
`KeyExpansion` giờ đã là bus thanh ghi thật, không phải dây tổ hợp) — nối
thẳng `expanded_keys`/`expanded_keys_valid` vào `AESEncrypt`.

**Verify**:
- `tb_aes_core.v` (cập nhật thêm `clk`/`rst_n` cho `KeyExpansion`, thêm dây
  `keys_valid`) — **4/4 mode PASS**, khớp NIST SP800-38A.
- `tb_aes_wrapper_timing_fix.v` (đã poll `REG_STATUS`, không đếm chu kỳ cứng
  nên tự hấp thụ được latency mới) — **4/4 mode PASS**, không cần sửa gì.
- Synth out-of-context `aes_wrapper` (`xc7z020clg484-1`, `AreaOptimized_high`
  + `opt_design -directive ExploreArea`) với `create_clock -period 20.0`
  (đúng 50MHz — chặt hơn cả target 40MHz cũ): **WNS = +13.145ns, 0 endpoint
  fail** trên 2457 endpoint (trước: -5.249ns/25ns). Path xấu nhất còn lại
  chỉ 13 logic level (~5ns), không liên quan key schedule nữa (so sánh
  128-bit `key_in!=key_in_d` để reset `fill_cnt`).

**Đã đồng bộ**: 3 file `KeyExpansionRound.v`, `AESEncrypt.v`, `aes_wrapper.v`
đã copy đè sang `d:\SE_RISSP_LIBRARY\AES_NEOS\src\` (IP repo thật mà project
`SE-RISSP_AES_ULTRA` tham chiếu qua `ip_repo_paths`, xác nhận bằng
`design_1_wrapper.tcl`) — **CẦN làm tiếp trong Vivado** (chưa tự làm được vì
cần GUI): mở project `AES_NEOS` packaging (hoặc Tools → Create and Package
New IP → Edit IP trỏ tới `d:\SE_RISSP_LIBRARY\AES_NEOS`) → tab File Groups →
"Merge changes from File Groups Wizard" → tăng Version → Re-Package IP; sau
đó trong `SE-RISSP_AES_ULTRA`, mở Block Design → chuột phải
`aes_axi_slave_0` → **Upgrade IP...** (hoặc Report IP Status → Refresh nếu
Vivado chưa tự phát hiện) → Validate Design → Generate Output Products →
chạy lại Synthesis/Implementation, đặt clock chính của hệ (`clk_wiz`) ra
**50MHz** để xác nhận WNS dương trên report thật (đo standalone chỉ mang
tính định hướng, số cuối cùng phải lấy từ report routed của SoC đầy đủ).

**Lưu ý riêng — RSA cũng đang fail ở 40MHz**: đếm trong
`design_1_wrapper_timing_summary_routed.rpt` (64 path chi tiết được liệt
kê), **34 path thuộc AES** (đã sửa ở trên), nhưng **19 path thuộc
`RSA_mark03_0`** (chuỗi `ACOUT` của DSP48 trong Montgomery reduction,
`u_mont/u_red`) — khác cơ chế, chưa đụng tới. Nếu muốn cả SoC thật sự chạy
được 50MHz, sau khi build lại với AES đã sửa cần xem lại report timing mới
— nhiều khả năng RSA sẽ là bottleneck kế tiếp, cần phân tích riêng.

## Khuyến nghị (chưa sửa, cần xác nhận trước khi động vào)

1. **Firmware chờ bằng NOP đếm cứng, không polling `REG_STATUS`
   (offset 0x24)** — hoạt động đúng vì có biên độ dư 3.5x, nhưng nếu sau
   này đổi tần số clock hoặc thêm round/mode làm tăng độ trễ core, delay
   cứng 60 NOP có thể không còn đủ mà không có cảnh báo lỗi nào (đọc phải
   ciphertext cũ/rác). Poll `REG_STATUS` bit0 sẽ an toàn tuyệt đối bất kể
   độ trễ core — nhưng đây là thay đổi ở firmware, cần hỏi lại trước khi
   sửa vì 4 file `.coe` hiện tại đã chạy được trên Vivado thật.
2. Phần dữ liệu cuối mỗi file `.coe` (sau lệnh `JAL` nhảy lùi) là các word
   trông giống metadata debug (`.debug_frame`/CFI) còn sót lại từ toolchain
   biên dịch, **không được CPU thực thi tới** (JAL nhảy lùi trước đó) — vô
   hại, chỉ chiếm thêm vài chục word trong BRAM.
