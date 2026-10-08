# Khả thi tích hợp PicoRV32 làm lõi CPU thứ 4 — nghiên cứu (2026-08-17)

> Trạng thái: **nghiên cứu khả thi đã xong, wrapper đã elaborate sạch**.
> **CHƯA** mô phỏng chức năng, **CHƯA** đóng IP, **CHƯA** dựng SoC. Mọi số
> LUT/FF trong tài liệu này là **thật, đo bằng Vivado `synth_design`**, không
> phải ước lượng — nhưng mới chỉ đo module `picorv32` độc lập (giống cách đo
> `synth_standalone.tcl` cho RISSP), chưa đo wrapper+SoC.

## 1. PicoRV32 là gì

Lõi RISC-V nhỏ gọn của Claire Wolf (YosysHQ), thiết kế cho FPGA/ASIC làm
"auxiliary CPU". Nguồn: `github.com/YosysHQ/picorv32`, giấy phép **ISC**
(tương đương MIT/BSD-2-Clause, rất thoáng, không ràng buộc gì đáng ngại cho
paper). Toàn bộ lõi nằm trong **đúng 1 file** `picorv32.v` (~97KB, 8 module:
`picorv32`, `picorv32_regs`, `picorv32_pcpi_mul/fast_mul/div`, `picorv32_axi`,
`picorv32_axi_adapter`, `picorv32_wb`) — nhẹ hơn hẳn Ibex (111 file lowRISC)
và CVA6 (111 file + phải lọc bỏ FPU/hpdcache).

Đã clone shallow về `PicoRV32_Core/` (repo con, `.git` riêng — commit đang
dùng là HEAD của `master` tại thời điểm 2026-08-17).

## 2. Vì sao đây là kiến trúc kết nối DỄ hơn Ibex và CVA6

Lõi `picorv32` (bản gốc, không phải wrapper `picorv32_axi`) có **1 cổng bộ
nhớ duy nhất** dùng chung cho cả fetch lẫn data, nhưng **có sẵn cờ
`mem_instr`** báo giao dịch hiện tại là fetch hay data — đúng cái cần để
tách ra `imem` (ROM riêng, 1 chu kỳ, không qua AXI) + `dmem` (qua
`axi_rissp_master.v`), giống hệt kiến trúc RISSP/RV32I/Ibex đang dùng. CVA6
**không có** cờ này ở cổng AXI hợp nhất nên phải thêm hẳn 1 AXI slave BRAM
riêng cho imem — PicoRV32 không cần vậy.

Giao thức `mem_valid`/`mem_ready` của PicoRV32 khớp gần như nguyên xi với
mẫu BRAM 1-chu-kỳ-đọc mà cả 3 SoC hiện tại đang dùng — đối chiếu trực tiếp
với ví dụ tham chiếu chính chủ `picosoc/picosoc.v` (dòng ~208-209):
```verilog
always @(posedge clk)
    ram_ready <= mem_valid && !mem_ready && mem_addr < 4*MEM_WORDS;
```
Đây chính là kiểu than ghi 1-cycle-pulse mà `axi_rissp_master.v` cũng dùng
(chốt theo cạnh xuống của `stall_cpu`) — không cần phát minh giao thức mới.

**Không có boot-offset ẩn** như Ibex (`+0x80`, cố định trong RTL, phải thêm
bộ trừ 13-bit trong Block Design mới né được). PicoRV32 có tham số
`PROGADDR_RESET` cấu hình được, đặt thẳng `32'h0` là xong — dùng ngay
`.coe` chuẩn chung với RISSP/RV32I/Ibex mà không cần patch gì.

## 3. LUT đo THẬT bằng Vivado (OOC, `xc7z020clg484-1`)

Script `PicoRV32_Core/synth_picorv32.tcl` (AreaOptimized_high + `opt_design
-directive ExploreArea`, đúng phương pháp `synth_standalone.tcl` của RISSP)
và `synth_picorv32_default.tcl` (strategy mặc định — đúng số nên trích vào
paper theo quy ước đã chốt "báo cáo default"). Cả 2 lần chạy đều **0 lỗi**,
chỉ có warning vô hại (cổng PCPI không nối — vì `ENABLE_PCPI=0` — và 1
case-item không thể chạm tới).

