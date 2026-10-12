# Ibex_FULL — testbench cho SoC `Ibex_SoC`

SoC: **Ibex + AES + SHA3 + RSA-2048** (`F:\advance_topic\Ibex_SoC`, Zynq
xc7z020, 40MHz — dia chi AXI giong het `SE-RISSP_AES_ULTRA`). Đây là SoC đã
đi dây xong (2026-08-14), CHƯA chạy Synthesis/Implementation.

## Boot offset 0x80 — đã xử lý bằng phần cứng, dùng THẲNG `.coe` gốc

Ibex **không boot tại địa chỉ 0** — lệnh fetch đầu tiên thật sự tại
`boot_addr_i + 0x80` (`ibex_if_stage.sv:218`, cố định trong RTL, không sửa
được qua tham số). Thay vì phải chỉnh file `.coe`, đã thêm **1 bộ trừ hằng
số tổ hợp** (`addsub_bootoffset_0`, IP `xilinx.com:ip:c_addsub:12.0`, 0 chu
kỳ trễ) chen giữa `xlslice_0` và `blk_mem_gen_0` trong Block Design của
`Ibex_SoC`:

```
addr_BRAM(13-bit) = addr_fetch_word(13-bit) − 32
```

Ibex fetch tại word-address 32 (=byte 0x80) → trừ 32 → đọc trúng **word 0
của BRAM** = word 0 của file `.coe` gốc. Không tràn/âm vì địa chỉ fetch của
Ibex sau khi boot luôn ≥ 32 (chương trình chỉ dùng branch nội bộ, không
nhảy lùi về trước điểm vào).

⇒ **Nạp thẳng file `.coe` gốc trong `firmware_testbench/SE-RISSP_FULL/`**,
không cần sửa/đệm gì — dùng đúng 1 bộ file cho cả 3 hệ RISSP/RV32I/Ibex.
(Đã cân nhắc phương án khác — đệm 32 từ vào đầu `.coe` — nhưng chọn cách
này theo yêu cầu giữ nguyên bộ `.coe` chuẩn dùng chung.)

Bộ trừ này nằm **ngoài** module CPU (`ibex_axi_top`), ở tầng đi dây SoC nên
**không lọt vào số LUT lõi** dùng so sánh diện tích giữa 3 lõi (đo bằng
`synth_standalone.tcl`/OOC, tách biệt hoàn toàn khỏi Block Design) — chỉ
cộng thêm vài LUT vào tổng LUT *toàn SoC* (không đáng kể, có thể ghi chú
ngắn trong paper nếu cần).

## Phạm vi: mỗi mode test 1 case — GIỐNG HỆT SE-RISSP_FULL/RV32I_FULL

Cùng vector, cùng ciphertext/digest/RESULT kỳ vọng, cùng cơ chế đo (PURE =
mốc theo địa chỉ từ cuối, không đếm số giao dịch) — 3 bảng so sánh được
trực tiếp với nhau.

## ✅ Nút "Run Simulation" của Vivado GUI GIỜ CHẠY BÌNH THƯỜNG (đã sửa tận gốc 2026-08-14)

