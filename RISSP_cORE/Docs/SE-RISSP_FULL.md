# SE-RISSP_FULL — SoC RISSP + AES + RSA + SHA3 (project "ULTRA")

Ghi lại những gì đã quét được từ project Vivado thật tại
`F:\advance_topic\SE-RISSP_AES_ULTRA` (2026-08-10). Đây là project **khác**
với `SE-RISSP-SHA3` (bản đã bỏ AES/RSA, dùng cho hướng "hash the image" ở
`f:\RISSP_cORE\CLAUDE.md`) — project này giữ **đủ cả 3 lõi crypto** cùng
RISSP trong 1 SoC, đúng tên "ULTRA". Không phải git repo, chỉ là thư mục
project Vivado (`.xpr` + `.srcs`/`.gen`/`.runs`/...).

## 1. Kiến trúc Block Design (`design_1`)

Device: **xc7z020clg484-1** (Zynq-7020), board part
`digilentinc.com:zedboard:part0:1.0` → **target là ZedBoard**.

```
clk_in1_0 (100MHz ext) ──► clk_wiz_0 ──► clk_out1 = 40MHz ──► toàn bộ logic
reset_0 ──► proc_sys_reset_0 ──► peripheral_aresetn (active-low, dùng chung)

rissp_top_0 (RISSP core, AXI4 master "m_axi")
  │
  └──► axi_interconnect_0 (crossbar 1×4, NUM_MI=4)
         ├─ M00 ──► aes_axi_slave_0   @ 0x40000000, 16K
         ├─ M01 ──► SHA3_hardware_new_0 @ 0x44000000, 64K  (qua S01_AXI)
         ├─ M02 ──► RSA_mark03_0     @ 0x48000000, 64K  (qua S00_AXI)
         └─ M03 ──► axi_bram_ctrl_0 ──► blk_mem_gen_1 @ 0xC0000000, 8K
                     (BRAM dữ liệu debug, 32-bit addressing, dùng axi_bram_ctrl chuẩn)

rissp_top_0.imem_addr ──► xlslice_0 (bit [14:2], lấy word-addr) ──► blk_mem_gen_0.addra
blk_mem_gen_0.douta ──► rissp_top_0.imem_rdata
  (imem: Single_Port_ROM riêng, KHÔNG qua AXI — đúng kiến trúc RISSP: chỉ
  fetch được từ imem, không LW/SW được vào imem)
```

**Bản đồ địa chỉ AXI** (nhìn từ `rissp_top_0/m_axi`, đọc trực tiếp từ
`design_1.bd`, phần `addressing`):

| Peripheral | Base | Size | Ghi chú |
|---|---:|---:|---|
| `aes_axi_slave_0` | `0x40000000` | 16K | AXI4 slave riêng (không phải AXI4-Lite template) |
| `SHA3_hardware_new_0` (S01_AXI) | `0x44000000` | 64K | AXI4-Lite, 64 thanh ghi 32-bit (offset 0–252), template driver chuẩn Xilinx |
| `RSA_mark03_0` (S00_AXI) | `0x48000000` | 64K | AXI4-Lite, 4 thanh ghi 32-bit (offset 0–12) |
| `axi_bram_ctrl_0` (BRAM debug) | `0xC0000000` | 8K | Single-port BRAM qua `axi_bram_ctrl` chuẩn |