Tham số đã chọn để **công bằng với 3 lõi đang có** (lý do từng dòng nằm
trong comment của chính 2 file `.tcl`):

| Tham số | Giá trị | Lý do |
|---|---|---|
| `ENABLE_MUL`/`ENABLE_DIV`/`ENABLE_PCPI` | 0 | khớp quy ước "RV32M=0" đã áp cho cả 3 lõi kia |
| `COMPRESSED_ISA` | 0 | không có decoder nén — **tắt được HOÀN TOÀN** (khác Ibex, nơi buộc phải giữ `RV32Zca` tối thiểu) |
| `ENABLE_IRQ` | 0 | không lõi nào trong 3 lõi hiện có dùng ngắt |
| `BARREL_SHIFTER` | **1** | ⚠️ mặc định của PicoRV32 là 0 (shift 1 bit/chu kỳ, tối đa 32 chu kỳ/lệnh shift) — **bắt buộc bật** để so chu kỳ công bằng với RISSP/RV32I/Ibex (đều shift 1 chu kỳ) |
| `ENABLE_COUNTERS`/`64` | 0 | firmware hiện tại không dùng CSR cycle/instret |

**Kết quả** (`util_picorv32_default.rpt` / `util_picorv32_fair.rpt`):

| | Slice LUT | LUT as Logic | LUT as Memory (LUTRAM) | FF | BRAM | DSP |
|---|---:|---:|---:|---:|---:|---:|
| **default strategy** | **916** | 868 | 48 | 436 | 0 | 0 |
| **AreaOptimized_high + opt ExploreArea** | **866** | 818 | 48 | 436 | 0 | 0 |

48 LUT LUTRAM = register file nội bộ (`picorv32_regs`, dual-port) — đã tính
gộp trong con số trên (không cần cộng thêm, giống cách RISSP tính
`register_file` vào tổng).

### So với 3 lõi đã có (cùng phương pháp đo standalone/OOC)

| Lõi | LUT (default) | LUT (AreaOpt) | FF |
|---|---:|---:|---:|
| RISSP | 1152 | 1001 | 170 |
| RV32I (nguyên trạng, còn `DONT_TOUCH`) | 1626 | 1625 | 1663 |
| RV32I (đã gỡ khoá) | 1204 | 975 | 671 |
| Ibex (`ibex_axi_top`, đo hierarchy/routed — khác phương pháp) | ~2437* | — | 1841 |
| **PicoRV32 (`picorv32` core, CHƯA cộng wrapper)** | **916** | **866** | **436** |

\* Ibex đo bằng hierarchy-extraction post-route, không phải OOC standalone —
xem cảnh báo phương pháp trong CLAUDE.md mục "TÍNH CÔNG BẰNG". Số PicoRV32
ở đây **là OOC standalone**, so trực tiếp được với cột RISSP/RV32I.

⚠️ Con số PicoRV32 **chưa cộng phần glue của wrapper** (`picorv32_axi_top.v`
— FSM tách imem/dmem, tương đương phần `axi_rissp_master.v` ~20 LUT hoặc
phần "coordinator" `modular_ex` ~193 LUT của RISSP). Dựa trên độ phức tạp
của wrapper (chỉ 2 thanh ghi 1-bit + vài mux), ước tính cộng thêm **dưới 50
LUT** — chưa đo thật, sẽ đo khi có checkpoint SoC.

**PicoRV32 đã là lõi NHỎ NHẤT trong 4 lõi**, kể cả trước khi cộng wrapper —
đáng chú ý cho paper vì đây chính là mục đích thiết kế gốc của nó ("optimized
for size"). Đánh đổi: kiến trúc FSM nhiều chu kỳ/lệnh (không single-cycle,
không pipeline) — dự đoán **sẽ chậm hơn cả 3 lõi kia** về số chu kỳ, kể cả
RV32I 5-tầng. Đây là điểm dữ liệu quan trọng cho câu chuyện Pareto (diện
tích ↔ hiệu năng) của paper — **chưa đo thật vì chưa có RTL wrapper elaborate
với firmware**, chỉ là suy luận từ kiến trúc.

