# IBEX_CORE

Bản Ibex (lowRISC RV32 CPU, https://github.com/lowrisc/ibex) đã được kéo về,
**gạn lọc còn đúng RTL cần cho tổng hợp** (bỏ DV/UVM/formal/cosim/docs), và
đóng gói cùng **1 wrapper AXI** để cắm thẳng vào cùng 1 SoC kiểu
`SE-RISSP_AES_ULTRA`/`rissp_top.v`, phục vụ so sánh Ibex vs RISSP (vs CVA6
sau này) khi chạy chung 1 hệ thống.

## Nguồn & cách lấy

- Clone từ `https://github.com/lowrisc/ibex.git`, checkout ở commit
  `c6edaa4060b1a3cd27fda928058db4f0ee3d24bd` (2026-07-02, "Generalize SRAM
  configuration interfaces") — **cố tình KHÔNG lấy HEAD**, vì HEAD tại thời
  điểm lấy (2026-08-12) đã có thêm tính năng "TRVK / CHERIoT" (merge
  2026-08-10, 2 ngày trước) làm `ibex_top` phình thêm ~10 cổng
  (`trvk_*`) không cần thiết cho 1 core RV32 so sánh thường. Commit đã chọn
  là bản ngay TRƯỚC merge đó — Ibex "vanilla" gọn nhất còn hợp lệ.
- Danh sách file + **thứ tự compile chính xác** không suy đoán bằng tay —
  dùng `fusesoc` (dependency resolver chính chủ của Ibex) chạy
  `fusesoc run --target=default --tool=vivado --setup lowrisc:ibex:ibex_top`
  rồi trích thứ tự `read_verilog` từ file `.tcl` Vivado mà nó tự sinh ra.
  Đây chính là target Ibex tự định nghĩa cho Vivado (`tool_vivado ?
  (FPGA_XILINX=true)`), nên là nguồn đáng tin cậy nhất, tự động chọn đúng
  `prim_xilinx` (BUFGCE/BUFGMUX cho clock gating/mux) thay vì `prim_generic`.

## Nội dung

```
IBEX_CORE/
├── README.md            — file này
├── compile_order.f      — 111 file .sv/.v THEO ĐÚNG THỨ TỰ COMPILE
│                           (109 file lõi Ibex do fusesoc resolve +
│                            axi_rissp_master.v + ibex_axi_top.sv)
├── rtl/                  111 file trên + 8 file .svh/.sv chỉ để `include`
│                          (prim_assert.sv, prim_assert_standard_macros.svh,
│                          prim_assert_sec_cm.svh, prim_assert_dummy_macros.svh,
│                          prim_flop_macros.sv, prim_util_memload.svh,
│                          prim_util_get_scramble_params.svh,
│                          dv_fcov_macros.svh) = 119 file tổng cộng
└── sim/                  testbench + chương trình test tự viết, ĐÃ CHẠY
                           THẬT qua xsim và PASS — xem mục "Verify đã làm"
```

Không có file DV/UVM/formal/cosim/riscv-tests/coremark nào bị mang theo từ
Ibex gốc — chỉ đúng RTL synthesizable + 1 tầng wrapper AXI tự viết. `sim/`
là bộ tự-test riêng của repo này (không phải của Ibex), giữ tách khỏi
`rtl/` để `rtl/` luôn sạch cho việc đóng gói IP.

### `ibex_axi_top.sv` — wrapper để so sánh công bằng với RISSP

Muốn Ibex "vào dùng 1 khuôn" với `rissp_top.v` để đổi CPU trong SoC mà
**không đổi gì khác** (cùng port `imem_addr/imem_rdata`, cùng port AXI4
`m_axi_*`, cùng module `axi_rissp_master.v` — **copy y hệt, không sửa 1
dòng** — làm cầu nối tới bus dữ liệu). Chỉ core CPU là biến số duy nhất khi
so sánh 2 SoC.

2 chỗ cần "dịch" giao thức, cả 2 đều suy ra thuần từ port đã công bố (không
đụng vào tín hiệu nội bộ của module nào):

1. **imem** (`instr_req_o/instr_gnt_i/instr_rvalid_i`, giao thức OBI của
   Ibex) → cổng BRAM thô 1-chu-kỳ (`imem_addr`/`imem_rdata`, giống hệt
   `fetch_stage.v` của RISSP). Vì BRAM 1 cổng luôn sẵn sàng nhận địa chỉ
   mới mỗi chu kỳ: `gnt = req` (tổ hợp), `rvalid` = `req` trễ 1 chu kỳ. Đây
   đúng là mẫu tham chiếu chính chủ Ibex dùng
   (`examples/simple_system/rtl/ibex_simple_system.sv`: `assign instr_gnt =
   instr_req;`).

2. **dmem** (`data_req_o/data_gnt_i/data_rvalid_i/...`) → `axi_rissp_master.v`
   (copy y hệt). Module này không có cổng `gnt`/`rvalid` riêng (chỉ có
   `dmem_addr/wdata/wstrb/read` vào, `dmem_rdata/stall_cpu` ra), nên suy ra
   gnt/rvalid từ **cạnh của `stall_cpu`**: cạnh lên = đúng lúc FSM rời
   `IDLE` và latch địa chỉ (= lúc phải báo gnt), cạnh xuống = đúng lúc vào
   trạng thái `DONE` (= lúc `dmem_rdata` đã chắc chắn đúng theo comment gốc
   trong chính `axi_rissp_master.v`). Không đọc `state` nội bộ — chỉ dùng 2
   cổng đã công bố.

### Tham số có thể chỉnh (parameter pass-through ra `ibex_axi_top`)

Mặc định = **y hệt default của chính `ibex_top`** (Ibex "nguyên bản"):
`RV32M=RV32MFast`, `RV32B=RV32BNone`, `RV32ZC=RV32ZcaZcbZcmp` (có nén),
`RV32E=0`, `ICache=0`, `PMPEnable=0`, `MHPMCounterNum=0`. Muốn so sánh
**đúng tập lệnh RV32I với RISSP** (tắt M/nén để cùng ISA), set khi
instantiate: `RV32M=ibex_pkg::RV32MNone`. Lưu ý Ibex **không có** cách tắt
hẳn phần nén (không có `RV32ZcNone`, enum nhỏ nhất là `RV32Zca`) — decoder
nén luôn tồn tại trong RTL dù chương trình không dùng lệnh nén.

## Verify đã làm — MÔ PHỎNG HÀNH VI THẬT ĐÃ CHẠY VÀ PASS (2026-08-13)

Không chỉ dừng ở static elaboration — đã dựng `sim/tb_ibex_axi_top.v`
(model BRAM 1-chu-kỳ cho imem + 1 AXI4 slave hành vi tối giản cho dmem,
backing bằng RAM 64 từ) và chạy **thật** qua `xsim` với 1 chương trình
RV32I thật (`sim/test_prog.s`, assemble bằng đúng toolchain
`F:\xpack-riscv-none-elf-gcc-15.2.0-1\bin` đã dùng cho firmware RISSP):
LI/ADDI, ADD, SW/LW qua AXI dmem shim, vòng lặp branch (BNE) 5 lần, JAL
nhảy vô hạn. Kết quả:

```
[PASS] mem[0x100] = 15 (x3 = x1+x2, sw dung)
[PASS] mem[0x104] = 115 (lw doc lai + addi dung)
[PASS] mem[0x108] = 5 (vong lap branch dung 5 lan)
=== ALL PASS: ibex_axi_top boot + fetch + LSU AXI + branch OK ===
```

**2 lỗi thật đã bắt và sửa trong quá trình này** (không phải chỉ suy đoán):

1. **Ibex KHÔNG boot tại `boot_addr_i`** — fetch đầu tiên thật sự tại
   `boot_addr_i + 0x80` (`ibex_if_stage.sv:218`,
   `fetch_addr_n = {boot_addr_i[31:8], 8'h80}` — reset vector cố định
   kiểu OpenTitan). Khác hẳn RISSP (boot thẳng PC=0). Đã sửa bằng cách
   link chương trình test tại `0x80` (`sim/link.ld`) và ghi rõ trong
   comment tham số `BootAddr` của `ibex_axi_top.sv`. **Khi đưa vào SoC
   thật, chương trình trong imem BRAM phải đặt tại offset byte 0x80**,
   không phải 0x0 như RISSP.
2. **`xelab` crash khi dựng snapshot mô phỏng** nếu thiếu define
   `SYNTHESIS` — nguyên nhân: `ibex_if_stage.sv` có 1 khối
   `` `ifndef SYNTHESIS `` (DPI-export shim cho cosim testbench riêng của
   Ibex, tự nhận là "slightly ugly hack" trong comment gốc) sinh ra tên
   hàm C không hợp lệ khi nằm trong generate-block, khiến trình sinh C
   nội bộ của `xelab` lỗi. Đã xác nhận (đọc hết mọi chỗ dùng `SYNTHESIS`
   trong 119 file) toàn bộ code phía sau các `` `ifdef``/`` `ifndef
   SYNTHESIS`` chỉ là DV/assertion/FCOV — định nghĩa `SYNTHESIS` không
   mất chức năng thật nào. Xem chi tiết + lý do tại sao Synthesis thật
   thường không dính lỗi này ở mục "Việc còn lại" bước 2 bên dưới.

**Cách chạy lại** (giống hệt flow `xvlog`/`xelab`/`xsim` RISSP đã dùng,
chỉ thêm `-d SYNTHESIS -d FPGA_XILINX` và link thư viện UNISIM):

```
cd IBEX_CORE/sim
set PATH=F:\vivado\Vivado\2024.2\tps\mingw\10.0.0\win64.o\nt\bin;%PATH%
"F:\vivado\Vivado\2024.2\bin\xvlog.bat" -sv -d SYNTHESIS -d FPGA_XILINX -i ../rtl -f filelist.f
"F:\vivado\Vivado\2024.2\bin\xvlog.bat" tb_ibex_axi_top.v
"F:\vivado\Vivado\2024.2\bin\xvlog.bat" "F:\vivado\Vivado\2024.2\data\verilog\src\glbl.v"
"F:\vivado\Vivado\2024.2\bin\xelab.bat" tb_ibex_axi_top glbl -s tb_snap -L unisims_ver -timescale 1ns/1ps
"F:\vivado\Vivado\2024.2\bin\xsim.bat" tb_snap -R
```

(Dòng `set PATH=...mingw...` chỉ cần nếu chạy `xelab`/`xsim` từ ngoài
Vivado GUI/Tcl console như sandbox này — trong Vivado GUI thật, C
toolchain cho `xsim` đã tự có sẵn trong môi trường, không cần thêm.)

**Chưa làm được / còn lại**: Run Synthesis/Implementation lấy số
LUT/FF/BRAM/DSP/power/timing thật (cần Vivado GUI, không chạy được bằng
CLI thuần trong sandbox này), test trên board thật.

## ĐÃ ĐÓNG GÓI THÀNH IP (2026-08-14) — `F:\advance_topic\Ibex_Core\ip_repo`

Không cần chờ Vivado GUI nữa — đã tự động hoá toàn bộ quy trình
`Docs/Vivado.md` bằng Tcl (`package_ibex_ip.tcl`) và chạy thật qua
`vivado -mode batch`, **PASS, exit code 0**. Chạy lại được bất cứ lúc nào:

```
"F:\vivado\Vivado\2024.2\bin\vivado.bat" -mode batch -source package_ibex_ip.tcl
```

- **Project**: `F:\advance_topic\Ibex_Core\ibex_core.xpr` (part
  `xc7z020clg484-1`, giống hệt part đã đo LUT cho RISSP).
- **IP đã đóng gói**: `F:\advance_topic\Ibex_Core\ip_repo\` (VLNV
  `rissp.local:user:ibex_core:1.0`, top = `ibex_axi_top`). Trỏ IP
  Repository của project SoC đích vào thư mục này (y hệt Bước 3 trong
  `Docs/Vivado.md`, chỉ đổi đường dẫn).
- **Interface tự suy luận đúng như kỳ vọng** (giống hệt kết quả RISSP):
  `m_axi` → AXI4MM (không có tín hiệu burst nên hoạt động như AXI4-Lite,
  đúng chủ đích), `rst_n` → Reset (POLARITY=ACTIVE_LOW, tự đúng), `clk` →
  Clock. `imem_addr`/`imem_rdata` giữ nguyên dạng External Port (đúng dự
  kiến, nối tay ở Bước 6 của `Docs/Vivado.md`).
- **2 define bắt buộc đã set sẵn trong project `Ibex_Core`** (`SYNTHESIS`,
  `FPGA_XILINX`) — nhưng property `verilog_define` của fileset **KHÔNG đi
  theo IP khi package**, nên **PHẢI set lại 2 define này ở project SoC
  đích** (nơi bạn add IP repo vào) — xem mục "Việc còn lại" bước 2 bên
  dưới, đừng quên bước này.

### 2 phát hiện quan trọng trong lúc đóng gói (không phải suy đoán — đã tự verify bằng elaboration thật)

1. **`axi_rissp_master.v` "chuẩn" trong repo này BỊ LỖI THỜI** — CLAUDE.md
   ghi nhận bản đã sửa "bỏ 1 chu kỳ lãng phí" (2026-08-13) nhưng bản sửa đó
   **chưa từng được đồng bộ ngược lại repo nguồn** (`F:\RISSP_cORE\`), chỉ
   tồn tại trong cache Vivado của project `SE-RISSP_AES_ULTRA`. Diff xác
   nhận cả `F:\RISSP_cORE\axi_rissp_master.v` VÀ `RISSP_CORE\
   axi_rissp_master.v` (bản dùng đóng IP cho RISSP!) đều còn bản CŨ (5
   thanh ghi cờ). Đã đồng bộ bản đã sửa vào **cả 3 nơi**: root, `RISSP_CORE/`,
   `IBEX_CORE/rtl/` — verify lại `tb_rissp_top.v` **PASS 43/43** (không hồi
   quy) và `sim/tb_ibex_axi_top.v` **PASS** (giữ nguyên) sau khi đồng bộ.
   ⚠️ **IP RISSP đã đóng gói trước đây tại `D:\SE_RISSP_LIBRARY\
   RISSP_CORE_NEW` có thể vẫn đang dùng bản cầu AXI cũ** — nên đóng gói lại
   nếu muốn số liệu so sánh RISSP/Ibex công bằng tuyệt đối (không phải việc
   của phiên này, chỉ ghi chú lại).

2. **Tham số kiểu `ibex_pkg::rv32m_e`/`rv32b_e`/`rv32zc_e` làm IP Packager
   crash thật** (`ERROR: [IP_Flow 19-627] XPath expression failed:
   Undefined parameter "ibex_pkg"`) — dù `xvlog`/`xelab`/`xsim` compile và
   chạy hoàn toàn bình thường với kiểu này. Đây là giới hạn RIÊNG của
   IP-XACT metadata generator (không hiểu type package-scoped enum ở tham
   số MODULE TOP được package). Đã sửa: đổi `RV32M`/`RV32B`/`RV32ZC` sang
   kiểu `int` với giá trị mặc định là **số nguyên literal** (không phải
   biểu thức cast — IP-XACT cũng không hiểu cú pháp `int'(...)`), cast lại
   đúng kiểu enum ngay trước khi đưa vào `ibex_top` bên trong. Xem comment
   chi tiết + bảng mapping số↔enum ngay tại khai báo tham số trong
   `ibex_axi_top.sv`.

3. **Vivado IP Packager tự cắt bớt file "chết"** theo phân tích generate-
   block dựa trên giá trị tham số mặc định: `ip_repo/src/` chỉ còn **63/119
   file** (thiếu 55 file `prim_secded_*`/`prim_mubi*` các độ rộng không
   dùng tới, `prim_and2`/`prim_onehot_*`/`prim_present` — không module nào
   khác gọi tới chúng trong toàn bộ 111 file, xác nhận bằng `grep`). Đã
   **tự verify lại bằng cách elaborate TRỰC TIẾP đúng bộ 63 file đã đóng
   gói** (không phải bộ gốc) với 2 tham số duy nhất người dùng IP có thể
   bật sau này:
   - `PMPEnable=1` (ICache=0): **elaborate sạch, PASS**.
   - `ICache=1`: **FAIL thật** — `ERROR: [VRFC 10-3823] variable
     'icache_tag_alert' might have multiple concurrent drivers`. Truy ra
     tận gốc: đây là **bug RTL thật của chính Ibex** ở commit
     `c6edaa4060` (không phải do wrapper/pruning) — `ibex_top.sv` dòng
     756-757 gán cả mảng `icache_tag_alert`/`icache_data_alert` **bên
     trong** vòng lặp generate theo từng "way", mà `IC_NUM_WAYS=2` cố định
     (`ibex_pkg.sv` dòng 386, không parameterize được) ⇒ 2 driver cùng
     lúc. Đã ghi cảnh báo `⚠️ ICache=1 HIEN KHONG CHAY DUOC` ngay tại khai
     báo tham số trong `ibex_axi_top.sv` — **chỉ dùng `ICache=0` (mặc
     định)** cho tới khi có bản Ibex mới hơn sửa lỗi này.

### ⚠️ Bug thứ 4 phát hiện SAU khi kéo IP vào 1 project SoC khác (2026-08-14, đã sửa)

Kéo IP vào 1 Block Design mới rồi mở **Analysis Results** của fileset
`sim_1` (fileset không set `SYNTHESIS`, khác project `Ibex_Core` dùng đóng
gói) hiện ra hàng loạt `[HDL 9-3952] use of undefined macro 'ASSERT'` +
`[HDL 9-1206] Syntax error...` khắp `ibex_*.sv`/`prim_*.sv`. Truy ra gốc:
`prim_assert.sv` có `` `include `` rẽ nhánh theo `` `ifdef SYNTHESIS``
(nhánh true → `prim_assert_dummy_macros.svh`, nhánh false →
`prim_assert_standard_macros.svh`). Lúc đóng gói IP, project có
`SYNTHESIS=1` đang bật nên **`ipx::package_project` chỉ "thấy" và copy
đúng nhánh đang active** — `prim_assert_standard_macros.svh` (nhánh kia)
**bị thiếu hẳn** trong `ip_repo/src/`, dù vẫn có sẵn trong
`IBEX_CORE/rtl/`. Khi 1 fileset KHÁC (như `sim_1` mặc định) không bật
`SYNTHESIS`, code rẽ sang nhánh thiếu file → domino lỗi macro/syntax y hệt
trên. **Đã thử sửa `package_ibex_ip.tcl` để add tất cả 119 file vật lý
(không chỉ dò theo include) trước khi package — KHÔNG ăn thua**:
`ipx::package_project` vẫn tự phân tích "file nào thực sự được dùng" và
cắt bớt y hệt (vẫn ra đúng 63 file, thiếu đúng file đó), bất kể project có
đủ 119 file trong fileset hay không — đây là hành vi cố định bên trong
lệnh đóng gói, không sửa được bằng cách add thêm file.

**Cách đã sửa THỰC TẾ (không cần chạy lại Vivado — lúc đó GUI của bạn
đang mở, tránh conflict)**: copy trực tiếp
`prim_assert_standard_macros.svh` vào `ip_repo/src/` bằng filesystem, rồi
**sửa tay `ip_repo/component.xml`** thêm đúng 1 khối `<spirit:file>` (2
chỗ, khớp 2 fileset) đăng ký file này, y hệt format của
`prim_assert_dummy_macros.svh` cạnh nó — đã verify lại XML còn hợp lệ
(`xml.etree.ElementTree` parse sạch).

**⚠️ VIỆC BẠN CẦN LÀM trong Vivado GUI đang mở** để nhận thay đổi này (vì
tôi sửa thẳng file trên đĩa, không qua Tcl/GUI của Vivado nên project
đang mở chưa tự biết): trong project SoC (`ibex_soc`/`Ibex_SoC`) →
**Tools → Report → Report IP Status** (hoặc mục **Reports** ở đáy cửa sổ)
→ nếu Vivado báo IP có thay đổi, bấm **Upgrade Selected**/**Refresh IP**
→ sau đó chuột phải khối `ibex_core` trong Sources → **Reset Output
Products** rồi **Generate Output Products** → chạy lại **Run Simulation**
(hoặc mở lại Analysis Results) để xác nhận hết lỗi `ASSERT`/syntax.

**Bài học chung**: mọi lần đóng gói lại IP về sau, nên **kiểm tra
`ip_repo/src/` có đủ file so với `IBEX_CORE/rtl/`** trước khi coi là xong
— `ipx::package_project` không đáng tin để copy đủ file khi RTL có
`` `ifdef``-include rẽ nhánh theo define đang bật lúc đóng gói.

## Việc còn lại (làm trên máy có Vivado GUI đầy đủ)

1. ~~**Đóng gói IP**~~ — **ĐÃ XONG** (xem mục ngay trên). Nếu muốn xem lại
   bằng GUI: mở `F:\advance_topic\Ibex_Core\ibex_core.xpr`, **Tools →
   Package IP…** để mở lại project packaging tạm và soi từng tab (Ports and
   Interfaces, File Groups...) như quy trình gốc trong `Docs/Vivado.md`.
2. **2 Verilog define bắt buộc**: set `FPGA_XILINX=1` VÀ `SYNTHESIS=1` ở
   Project Settings → General → Verilog Options — **set cho cả 2 fileset
   Synthesis lẫn Simulation**, đừng chỉ set 1 bên:
   - `FPGA_XILINX=1`: đúng define mà target `tool_vivado` của Ibex tự
     set. `prim_xilinx_clock_gating`/`clock_mux2` đã hard-code
     BUFGCE/BUFGMUX sẵn nên không phụ thuộc define này để hoạt động đúng
     — chỉ ảnh hưởng pragma DSP cho performance counter (không dùng ở
     đây vì `MHPMCounterNum=0` mặc định). Không bắt buộc để chạy được,
     nhưng nên set để khớp 100% target chính chủ.
   - `SYNTHESIS=1`: **bắt buộc để mô phỏng (`xsim`) không bị crash** —
     đã tận mắt gặp lỗi này và sửa (xem mục "Verify đã làm" ở trên).
     Run Synthesis thật của Vivado (`synth_design`) **tự động định nghĩa
     `SYNTHESIS` sẵn** (hành vi mặc định của mọi công cụ synthesis lớn),
     nên bước Synthesis thường không bao giờ dính lỗi này dù có set tay
     hay không — chỉ riêng mô phỏng (`xsim`, kể cả sau này mô phỏng cả
     Block Design) mới cần set tay. Set cả 2 fileset cho chắc, không có
     tác dụng phụ (đã verify: mọi chỗ dùng `SYNTHESIS` trong 119 file chỉ
     là code DV/assertion, không đụng logic chức năng).
3. **Instantiate trong Block Design** giống `rissp_top`: `imem_addr` nối
   BRAM ROM (giống imem hiện tại của RISSP, port A, 1-cycle, KHÔNG tick
   "Register PortA Output of Memory Primitives" — bài học đã ghi lại trong
   `CLAUDE.md` chính, áp dụng y hệt cho Ibex vì cùng giả định BRAM 1 chu
   kỳ), `m_axi_*` nối vào cùng `axi_interconnect` mà RISSP đang dùng để giữ
   nguyên tập peripheral (SHA3/AES/RSA/BRAM debug).
4. Run Synthesis + Implementation, lấy LUT/FF/BRAM/DSP/power/timing —
   **đặt cạnh số đã có của RISSP** (1018 LUT lõi CPU, 10111 LUT toàn SoC 4
   lõi @ 40MHz) để ra bảng so sánh cho paper.
5. **Boot/test**: `BootAddr` mặc định `32'h0`, nhưng lệnh đầu tiên Ibex
   fetch thật sự là `BootAddr + 0x80` (đã verify bằng mô phỏng thật, xem
   mục "Verify đã làm") — **chương trình phải đặt tại offset byte 0x80
   trong imem BRAM**, KHÔNG phải 0x0 như RISSP. Nếu muốn giữ nguyên
   layout `.coe`/linker script cũ của RISSP (chương trình tại 0x0) để
   đổi core mà không đổi gì khác trong imem, đặt `BootAddr` sao cho
   `BootAddr+0x80` trỏ đúng địa chỉ chương trình mong muốn (vd muốn chạy
   tại 0x0 thật thì không được — 0x80 là offset cộng thêm cố định trong
   RTL, không trừ được qua tham số; cách khả thi duy nhất là dời chương
   trình sang 0x80 trong file `.coe` nạp vào imem BRAM khi build riêng
   cho Ibex).