> Lưu ý: đây là **địa chỉ 4-master** (giống bản gốc trước khi
> `SE-RISSP-SHA3`/`SE-RISSP_AES_ULTRA` (bản thu gọn 2-master) tách riêng —
> SHA3 ở đây vẫn là `0x44000000`, KHÔNG phải `0x44A00000` như bản thu gọn đã
> ghi trong `CLAUDE.md`. Đừng nhầm 2 project.

**IP repo paths** (từ `.xpr`, `IPRepoPath`):
- RISSP core: `d:/SE_RISSP_LIBRARY/RISSP_CORE_NEW`
- AES: `D:/SE_RISSP_LIBRARY/AES_NEOS`
- SHA3: `d:/SE_RISSP_LIBRARY/SHA_3/SHA3_hardware_new_1_0`
- RSA: `$PPRDIR/../RSA_mark03` (tương đối, khả năng `F:\advance_topic\RSA_mark03`)

**Không có file `.xdc` do người dùng tạo** (chỉ có `.xdc` tự sinh từ IP
`clk_wiz`/`proc_sys_reset` cho ràng buộc clock nội bộ) — nghĩa là **chưa gán
pin vật lý nào cho ZedBoard** (LED/switch/UART/nút bấm...). Muốn chạy trên
board thật phải tự thêm constraint pin trước.

## 2. Trạng thái flow Vivado — đã làm tới đâu

- **Synthesis (`synth_1`)**: đã chạy xong (`__synthesis_is_complete__` tồn
  tại), có `design_1_wrapper.dcp`.
- **Implementation (`impl_1`)**: đã chạy hết **opt → place → phys_opt →
  route**, có `design_1_wrapper_routed.dcp`. Log kết thúc sạch, không lỗi.
- **Bitstream: CHƯA chạy** — không có file `.bit` nào trong `impl_1`. Nghĩa
  là design đã "closure" về timing/area nhưng **chưa `write_bitstream`**,
  chưa thể nạp board thật.
- **Simulation: CHƯA có** — thư mục `SE-RISSP_AES_ULTRA.sim` rỗng, không có
  `sim_1`, không có testbench nào trong project. SoC này **chưa từng được
  verify chức năng ở mức toàn hệ thống** (khác hẳn với các SoC trong
  `f:\RISSP_cORE` đã có `tb_soc_hash_lena_512x512.v` PASS thật).

## 3. Số liệu Vivado đo được (post-route, 40MHz)

Nguồn: `design_1_wrapper_utilization_placed.rpt`,
`design_1_wrapper_timing_summary_routed.rpt`,
`design_1_wrapper_power_routed.rpt` (tất cả trong `impl_1`, chạy
2026-08-07).

### Utilization (xc7z020, tổng available: 53200 LUT / 106400 FF / 140 BRAM tile / 220 DSP)

| Resource | Used | Util% |
|---|---:|---:|
| Slice LUTs | **10111** (10064 logic + 47 memory) | 19.01% |
| Slice Registers | **6146** | 5.78% |
| F7/F8 Muxes | 899 / 448 | — |
| Block RAM Tile | **9.5** (9× RAMB36 + 1× RAMB18) | 6.79% |
| DSP48E1 | **11** | 5.00% |
| Bonded IOB | 2 (chỉ `clk_in1_0` + `reset_0`, chưa gán pin nào khác) | — |
| MMCME2_ADV | 1 (clk_wiz) | — |

### Timing (40MHz, period 25ns)

- **WNS = +8.097 ns**, TNS = 0 → **đạt timing thoải mái** ở 40MHz (còn dư
  địa để tăng tần số nếu muốn — chưa thử).
- WHS = +0.020 ns (hold cũng đạt, sát hơn nhiều so với setup — bình thường).
- "All user specified timing constraints are met."

### Power (vector-less activity propagation, Confidence: Medium — chưa có SAIF/VCD thật)

| | W |
|---|---:|
| **Total On-Chip Power** | **0.293** |
| Dynamic | 0.187 |
| Device Static | 0.106 |
| Junction Temperature | 28.4°C |

Phân bổ dynamic power theo hierarchy (`design_1_i`, tổng 0.187W):

| Block | Power (W) | % dynamic |
|---|---:|---:|
| `clk_wiz_0` (MMCM) | 0.106 | 56.7% |
| `SHA3_hardware_new_0` | 0.062 | 33.2% |
| `aes_axi_slave_0` | 0.010 | 5.3% |
| `RSA_mark03_0` | 0.004 | 2.1% |
| `blk_mem_gen_0` (imem) | 0.003 | 1.6% |
| `rissp_top_0` | 0.001 | 0.5% |
| (interconnect/bram_ctrl_0/blk_mem_gen_1) | không đáng kể, làm tròn 0 | — |

**Quan sát đáng chú ý**: MMCM/clk_wiz chiếm hơn nửa dynamic power — đây là
overhead cố định của việc dùng PLL để chia 100MHz→40MHz, không phải logic
thiết kế. SHA3 là lõi crypto tốn power nhất (hợp lý, chạy Keccak liên tục
nhiều round). RISSP core bản thân **cực rẻ** (0.001W, khớp trực giác vì chỉ
1018 LUT). Số 0.293W này **thấp hơn** con số cũ 0.349W từng ghi trong
`CLAUDE.md` cho SoC SHA3-only — không kết luận vội SoC 4-lõi này "rẻ hơn"
SoC 1-lõi, vì 2 project khác nhau, khác đo lường (vector-less, không cùng
constraint/silicon corner) — cần đo lại cả 2 cùng phương pháp nếu muốn so
sánh công bằng cho paper.

## 4. Register map phần mềm (driver header tự sinh, generic AXI4-Lite template)

- `RSA_mark03`: 4 thanh ghi 32-bit, offset `0x0/0x4/0x8/0xC` (`RSA_mark03.h`).
- `SHA3_hardware_new`: 64 thanh ghi 32-bit, offset `0x0..0xFC`
  (`SHA3_hardware_new.h`).
- `aes_axi_slave`: **không thấy driver `.h` được sinh** trong
  `mem_init_files` — khả năng là AXI4 slave tự viết tay (không dùng AXI4-Lite
  template chuẩn của Vivado IP packager) nên không tự sinh header theo cùng
  cách. Cần mở trực tiếp RTL `aes_axi_slave` (trong `AES_NEOS` IP repo) để
  biết register semantics thật nếu cần viết firmware.
- Các header trên chỉ là **macro offset generic** (`mWriteReg`/`mReadReg` +
  `SelfTest` rỗng) — không mô tả ý nghĩa từng thanh ghi (CTRL/STATUS/DATA...).
  Semantics thật phải đọc RTL nguồn (`*_S_AXI` case trong mỗi `_axi_slave`/
  `S00_AXI` module).

## 5. ⚠️ Rủi ro đã biết cần kiểm tra trước khi tin SoC này "chạy đúng"

**Nghi vấn nghiêm trọng nhất — imem có thể đang bị đúng bug đã gặp ở project
khác**: đã xác nhận trong `[[project-soc-pc-insn-desync-bug]]` (memory,
project `Hashing_image`) rằng `fetch_stage.v` của RISSP **bắt buộc** imem
phải có **latency đọc đúng 1 chu kỳ**, và nếu Vivado bật
`Register_PortA_Output_of_Memory_Primitives = true` cho `blk_mem_gen_0`
(imem) thì latency thành 2 chu kỳ → `insn` trễ pha so với `pc` → **mọi
branch/jump tính sai target**, code thẳng dòng thì vẫn chạy đúng (dễ đánh
lừa) nhưng bất kỳ `beq/bne/blt/.../jal/jalr` nào cũng sai.

**Đã kiểm tra trực tiếp file `.xci` của `blk_mem_gen_0` trong project
`SE-RISSP_AES_ULTRA` này**:
```
"Register_PortA_Output_of_Memory_Primitives": [ { "value": "true", ... } ]
```
→ **Đúng y hệt cấu hình gây bug đã tìm thấy ở project khác.** Nhiều khả năng
SoC "ULTRA" này đang mắc **cùng 1 bug pc/insn desync**, và vì project chưa
có testbench/simulation nào (mục 2), bug này **chưa từng được phát hiện ở
đây**. Nếu firmware dự định chạy trên SoC này có bất kỳ nhánh rẽ nào (gần
như chắc chắn có, vì mục đích là điều phối cả AES+SHA3+RSA — cần if/loop),
khả năng cao sẽ treo/sai y hệt kịch bản đã debug trước đó.

**Cách sửa (đã biết, không cần đổi RTL)**, nếu xác nhận đúng là bug này:
```tcl
set_property -dict [list CONFIG.Register_PortA_Output_of_Memory_Primitives {false}] [get_bd_cells blk_mem_gen_0]
```
rồi Validate Design + Generate Output Products + re-run synth/impl.

## 6. Việc còn thiếu để gọi SoC này "hoàn chỉnh" theo nghĩa có thể trình bày

1. **Xác nhận/sửa bug imem latency ở mục 5** — ưu tiên cao nhất, làm trước
   mọi thứ khác vì nó quyết định firmware có chạy đúng hay không.
2. **Chưa có testbench SoC nào** — cần ít nhất 1 testbench tự viết (theo
   đúng pattern đã dùng ở `f:\RISSP_cORE` cho SHA3: behavioral AXI4-Lite
   model cho từng peripheral + instantiate `design_1`/`rissp_top` thật) để
   verify CPU thực thi đúng qua cả 3 lõi crypto, không chỉ "synth sạch".
3. **Chưa có firmware/chương trình cụ thể** nào được xác nhận sẽ chạy trên
   SoC 4-lõi này (khác với `firmware_HashImage`/`firmware_OTA` viết cho các
   biến thể SoC khác, địa chỉ AXI không khớp — SHA3 base ở đây là
   `0x44000000` không phải `0x44A00000`, và ở đây còn có AES+RSA thật cần
   điều phối, không chỉ SHA3).
4. **Chưa `write_bitstream`**, chưa nạp thử board ZedBoard thật, **chưa gán
   pin XDC nào** (không có LED debug, không UART ra ngoài để quan sát kết
   quả trên board thật).
5. **Chưa đo lại power bằng activity thật** (hiện tại "Confidence: Medium",
   vector-less estimate) — nếu cần số power đáng tin cho paper, nên tạo SAIF
   từ 1 lần simulation thật (sau khi có testbench ở mục 2) rồi
   `report_power -sim_output` mới đáng tin hơn.
6. Chưa rõ **register semantics thật** của `aes_axi_slave` (mục 4) — cần đọc
   RTL gốc trước khi viết firmware điều khiển AES.

## 7. Vì sao đáng lưu ý so với các SoC khác trong `f:\RISSP_cORE`

SoC trong `f:\RISSP_cORE/CLAUDE.md` (project `SE-RISSP-SHA3` /
`Hashing_image`) đã đi xa hơn nhiều về mặt **verify chức năng** (testbench
full-SoC PASS thật với ảnh Lena 512×512, đã tự tìm và sửa đúng bug imem
latency này). SoC "ULTRA" ở `F:\advance_topic\SE-RISSP_AES_ULTRA` lại đi xa
hơn về mặt **độ đầy đủ phần cứng** (đủ cả AES+RSA+SHA3, không chỉ SHA3) và
đã có **số liệu Vivado thật sau route** (LUT/power/timing ở mục 3) — nhưng
**chưa được verify chức năng** và **nhiều khả năng dính bug đã biết**. Hai
project bổ sung cho nhau: kỹ thuật sửa bug + cách viết testbench đã có sẵn
từ bên kia, chỉ cần áp dụng lại cho project này.