## 4. Wrapper đã viết — `picorv32_axi_top.v` (đã elaborate sạch, CHƯA mô phỏng chức năng)

Instantiate thẳng `picorv32` (không dùng `picorv32_axi` có sẵn, vì wrapper
đó gộp chung imem+dmem qua 1 cổng AXI — sẽ mất khả năng tách private-ROM
fetch nhanh như 3 lõi kia). Logic:
- Nhánh imem: FSM 1 thanh ghi (`imem_pending`), đúng mẫu `picosoc.v` gốc.
- Nhánh dmem: **dùng thẳng `axi_rissp_master.v` không sửa 1 dòng nào** —
  `core_mem_ready` phía dmem lấy từ cạnh xuống của `stall_cpu` (đúng gợi ý
  trong comment sẵn có của chính module đó).

Đã verify bằng công cụ thật (không suy đoán):
```
xvlog picorv32.v axi_rissp_master.v picorv32_axi_top.v   → 0 lỗi
xelab picorv32_axi_top -s picorv32_top_snap              → build snapshot OK
```
(1 warning vô hại: cổng debug `trace_valid` của lõi không nối — tính năng
trace không dùng tới, giống warning PCPI ở bước synth.)

## 5. Việc còn lại để có số liệu SoC thật (chưa làm, ước lượng độ lớn theo kinh nghiệm Ibex/CVA6)

1. **Mô phỏng chức năng** — viết testbench kiểu `tb_ibex_ecb.v` (model BRAM
   imem hành vi + model AXI slave AES/SHA3/RSA hành vi), chạy `hash`/AES
   firmware `.coe` có sẵn (dùng chung với 3 lõi kia, không cần soạn mới) qua
   `picorv32_axi_top.v`, verify PASS trước khi tin bất kỳ số chu kỳ nào.
2. **Đóng gói IP Vivado** — dự kiến **dễ hơn Ibex/CVA6**: `picorv32.v` là
   Verilog-2001 thuần, không dùng macro tham số mặc định kiểu lowRISC
   `` `ASSERT`` (nguyên nhân chính gây lỗi packaging của Ibex) và không có
   `` `ifndef SYNTHESIS``/kiểu tham số struct/package-scoped như CVA6 — rủi ro
   packaging thấp, nhưng **chưa thử thật nên chưa chắc chắn**.
3. **Dựng `PicoRV32_SoC`** — tái dùng `design_1_exported.tcl` của `Ibex_SoC`
   làm khuôn (đã có sẵn, xem CLAUDE.md mục CVA6 § 7 — cùng cách đã dùng để
   định hướng cho CVA6_SoC), đổi CPU + thêm ROM imem 8192×32 riêng (không
   cần AXI slave BRAM như CVA6 vì có `mem_instr` tách sẵn).
4. **Firmware/testbench 8 workload** — dùng chung 100% `.coe` với 3 lõi kia
   (địa chỉ AXI giống hệt, không có boot-offset lệch).
5. **Synth + Impl thật** để lấy Power/WNS/fmax/LUT-FF toàn SoC.

## 6. Kết luận khả thi

**Khả thi cao, khả thi hơn cả Ibex và CVA6 lúc mới bắt đầu** — nhờ 3 lý do
đã verify bằng công cụ thật (không suy đoán): (a) file nguồn tối giản, giấy
phép thoáng; (b) có sẵn tín hiệu `mem_instr` khớp thẳng kiến trúc
imem-riêng/dmem-qua-AXI đã dùng cho 3 lõi kia — tái dùng nguyên xi
`axi_rissp_master.v`; (c) không có boot-offset ẩn như Ibex. Rủi ro còn lại
nằm ở bước đóng gói IP (chưa thử) và ở việc lõi FSM nhiều chu kỳ/lệnh có
thể cho số chu kỳ rất cao (đổi lại LUT nhỏ nhất) — cả 2 điều này chỉ trả lời
được bằng cách làm tiếp bước 5 mục 5, không suy đoán thêm được nữa.