Trước đây Vivado không tự đưa đủ 56 file `.sv` của `ibex_core_0` vào mô
phỏng (bug thật của `ipx::package_project` — bộ đóng gói IP có bộ phân
tích cú pháp yếu hơn `xvlog`, không hiểu macro `` `ASSERT`` tham số mặc
định của lowRISC, gây lỗi metadata mô phỏng âm thầm). **Đã sửa tận gốc**:
đóng gói lại IP (`F:\advance_topic\Ibex_Core\ip_repo`, cùng VLNV) từ 1 file
RTL đã gộp + bỏ lời gọi `` `ASSERT``/`` `COVER``/`` `ASSUME`` (rỗng hoàn
toàn khi `SYNTHESIS`, xoá không đổi hành vi) — xem đầy đủ quá trình truy
lỗi + fix trong `CLAUDE.md` mục "ĐÃ TÌM RA VÀ SỬA TẬN GỐC".

⇒ **Giờ chỉ cần mở `Ibex_SoC.xpr`, set testbench làm Top, bấm "Run
Simulation"** — giống hệt cách dùng cho RISSP/RV32I, không cần thao tác gì
thêm. Nếu Vivado vẫn dùng cache cũ (hiếm, chỉ khi mở project rất lâu trước
khi fix): **Reset Output Products** rồi **Generate Output Products** lại
cho `design_1.bd` trước khi Run Simulation.

`run_manual_sim.tcl`/`run_all.bat` dưới đây **vẫn giữ lại** làm phương án
chạy hàng loạt/không cần mở GUI (hữu ích khi chạy cả 8 workload liên tục),
nhưng không còn là cách BẮT BUỘC nữa.

### (Tuỳ chọn) Cách 1 — bấm đúp `run_all.bat`, không cần mở GUI, tự mở waveform luôn

Bấm đúp `run_all.bat` trong Explorer (hoặc chạy `run_all.bat <ten_testbench>
<ten_coe>` từ cmd) — script tự chạy mô phỏng, in kết quả PASS/FAIL ra màn
hình, rồi **tự mở Vivado GUI với waveform đã sẵn** (không cần tự vào File →
Open Waveform Database). Không cần mở Vivado trước — script tự lo hết.
Đã verify: `run_all.bat tb_ibex_ecb aes_ecb` chạy PASS + tự mở đúng waveform.

### (Tuỳ chọn) Cách 2 — chạy tay qua dòng lệnh (không tự mở waveform)

```
"F:\vivado\Vivado\2024.2\bin\vivado.bat" -mode batch -source run_manual_sim.tcl -tclargs <ten_testbench> <ten_file_coe_khong_duoi>
```

| Chức năng | `<ten_testbench>` | `<ten_file_coe>` |
|---|---|---|
| AES-128 **ECB** | `tb_ibex_ecb` | `aes_ecb` |
| AES-128 **CBC** | `tb_ibex_cbc` | `aes_cbc` |
| AES-128 **CFB** | `tb_ibex_cfb` | `aes_cfb` |
| AES-128 **CTR** | `tb_ibex_ctr` | `aes_ctr` |
| **SHA3-256** 1 block | `tb_ibex_sha3` | `sha3` |
| **SHA3-256** 4 block | `tb_ibex_sha3_4` | `sha3_4` |
| **SHA3-256** 16 block | `tb_ibex_sha3_16` | `sha3_16` |
| **RSA-2048** verify | `tb_ibex_rsa2048` | `rsa2048` |

Ví dụ (AES ECB): `... -tclargs tb_ibex_ecb aes_ecb`. Script tự đọc
`.coe` từ `SE-RISSP_FULL` (không sửa file gốc), tự convert sang `.mif`
đúng định dạng NHỊ PHÂN 32-bit/dòng mà `blk_mem_gen` cần (⚠️ khác `.coe`
dùng hex — nhầm cái này làm CPU chạy lạc, đã tự bắt lỗi này lúc build
script), rồi biên dịch+elaborate+chạy trong thư mục `_sim_run/` (tự tạo,
xoá được, không phải commit). Kết quả in thẳng ra Tcl console giống hệt
format `Run Simulation`.

### Xem waveform (giống cách đã làm cho RISSP/RV32I)

Script tự ghi **waveform database** (`--debug all` khi `xelab` + `log_wave
-recursive *` khi chạy) ra `_sim_run/<ten_testbench>.wdb` — chứa TOÀN BỘ
tín hiệu nội bộ, kể cả bên trong `ibex_core_0`.

- Dùng **Cách 1** (`run_all.bat`) → waveform **tự mở**, không cần làm gì
  thêm.
- Dùng **Cách 2** (dòng lệnh) → tự mở tay: mở Vivado (project nào cũng
  được) → **File → Open Waveform Database...** → chọn file
  `firmware_testbench/Ibex_FULL/_sim_run/<ten_testbench>.wdb`. Kéo tín hiệu từ
  cây hierarchy (bên trái) vào cửa sổ waveform giống hệt thao tác đã quen
  với RISSP/RV32I.

⚠️ File `.wdb` bị **ghi đè** mỗi lần chạy lại CÙNG 1 testbench — nếu muốn
giữ lại nhiều lần chạy, đổi tên file `.wdb` trước khi chạy lại.

**Yêu cầu trước khi chạy**: `Ibex_SoC.xpr` đã Create HDL Wrapper +
Generate Output Products **ít nhất 1 lần** (để có sẵn
`design_1_wrapper.v`/`ipshared/`/stub `.vhd` của 4 IP VHDL — 34 file
"phần còn lại" trong `run_manual_sim.tcl` trỏ cứng vào các đường dẫn này,
nếu Block Design đổi cấu trúc thì phải cập nhật lại danh sách).

**File `ibex_compile_order.f`** — thứ tự biên dịch đúng của 56 file RTL
Ibex (package phải compile trước module dùng nó — SystemVerilog không tự
sắp xếp được, dùng sai thứ tự sẽ lỗi `'ibex_pkg' is not declared`). Lọc từ
`IBEX_CORE/compile_order.f` (111 file gốc), chỉ giữ 56 file thực sự còn
trong `ip_repo/src/` sau khi IP Packager tự cắt bớt. **Đừng gõ tay lại
danh sách này** — bài học từ chính phiên debug: gõ tay 1 lần đã sót 19 file
(thiếu cả `prim_clock_gating.sv` gây lỗi elaborate).

## ⚠️ `POWER_W` trong mọi testbench đang là số TẠM (0.407 W, mượn của SoC RISSP)

`Ibex_SoC` **chưa chạy Implementation** nên chưa có `Total On-Chip Power`
thật. Mọi số Energy/Throughput-per-W in ra hiện tại **chỉ mang tính tham
khảo cấu trúc phép tính**, chưa dùng được cho paper. Sau khi có báo cáo
`report_power` thật, cập nhật `POWER_W` ở đầu mỗi file `tb_ibex_*.v`
(giống cách `gen_all.py` cập nhật `POWER_W` cho 2 bộ kia).

## File trong thư mục

```
tb_ibex_ecb/cbc/cfb/ctr.v        AES-128 4 mode
tb_ibex_sha3/sha3_4/sha3_16.v    SHA3-256 1/4/16 block
tb_ibex_rsa2048.v                RSA-2048 verify
```

Không có `.coe`/`.s`/`.hex` riêng trong thư mục này — dùng thẳng file
`.coe` của `SE-RISSP_FULL` (xem phần "Boot offset" ở trên).
