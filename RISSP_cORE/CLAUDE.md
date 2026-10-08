# RISSP_CORE

Lõi RV32I single-cycle (không pipeline), kiến trúc "modular execution": mỗi
instruction type (R/I/B/J/U/S) có một hardware block **độc lập, chạy song
song**, kết quả được chọn qua mux theo opcode trong `modular_ex.v`. Đây là
triết lý cốt lõi của paper.

**3 ngoại lệ đã xác nhận với người dùng**: `r_type_block` và `i_type_block`
dùng **chung** 1 barrel shifter (`barrel_shifter.v`), 1 comparator
(`comparator.v`), 1 adder/sub (`alu_adder.v`) — vì 2 dạng lệnh này dùng
chung `rs1_data` làm toán hạng A và chỉ khác toán hạng B (`rs2_data` vs
`imm`). Đây là 3 nhượng bộ **duy nhất** của kiến trúc song song; phần
bitwise (XOR/OR/AND) và toàn bộ 4 block B/J/U/S vẫn 100% độc lập như paper
mô tả — cố tình dừng lại ở đây, không gộp thêm bitwise vì sẽ biến 2 block
thành lớp vỏ mỏng trên 1 ALU chung hoàn toàn (phương án đã bị từ chối).

`register_file` là khối riêng biệt, đứng **ngoài** modular_ex theo sơ đồ
paper (chỉ nhận `rs1_addr/rs2_addr/rdest_addr/rdest_data/wen`, trả về
`rs1_data/rs2_data`), không có quan hệ logic nào với các type-block hay với
3 khối dùng chung ở trên.

## HƯỚNG PAPER HIỆN TẠI — đọc mục này trước khi làm gì khác

Repo này giờ phục vụ 1 paper cụ thể (tiêu đề gốc: *"An Application-Specific
RISSP-Based SoC for Secure Edge Computing with Performance Evaluation
against RISC-V"*), đã pivot qua vài giai đoạn — xem `Docs/PaperStrategy.md`
để có chiến lược đầy đủ (tần số mục tiêu, ứng dụng từng crypto, hướng tạo
tính mới, venue khuyến nghị, baseline core khuyến nghị). Mục này chỉ tóm
**trạng thái mới nhất** để phiên chat mới không phải đọc lại từ đầu.

> 🧭 **ĐỌC THEO THỨ TỰ NÀY nếu mới vào phiên chat**:
> 1. **§ wolfSSL THẬT TRÊN BARE-METAL** — nhánh dùng thư viện production
>    thật (wolfSSL) thay code AES/SHA3/RSA tự viết. **Cả 3/3 lõi
>    (RISSP/Ibex/RV32I) đã PASS 100%** AES-128 + SHA3-256 + RSA-2048, có
>    bảng chu kỳ đầy đủ + phân tích độ tin cậy/đối chiếu literature. Đây là
>    nguồn số liệu software-only DUY NHẤT còn giữ lại (nhánh tự viết tay cũ
>    đã bị xoá khỏi tài liệu này — xem quyết định đã chốt cuối file).
> 2. **§ TIẾN ĐỘ HIỆN TẠI** — trạng thái + toàn bộ số liệu đang có hiệu lực
>    (nhánh HW accelerator gốc — AES/SHA3/RSA qua 3 IP phần cứng, số liệu
>    CHÍNH của paper).
> 3. **§ TRẠNG THÁI IBEX** — số liệu Ibex đầy đủ (nhánh HW accelerator gốc).
> 4. **§ CÔNG THỨC** và **§ CƠ SỞ ĐO** — quy ước tính toán, phải giữ nguyên.
> 5. **§ BẢN SAO GITHUB** — repo private chứa toàn bộ project để mở ở máy
>    khác + 4 phát hiện trạng thái thật (IP RV32I rev 1 vs 2...).
>
> Mọi mục còn lại là **lịch sử/tham khảo**. Các con số chu kỳ và power ghi
> trong phần lịch sử (trước mục "TIẾN ĐỘ HIỆN TẠI") đều đo TRƯỚC khi sửa
> `axi_rissp_master.v` (2026-08-13) nên **đã hết hạn** — đừng trích vào paper.

## ☁️ BẢN SAO GITHUB ĐỂ MỞ Ở MÁY KHÁC (2026-10-08)

Repo **private**: `https://github.com/thanhtruong332/RISSP-Paper-Vivado`
(chỉ chủ repo + collaborator được mời xem được — GitHub không có chế độ
"ai có link thì vào"). Bản làm việc liên kết với remote: `D:\RISSP_GH`.

**Nội dung**: 6 project Vivado (3 SoC chính `SE-RISSP_AES_ULTRA`/
`RV32I_soc_ULTRA`/`Ibex_SoC` + 3 SoC wolfSSL `RISSP_software`/
`RV32I_software`/`Ibex_software`), 6 IP repo (`SE_RISSP_LIBRARY/
{RISSP_CORE_NEW,AES_NEOS,SHA_3/SHA3_hardware_new_1_0}`, `RSA_mark03`,
`RV32I_FIXED`, `Ibex_Core`), `firmware_testbench/{SE-RISSP,RV32I,Ibex}_FULL`
(mọi `.coe` + testbench — **trên repo đổi tên `Viettel_semi` → `firmware_testbench`**
theo yêu cầu người dùng; máy gốc vẫn là `D:\Viettel_semi`), board file ZedBoard, phần `RISSP_cORE` có trong
tài liệu này (RTL, Docs, wolfSSL build + source đã vá). **Không** đưa
`.runs/.sim/.cache`, bitstream, log (người dùng tự chạy lại synth/impl).
Giữ nguyên cây thư mục máy gốc ở gốc repo nên đường dẫn `$PPRDIR/../..`
sẵn có vẫn đúng. **Bản gốc trên máy này không bị sửa gì** — mọi chỉnh sửa
chỉ làm trên bản sao.

**Chỉnh sửa trong bản sao để chạy được ở máy khác**: đường dẫn tuyệt đối
`d:/SE_RISSP_LIBRARY`, `d:/Viettel_semi` (→ `firmware_testbench/`), board XHub → tương đối (cả trong
`.xpr`, `.bd`, `.xci`, `.gen/.../design_1_blk_mem_gen_0_0.xml`); gỡ tham
chiếu file của nhánh tự-viết-tay đã xoá khỏi 3 project wolfSSL;
`RISSP_software`/`Ibex_software` đổi `.coe` sang `rissp_wolfssl.coe` (qua
`set_property`, không sửa text — sửa text làm IP khoá "stale content");
`Ibex_FULL/run_manual_sim.tcl` + `run_all.bat` tính đường dẫn theo vị trí
script.

**Kiểm chứng trên bản clone ở đường dẫn khác** (đã đối chiếu tree hash
bản trên GitHub trùng khít): 6/6 project mở được, 0 file thiếu, 0 file trỏ
ra ngoài repo · `tb_sha3` RISSP PASS 492 ck · `tb_ibex_rsa2048` PASS
320974 ck · `tb_ibex_ecb` (script tay) PASS 90 ck · `tb_rv32i_rsa2048`
PASS 321039 ck · RV32I_soc_ULTRA Run Synthesis Complete 0 error — số chu kỳ
khớp đúng bảng § TIẾN ĐỘ HIỆN TẠI.

**4 phát hiện mới về trạng thái THẬT trên máy gốc** (không phải do bản sao):
1. `RV32I_soc_ULTRA` dùng IP `rv32i_fixed` **revision 1** (trước sửa SRA),
   IP repo đã lên **revision 2** → IP hiện "locked – different revision",
   validate BD báo lỗi; vẫn mô phỏng + synthesis được bằng output đã sinh.
   `RV32I_software` dùng revision 2. Xác nhận lại đúng mục "chưa áp dụng
   bản sửa SRA cho SoC chính" — **đừng Upgrade IP** nếu muốn giữ số paper.
2. `Ibex_SoC.xpr` còn 56 tham chiếu sim tới `ipshared/7317/` không tồn tại
   (sót từ trước khi đóng gói lại IP). Đã gỡ trong bản sao.
3. `Ibex_FULL/run_manual_sim.tcl` gốc **đang hỏng**: tìm 56 file `.sv` lẻ
   trong `Ibex_Core/ip_repo/src`, nhưng sau khi đóng gói lại IP chỉ còn
   `ibex_axi_top_combined.sv`. Bản sao đã vá (dùng file gộp) → PASS.
4. Flow `export_simulation` cho Ibex **bỏ qua** define `SYNTHESIS` đặt
   trong sim fileset → DPI-C của lowRISC bật → xelab lỗi biên dịch C. GUI
   Run Simulation không bị (tự dùng define); flow dòng lệnh phải thêm
   `xvlog -d SYNTHESIS`.

Thư mục tạm có thể xoá: `D:\RISSP_GH_test`, `D:\RISSP_GH_t2`,
`D:\RISSP_GH_t3`, `D:\RISSP_GH_fromgithub` (bản clone kiểm chứng).

## 🔐 wolfSSL THẬT TRÊN BARE-METAL — thay code tự viết bằng thư viện production

**Bối cảnh**: theo gợi ý mentor, thay AES/SHA3/RSA tự viết ở nhánh "phần
mềm thuần" bằng thư viện wolfSSL thật (`github.com/wolfSSL/wolfssl`) để số
liệu thuyết phục hơn cho paper. Clone tại
`F:\RISSP_cORE\firmware_SW_Crypto\wolfssl_src\`, cấu hình tối giản tại
`firmware_SW_Crypto\wolfssl_build\` (chỉ bật AES-ECB/CBC/CFB/CTR + SHA3-256
+ RSA-2048 công khai).

### 3 lớp bug thật đã tìm ra & vá khi đưa wolfSSL vào SoC bare-metal (không sửa RTL)

1. **`.rodata` rơi vào vùng ROM fetch-only** — wolfSSL khai báo bảng tra
   cứu (S-box AES, hằng số vòng SHA3...) bằng `static const`, mà `.rodata`
   nằm chung địa chỉ với `.text` (chỉ đọc được qua fetch, không đọc bằng
   `lw`). **Vá**: chuyển mọi bảng sang khởi tạo runtime, đổi
   `WOLFSSL_AES_SMALL_TABLES` (Sbox 256B thay T-table 4KB). Bẫy phụ: GCC
   vẫn "constant-pool" literal 64-bit vào `.rodata` dù đã runtime-init —
   phải ghi từng nửa 32-bit qua con trỏ `word32*` để né.
2. **Kích thước code vượt ROM 32KB** — vá bằng `-Os`, `--gc-sections`,
   `NO_AES_DECRYPT`, `WOLFSSL_SP_NO_3072/4096`. Kết quả cuối: `.text=20512
   byte, .bss=3124 byte`.
3. **🔴 Bug RISSP thật chưa từng biết trước đây**: `lh`/`lhu` bị RISSP bỏ
   qua hoàn toàn, luôn trả về 0 âm thầm (đã ghi lý thuyết từ lâu trong
   `rissp_instruction.md` nhưng đây là lần đầu thực sự làm hỏng 1 tính
   toán thật — `sp_size_t`, kiểu đếm digit big-int của wolfSSL, mặc định
   16-bit nên đọc `lhu` ra 0 → RSA fail `BAD_FUNC_ARG`). **Vá**: ép
   `sp_size_t` luôn 32-bit trong `sp_int.h`. Verify bằng `objdump` xác
   nhận 0 lệnh `lh`/`lhu` sót lại.

**⚠️ Bài học cho mọi lần đưa thư viện ngoài vào 3 lõi này sau này**: danh
sách lệnh cấm cũ (`lb/lbu/sb/lh/lhu/sh/csrr/csrw/mul/div/rem/ecall/ebreak/
fence`) được viết để né bug RV32I, nhưng `lh`/`lhu` **còn nguy hiểm hơn
trên chính RISSP** (RV32I ít nhất đọc nhầm thành `lw`; RISSP bỏ qua hoàn
toàn, luôn ra 0). Với thư viện ngoài, struct nội bộ có thể chứa field
16-bit ở bất kỳ đâu — **bắt buộc `objdump` toàn bộ binary cuối cùng, xác
nhận rỗng cho cả `lh`/`lhu`** (không chỉ `lb`/`sb`), bất kể lõi đích.

### Vị trí file

- `F:\RISSP_cORE\firmware_SW_Crypto\wolfssl_src\` — clone wolfSSL (đã sửa
  `wolfcrypt/src/aes.c`, `wolfcrypt/src/sha3.c` vá `.rodata`;
  `wolfssl/wolfcrypt/sp_int.h` vá bug `lh`/`lhu`).
- `F:\RISSP_cORE\firmware_SW_Crypto\wolfssl_build\` — `user_settings.h`,
  `rissp_main.c` (firmware AES+SHA3+RSA), `tb_isolate_wolfssl_{rissp,ibex,
  rv32i}.v` (testbench RTL cô lập), `rsa2048_vectors.h`.
- Toolchain: `F:\xpack-riscv-none-elf-gcc-15.2.0-1\bin\`, build với
  `-march=rv32i2p1 -mabi=ilp32 -Os -ffunction-sections -fdata-sections`,
  link `-nostartfiles -T link_sw.ld --gc-sections -specs=nano.specs -lc
  -lgcc` (an toàn: `-march=rv32i` không sinh opcode `mul`/`div` thật).

### Bug thật khi đưa wolfSSL sang RV32I (ngoài 3 bug ở trên, KHÔNG sửa RTL)

1. **Ghi bảng/khởi tạo từng byte** (`Tsbox[i]=val`, an toàn trên RISSP)
   trúng bug WSTRB của RV32I (ghi byte thành ghi cả 4 byte) → phá dữ liệu
   lân cận. **Vá**: đóng gói 4 byte/lần, ghi 1 lệnh `sw`.
2. **`GetTable8`** (tra Sbox AES) — wolfSSL tự bật
   `WOLFSSL_AES_TOUCH_LINES` cho mọi `__riscv`, đọc 16 vị trí thay vì 1.
   **Vá**: tắt bằng `WC_NO_CACHE_RESISTANT`, định nghĩa lại macro gọi hàm
   `aes_safe_byte()` (đọc cả word qua `lw` rồi tách byte).
3. **`sp_read_unsigned_bin`/`sp_2048_from_bin`/`sp_c32.c`** (nạp/xuất số
   lớn RSA-2048) đọc/ghi từng byte gốc. **Vá**: `sp_int.c` gộp thành đọc
   word; `sp_c32.c` (digit 29-bit, không gộp được) thêm 3 hàm an toàn
   `sp_c32_safe_byte/safe_set_byte/safe_or_byte`.

**🎯 Nghi vấn treo máy RV32I ban đầu — đã xác nhận: bug nằm ở TESTBENCH CÔ
LẬP tự viết, không phải RTL hay wolfSSL.** Debug bằng cách in PC mỗi chu
kỳ phát hiện lặp vô hạn ngay sau `jal ra, main`, trước cả hoạt động AXI
đầu tiên. Đã tự kiểm RTL giải mã J-type (đúng chuẩn RISC-V, không phải bug
decode) → kết luận mô hình imem hành vi đơn giản hoá trong testbench tự
viết không khớp timing 1-chu-kỳ-trễ chính xác mà `rv32i_top.v` đã được sửa
riêng để hoạt động đúng với `blk_mem_gen` thật. **Xác nhận bằng thực
nghiệm quyết định**: dựng lại simulation trên SoC Vivado chính thức
`RV32I_software` (IP Xilinx thật) — chạy vượt xa điểm mà testbench cô lập
bị kẹt vĩnh viễn, xác nhận 100% đây là bug testbench.

**Quy trình build SoC chính thức** (đã lưu để tái sử dụng):
`firmware_SW_Crypto/run_rv32i_wolfssl_sw.tcl` — mở project, nạp `.coe`,
`generate_target all` (không chỉ `simulation` — 2 IP `axi_bram_ctrl`/
`proc_sys_reset` sinh VHDL, cần cả `xvhdl -prj vhdl.prj` lẫn `xvlog -prj
vlog.prj`), `export_simulation`, rồi `xelab`+`xsim -R` với đúng `-L`
libraries mà GUI Vivado tự sinh.

### Kết quả cuối cùng — PASS 3/3 lõi

| Lõi | AES-128-ECB | SHA3-256("") | RSA-2048 | Chu kỳ RSA (E2E) |
|---|---|---|---|---:|
| **RISSP** | ✅ PASS | ✅ PASS | ✅ PASS | 129.863.522 |
| **Ibex** | ✅ PASS | ✅ PASS | ✅ PASS | 141.286.544 (+8,80% so RISSP) |
| **RV32I** | ✅ PASS | ✅ PASS | ✅ PASS | 171.849.315 (+32,34% so RISSP), đo trên SoC Vivado chính thức `RV32I_software` |

**Cả 3/3 lõi đã xong (2026-08-26)** — PASS tuyệt đối AES-128-ECB (FIPS-197)
+ SHA3-256("") (hashlib) + RSA-2048 (`pow(M,65537,N)` Python) trên RTL
thật, cùng 1 file `.hex`/`.coe` cho cả 3. RV32I chậm hơn RISSP nhiều hơn
hẳn thông lệ cũ của bản RSA tự viết tay (~5-7%) — khớp đúng tỉ lệ +25-30%
đã thấy ở AES/SHA3 trong nhánh wolfSSL (bảng dưới), vì các hàm "safe-byte"
tốn thêm chỉ lệnh đáng kể mà RISSP/Ibex không cần. Ibex vẫn nằm giữa RISSP
và RV32I như xuyên suốt dự án.

⚠️ **Sự cố vận hành đáng ghi lại**: lần chạy đầu của RV32I (2026-08-25
09:13) bị chết âm thầm giữa chừng (process `xsim.exe` biến mất, log dừng
ngay sau START marker, không `$finish`, không crash log) do phiên làm việc
bị gián đoạn qua đêm — đã chạy lại thành công lần 2 (2026-08-26 08:24,
6h54min wall-clock). **Bài học**: theo dõi tiến độ các lần đo nhiều-giờ
bằng `tasklist` kiểm tra `xsim.exe` còn sống, không chỉ tin log đứng yên
(log có thể đứng yên nhiều giờ do buffering bình thường khi process vẫn
chạy — chỉ coi là "chết" khi process đã biến mất VÀ log không có `$finish`).

**AES-4-mode + SHA3-3-size, PURE cycles** (`aes_sha3_multi.c`, PASS 17/17 cả 3 lõi):

| Workload | RISSP | Ibex | RV32I |
|---|---:|---:|---:|
| AES-128 ECB | 9.917 | 10.623 | **12.621** |
| AES-128 CBC | 10.333 | 11.075 | **13.214** |
| AES-128 CFB | 10.365 | 11.114 | **13.262** |
| AES-128 CTR | 10.802 | 11.579 | **13.846** |
| SHA3-256 (1 block) | 31.916 | 32.698 | **40.502** |
| SHA3-256 (4 block) | 119.915 | 121.423 | **150.938** |
| SHA3-256 (16 block) | 471.911 | 476.323 | **592.682** |

Đúng thứ tự RISSP < Ibex < RV32I đã thấy xuyên suốt cả dự án (single-cycle
< pipeline 2 tầng < pipeline 5 tầng).

**2 bug testbench thật khác tìm ra khi lấy số chu kỳ này**
(`D:\Viettel_semi\RV32I_FULL\tb_aes_sha3_multi.v`): mảng snoop `m[]` dùng
slice địa chỉ 5-bit không đủ biểu diễn index marker DONE (đã sửa `[6:2]`→
`[7:2]`); khối bắt mốc PURE thiếu điều kiện giới hạn địa chỉ nên bắt nhầm
hàng chục nghìn lần ghi bảng khởi tạo AES vào chu kỳ đo (đã thêm lại guard
`bram_addr < 13'd136`).

### 🎯 Bug RTL thật trong RV32I, chưa từng biết trước đây — SRA tính sai thành logic-shift

**Bug**: `ALU.v` (`F:\advance_topic\RV32I_FIXED\ip_repo\rv32i_fixed_1_0\src\`),
dòng SRA: `4'b1011: ALU_result = $signed(A) >> B[4:0];` — trong Verilog
`>>` **luôn luôn** là dịch logic bất kể ép `$signed()`, phải dùng `>>>`.
Kết quả: SRA trên RV32I âm thầm hoạt động y hệt SRL — cùng loại bug RISSP
từng mắc và đã sửa từ đầu dự án, nhưng ở lõi RV32I khác, chưa ai phát hiện
trước đây dù đã dùng RV32I xuyên suốt cả dự án.

**Cách khoanh vùng**: đọc lại key/plaintext thô và round-key đã mở rộng
đều đúng → loại trừ key schedule, khoanh vùng vào MixColumns. Soi objdump
thấy `col_mul` (GF(2⁸) multiply) là hàm DUY NHẤT trong toàn đường AES/SHA3
dùng `srai` (mask branchless `0-(x>>7)`) — khớp tuyệt đối triệu chứng (AES
sai 100%, SHA3 đúng 100%, vì SHA3 chỉ dùng dịch logic).

**Đã sửa**: `ALU.v` đổi `>>`→`>>>`, bump `coreRevision` trong
`component.xml` (không bump thì Vivado giữ cache IP cũ, im lặng bỏ qua),
`update_ip_catalog -rebuild`+`upgrade_ip`+`generate_target all`. Sau khi
sửa: **PASS 17/17 tuyệt đối** trên RV32I.

**⚠️ Ảnh hưởng rộng hơn wolfSSL**: bug ảnh hưởng bất kỳ code C nào dùng
dịch phải số học trên số có dấu khi biên dịch cho RV32I. RSA-2048
(`sp_int.c`/`sp_c32.c`) dùng `srai` ở 13 hàm khác — đã chạy lại RSA từ đầu
với ALU đã sửa (số trong bảng ở trên đã dùng ALU đã sửa).

**⚠️ Phạm vi sửa CHỈ giới hạn ở nhánh wolfSSL**: `RV32I_soc_ULTRA` (SoC
HW-accelerator, dữ liệu CHÍNH của paper) **CHƯA được kiểm tra/sửa**. Nếu
firmware assembly (`.s`) của nhánh HW-accelerator dùng SRA/SRAI ở đâu đó,
số liệu đã báo cáo (bảng "TIẾN ĐỘ HIỆN TẠI", LUT/Power/timing) **cần rà
soát lại** — chưa xác minh. Script refresh IP:
`F:\RISSP_cORE\firmware_SW_Crypto\refresh_rv32i_ip.tcl`.

### 🔍 Vì sao ra đúng những con số này — đã research đối chiếu bên ngoài (2026-08-28)

Đã tổng hợp toàn bộ bảng trên thành 1 artifact có kẻ bảng đầy đủ + research
đối chiếu benchmark crypto embedded đã công bố (link:
`https://claude.ai/code/artifact/41325eae-ad81-4dbf-bf8b-04687987d026`, xem
lại bằng `Artifact action:"read"` nếu cần). Kết luận, **giữ nguyên cho các
lần dùng số liệu này về sau**:

**Đúng thuật toán — tin được tuyệt đối**: đối chiếu độc lập với chuẩn ngoài
(FIPS-197 App.C.1 cho AES, `hashlib.sha3_256` cho SHA3, `pow(M,65537,N)`
Python cho RSA). Thêm lớp bảo đảm: khi testbench cô lập của RV32I bị nghi
ngờ, đã dựng testbench độc lập thứ hai trên SoC Vivado chính thức để đối
chiếu chéo — loại trừ hẳn khả năng "PASS giả" do lỗi mô hình hoá.

**Con số chu kỳ tuyệt đối KHÔNG đại diện cho hiệu năng 1 vi điều khiển
thật** — điểm quan trọng nhất khi trích số liệu này. `RISSP_software`/
`RV32I_software`/`Ibex_software` không có RAM cục bộ — CPU + 1 BRAM debug
8KB qua AXI4-Lite làm toàn bộ RAM kể cả stack. Mỗi truy cập nhớ trả giá
bắt tay AXI trọn vẹn (~4 chu kỳ/lần, "87% thời gian là giao dịch bus không
phải tính toán" — xem § TIẾN ĐỘ HIỆN TẠI). Kiến trúc này dựng **cố ý xấu
về bộ nhớ** để so sánh công bằng 3 lõi CPU (cùng 1 nút thắt cho cả 3),
không phải để mô phỏng "chip thật nhanh cỡ nào".

Quy đổi ra chu kỳ/byte, đối chiếu literature đã công bố:

| Nền tảng | AES-128 (ck/byte) | SHA3-256 16blk (ck/byte) |
|---|---:|---:|
| Cortex-M4 fixslicing (tối ưu nhất công bố) | ~80 | — |
| Cortex-M3 (FELICS / XKCP) | ~113,5 | ~95 |
| Cortex-M0 (XKCP phần mềm thuần) | — | ~144 |
| AVR 8-bit | ~124,6 | — |
| MSP430 16-bit | ~132 | — |
| Motorola 68HC08 (8-bit đời cũ, ~1990s) | ~524 | — |
| **RISSP (dự án này, wolfSSL)** | **619,8** | **217,7** |
| **Ibex (dự án này, wolfSSL)** | **664,0** | **219,7** |
| **RV32I (dự án này, wolfSSL)** | **788,8** | **273,4** |

Nguồn: Schwabe & Stoffelen, *"All the AES You Need on Cortex-M3 and M4"*
(`eprint.iacr.org/2016/714`) · Bernstein & Schwabe, *"Fast Implementations
of AES on Various Platforms"* (`eprint.iacr.org/2009/501`) · Adomnicăi,
*"An update on Keccak performance on ARMv7-M"* (`eprint.iacr.org/2023/773`).

Cả 3 lõi **chậm hơn cả vi điều khiển 8-bit từ thập niên 1990** ở AES (tra
bảng S-box liên tục, mỗi lần tra là 1 giao dịch AXI) nhưng chỉ chậm hơn
Cortex-M0 khoảng 1,5–1,9 lần ở SHA3 (permutation xử lý chủ yếu trên state
giữ trong thanh ghi/stack, ít tra bảng lớn) — bằng chứng: chi phí phụ trội
tỷ lệ với **mật độ truy cập bộ nhớ** của từng thuật toán, không phải do
core "chậm" nói chung.

RSA-2048 rõ nhất: dự án chỉ tính phép khoá công khai e=65537 (17 phép nhân
Montgomery) nhưng vẫn tốn 129,9–171,8 triệu chu kỳ — cùng bậc độ lớn với
benchmark RSA-2048 công bố trên STM32F756/Cortex-M7 có nhân phần cứng,
200MHz (`kb.segger.com/RSA_STM32F756`, ~78,5 triệu chu kỳ, nhiều khả năng
đo phép khoá riêng đầy đủ — nặng hơn phép công khai ~100 lần). Khớp đúng
giả thuyết bus-bound: `sp_int.c`/`sp_c32.c` thao tác số 2048-bit qua mảng
~131 digit, mỗi phép nhân Montgomery chạm bộ nhớ hàng nghìn lần.

**Cách dùng đúng số liệu cho paper**: trích được ngay bảng PASS 3/3 + thứ
hạng tương đối RISSP<Ibex<RV32I (đáng tin, cùng chịu 1 nút thắt bus) + câu
chuyện "2 bug RTL thật tìm ra nhờ chuyển sang thư viện sản xuất thật".
**Không trích** số chu kỳ tuyệt đối làm "hiệu năng crypto phần mềm tham
khảo" — dùng benchmark bên ngoài ở bảng trên cho mục đích đó. Nhánh
wolfSSL nên là dữ liệu phụ (baseline "không có accelerator sẽ chậm cỡ
nào"), không phải số liệu đầu bảng — luận điểm chính vẫn dựa vào nhánh IP
tăng tốc phần cứng (AES 88–320K chu kỳ, xem § TIẾN ĐỘ HIỆN TẠI).

## 📌 TIẾN ĐỘ HIỆN TẠI — nhánh HW-accelerator gốc, số liệu CHÍNH của paper

**Trạng thái**: ✅ **ĐÃ XONG cả 3 lõi RISSP/RV32I/Ibex** — mỗi lõi chạy đủ
8/8 workload thật, đều có Power+LUT+FF+WNS thật từ Implementation. Xem
`Docs/PaperStrategy.md` hoặc § "KẾT QUẢ CUỐI CÙNG" trong "TRẠNG THÁI IBEX"
để có bảng so sánh 3 lõi đầy đủ.

🗑️ **Lõi thứ 4 (CVA6) — đã bỏ hẳn**, người dùng quyết định không dùng nữa
(CVA6 một mình dùng 116,5% LUT của xc7z020, không vừa chip) — xem §
"TRẠNG THÁI CVA6" phía dưới. Đã xoá toàn bộ working directory, không còn
IP/project/RTL nào trên máy.

⚠️ **Mọi số chu kỳ RISSP ghi ở các mục lịch sử phía dưới file này đều ĐÃ
HẾT HẠN** — đo TRƯỚC khi sửa `axi_rissp_master.v`. Số đúng nằm ở bảng
trong mục này.

#### 1. Đã sửa `axi_rissp_master.v` — bỏ 1 chu kỳ lãng phí mỗi giao dịch

Bản cũ chốt kết thúc bằng `write_done_all = aw_done & w_done & b_done`
(3 thanh ghi) → trễ 1 chu kỳ. Chuẩn AXI cấm slave phát `BVALID` trước khi
nhận đủ AW+W, nên bắt tay B đã hàm ý AW/W xong ⇒ chỉ cần chốt theo B (và
R cho đường đọc). Bỏ hẳn 5 thanh ghi cờ.

| | Trước | Sau |
|---|---:|---:|
| `tb_rissp_top` | PASS 43/43 | **PASS 43/43** |
| LUT / FF (OOC, AreaOpt) | 22 / 146 | **15 / 141** |
| Chu kỳ mỗi giao dịch ghi & đọc | 5 | **4** |

Module nhỏ đi chứ không phình. Ibex dùng chung cầu này (`IBEX_CORE/rtl/`).

#### 2. Bảng đối đầu RISSP ↔ RV32I — cơ sở PURE, 40 MHz, đo thật 8/8

| Workload | RISSP | RV32I | Δ | RISSP nhanh hơn | Tách nguyên nhân |
|---|---:|---:|---:|---:|---|
| AES-128 ECB | **88** | 93 | 5 | 5,4% | 5 đọc × 1 |
| AES-128 CBC | **124** | 129 | 5 | 3,9% | 5 đọc × 1 |
| AES-128 CFB | **124** | 129 | 5 | 3,9% | 5 đọc × 1 |
| AES-128 CTR | **124** | 129 | 5 | 3,9% | 5 đọc × 1 |
| SHA3-256 · 1 block | **492** | 500 | 8 | 1,6% | 8 đọc × 1 |
| SHA3-256 · 4 block | **1771** | 1911 | 140 | 7,3% | 66 nhánh×2 + 8 đọc |
| SHA3-256 · 16 block | **6871** | 7419 | 548 | 7,4% | 270 nhánh×2 + 8 đọc |
| RSA-2048 verify | **320972** | 321039 | 67 | 0,02% | 67 đọc × 1 |

Tất cả PASS chuẩn (NIST SP800-38A cho AES, `hashlib.sha3_256` cho SHA3,
`pow(M,65537,N)` cho RSA) — không phải chỉ so chu kỳ.

#### 3. ⭐ MÔ HÌNH HAI HẰNG SỐ — phát hiện chính của giai đoạn này

```
Δ(RV32I − RISSP) = 1,00 × (số lần ĐỌC) + 2,00 × (số NHÁNH taken)
```

Đúng trên cả 8 workload, dải từ 88 ck đến 321.000 ck (3.650 lần), sai số
tối đa 2 chu kỳ. Cả hai hằng số truy ngược ra được dòng RTL cụ thể:

- **1,00 ck/lần đọc** — `axi_rissp_master` bật `RREADY` ngay ở `IDLE`;
  cầu RV32I chỉ bật sau khi bắt tay `ARREADY` xong.
- **2,00 ck/nhánh taken** — `Flush` của RV32I xoá cả `IF_ID` lẫn `ID_EX`
  ⇒ giết đúng 2 lệnh. RISSP single-cycle không có bong bóng. ⚠️ Module
  `Branch_prediction` của RV32I **không phải** bộ dự đoán — chỉ đánh giá
  điều kiện nhánh, tên gây hiểu nhầm.

**Nhóm đối chứng hoàn hảo**: `sha3.coe` (1 block, unroll, 0 nhánh) → chênh
lệch biến mất sạch. Chi phí mỗi từ 64-bit khi nạp SHA3: RISSP 25,00 ck ·
RV32I 27,00 ck.

#### 4. Công suất + năng lượng (Implementation, strategy default cả 2 bên)

| | RISSP | RV32I |
|---|---:|---:|
| Total On-Chip Power | **0,407 W** | **0,438 W** (+7,6%) |
| Năng lượng / chu kỳ (`P × 25ns`) | **10,175 nJ** | **10,950 nJ** |

| Workload | RISSP E | nJ/bit | Mbps/W | RV32I E | nJ/bit | Mbps/W | RV32I tốn thêm |
|---|---:|---:|---:|---:|---:|---:|---:|
| AES ECB | 895,4 nJ | 6,995 | 142,95 | 1018,3 nJ | 7,956 | 125,69 | **+13,7%** |
| AES CBC/CFB/CTR | 1261,7 nJ | 9,857 | 101,45 | 1412,5 nJ | 11,036 | 90,62 | **+12,0%** |
| SHA3 1 block | 5006,1 nJ | 4,889 | 204,55 | 5475,0 nJ | 5,347 | 187,03 | **+9,4%** |
| SHA3 4 block | 18,02 µJ | 4,202 | 237,96 | 20,93 µJ | 4,880 | 204,92 | **+16,1%** |
| SHA3 16 block | 69,91 µJ | 4,031 | 248,08 | 81,24 µJ | 4,684 | 213,50 | **+16,2%** |
| RSA-2048 | 3265,9 µJ | — | 306,20 v/s/W | 3515,4 µJ | — | 284,46 v/s/W | **+7,6%** |

`E tốn thêm = (tỉ lệ chu kỳ) × (tỉ lệ power)` — hai yếu tố nhân nhau nên
khoảng cách năng lượng lớn gấp đôi khoảng cách chu kỳ.

**Điểm sắc nhất là RSA**: chu kỳ hoà tuyệt đối (lệch 0,02%, CPU chỉ hoạt
động 0,36% thời gian) nhưng vẫn tốn +7,6% năng lượng ⇒ *Chi phí của một
lõi CPU dư thừa không biến mất khi nó nhàn rỗi.*

#### 5. Diện tích lõi (OOC, xc7z020, `report_utilization`)

| Cấu hình | default LUT | AreaOpt LUT | LUTRAM | FF |
|---|---:|---:|---:|---:|
| **RISSP** | **1152** | 1001 | 48 | **170** |
| RV32I nguyên trạng (còn `DONT_TOUCH`) | 1626 | 1625 | 0 | 1663 |
| RV32I đã gỡ khoá (thí nghiệm) | 1204 | 975 | 48 | 671 |

**⚠️ Điều BẮT BUỘC phải biết**: `rv32i_top.v` có 15 thuộc tính
`DONT_TOUCH` (RISSP không có), và `Register_file.v` reset toàn mảng bằng
vòng `for` → phá LUTRAM. Đã làm thí nghiệm gỡ khoá thật (chức năng trùng
khít từng chu kỳ với bản gốc): sửa reset mảng → FF 1663→671; gỡ
`DONT_TOUCH` → AreaOpt cải thiện thêm 229 LUT (chứng minh nó đang khoá
cứng). Con số "RISSP nhỏ hơn 41%" chỉ đúng khi RV32I còn khoá.

**QUYẾT ĐỊNH ĐÃ CHỐT**: **KHÔNG sửa RTL của RV32I**, giữ nguyên trạng.
Trong paper báo cáo cả hai con số: RV32I baseline **1626 LUT** as
provided; sau khi loại `DONT_TOUCH` + ánh xạ register file sang LUTRAM:
**1204 LUT**. RISSP: **1152 LUT**. Lý do an toàn: ở default (flow đang
dùng), RISSP thắng cả bản đã gỡ khoá hoàn toàn (1152 vs 1204).

**Cột FF thắng đậm ở mọi cấu hình**: 170 vs 671. Trừ 141 FF cầu AXI dùng
chung ⇒ lõi RISSP chỉ ~29 FF (1 thanh ghi PC, register file trong LUTRAM)
so với ~530 FF cho 4 tầng pipeline của RV32I — *pipeline hoá tốn ~500
flip-flop trạng thái mà trong SoC này không đổi lại được gì.*

⚠️ Con số **1018 LUT** ghi ở phần lịch sử phía dưới file đo bằng script
riêng (`AreaOptimized_high`+`ExploreArea`) với cầu AXI **cũ**, không so
được với số default. **Số nên trích vào paper: 1152 (default)**.

#### 6. Việc còn lại

1. **Lõi Ibex** — xem § "TRẠNG THÁI IBEX" ngay dưới.
2. Soi Power Report theo hierarchy để quy 31 mW chênh lệch (0,365→0,407W)
   về đúng nguồn — chưa làm.
3. (tuỳ chọn) Nâng clock 40 → 48 MHz (trần ~50,8 MHz sau khi có RSA-2048).

---

### 🤖 TRẠNG THÁI IBEX — đã đóng IP, đi dây SoC, đủ 8/8 workload, Implementation thật

`IBEX_CORE/` chứa RTL Ibex gạn lọc (111 file, lowRISC upstream),
`ibex_axi_top.sv` dịch OBI↔BRAM cho imem + dùng `axi_rissp_master.v` cho
dmem. Đóng gói IP tại `F:\advance_topic\Ibex_Core\ip_repo` (VLNV
`rissp.local:user:ibex_core:1.0`), instantiate trong project
`F:\advance_topic\Ibex_SoC` (đi dây y hệt `SE-RISSP_AES_ULTRA`, chỉ đổi
CPU). Địa chỉ AXI giống hệt RISSP: AES `0x40000000`/16K · SHA3
`0x44000000`/64K · RSA `0x48000000`/64K · BRAM debug `0xC0000000`/8K ·
UART `0x40600000`/64K. `CONFIG.RV32M=0` khớp RISSP/RV32I (phần nén C vẫn
không tắt được — Ibex không có `RV32ZcNone`, **phải ghi rõ trong paper**
khi so diện tích).

**Boot offset 0x80** (Ibex fetch lệnh đầu tại `boot_addr_i + 0x80`, cố
định trong RTL) — giải quyết bằng **phần cứng**, KHÔNG sửa `.coe`: thêm
cell `addsub_bootoffset_0` (`c_addsub`, Subtract, B_Constant=32, thuần tổ
hợp) chen giữa `xlslice_0` và `blk_mem_gen_0/addra` — `addr_BRAM =
addr_fetch_word − 32`. Nằm ở tầng Block Design, ngoài module CPU, nên
**không lọt vào số LUT lõi** dùng so sánh 3 kiến trúc (chỉ +~10-15 LUT
tổng SoC, không đáng kể).

**Bug đóng gói IP đã sửa tận gốc** — `Run Simulation` báo `Module
<ibex_axi_top> not found` dù RTL thật có đủ trong `ipshared/<hash>/src/`.
Nguyên nhân thật: `ipx::package_project` (bộ đóng gói IP Vivado) dùng
parser yếu hơn hẳn `xvlog`/`xelab`, không hiểu cú pháp macro tham số mặc
định (`` `ASSERT``/`` `COVER``/`` `ASSUME`` của lowRISC) → parse lỗi dây
chuyền âm thầm, khiến metadata mô phỏng của IP thiếu file. Xác nhận bằng
cách gộp 56 file RTL đóng gói thử — chính `ipx::package_project` báo lỗi
syntax tại đúng lời gọi `` `ASSERT`` đầu tiên (trong khi `xvlog` biên dịch
sạch cùng nội dung). Các macro này rỗng hoàn toàn khi `SYNTHESIS` (đã đọc
`prim_assert_dummy_macros.svh` xác nhận) nên xoá lời gọi không đổi hành
vi. **Đã vá**: script bóc 206 lời gọi `` `ASSERT``/`` `COVER``/`` `ASSUME``
(gộp 56 file → 1 file `ibex_axi_top_combined.sv`), đóng gói lại IP —
`Run Simulation` GUI giờ chạy bình thường, không cần workaround. Bẫy khi
áp dụng: phải bump `coreRevision` trong `component.xml` (không bump thì
Vivado giữ cache IP cũ, im lặng bỏ qua thay đổi).

Bug phụ khi tự động hoá nạp firmware: `blk_mem_gen` mô phỏng đọc `.mif`
luôn ở định dạng **nhị phân** 32-bit/dòng (bất kể `.coe` khai báo radix
16) — script convert phải tự đổi hex→nhị phân, không copy thẳng.

**8 testbench** `tb_ibex_{ecb,cbc,cfb,ctr,sha3,sha3_4,sha3_16,rsa2048}.v`
tại `D:\Viettel_semi\Ibex_FULL\`, dùng chung `.coe` với RISSP/RV32I, cùng
cơ chế đo PURE.

#### 📊 KẾT QUẢ CUỐI CÙNG — Implementation thật của `Ibex_SoC`

**Chu kỳ PURE, 8/8 workload PASS thật** (đối chiếu trực tiếp FIPS-197/
hashlib/`pow()`):

| Workload | Ibex PURE | RISSP PURE | RV32I PURE |
|---|---:|---:|---:|
| AES-128 ECB | **90 ck** | 88 ck | 93 ck |
| AES-128 CBC/CFB/CTR | **126 ck** | 124 ck | 129 ck |
| SHA3-256 (1 block) | **496 ck** | 492 ck | 500 ck |
| SHA3-256 (4 block) | **1907 ck** | 1771 ck | 1911 ck |
| SHA3-256 (16 block) | **7415 ck** | 6871 ck | 7419 ck |
| RSA-2048 verify | **320974 ck** | 320972 ck | 321039 ck |

**Ibex nằm GIỮA RISSP và RV32I ở MỌI workload** — RV32I 5-tầng pipeline
chậm hơn cả RISSP (single-cycle song song) lẫn Ibex (2-tầng, prefetch
buffer). Chênh lệch Ibex so với RISSP ổn định ở +2 ck cho AES (chi phí
cấu trúc cố định, không phụ thuộc dữ liệu). Ibex nhanh hơn RV32I đúng 4 ck
cố định ở SHA3 (không phụ thuộc số nhánh), trong khi chênh lệch Ibex so
RISSP tăng tuyến tính theo số nhánh (~2,0 ck/nhánh, khớp gần đúng hằng số
"2,00 ck/nhánh" của RV32I) — gợi ý Ibex trả giá gần bằng RV32I mỗi nhánh
rẽ nhưng có chi phí cố định thấp hơn 4 ck; chưa verify bằng RTL thật, chỉ
là quan sát số liệu.

**Implementation thật, đối chiếu trực tiếp report** (Power/LUT/FF khớp
100% với report Vivado):

| | RISSP | RV32I | Ibex |
|---|---:|---:|---:|
| Total On-Chip Power | **0,407 W** | **0,438 W** | **0,446 W** |
| LUT toàn SoC | 17180 | 17632 | 18484 |
| FF toàn SoC | 24748 | 26233 | 26401 |
| WNS @ 40MHz | +5,308 ns | +5,249 ns | **+7,308 ns** |
| fmax ước lượng | ~50,8 MHz | ~50,6 MHz | **~56,5 MHz** |
| LUT lõi CPU riêng | 1152 (OOC default) | 1626/1204 (OOC) | 2437 (hierarchy/routed)* |
| FF lõi CPU riêng | 170 | 1663/671 | **1841** |

\* Số 2437 LUT của Ibex đo bằng hierarchy-extraction post-route (không
phải OOC standalone như 2 lõi kia) — khác phương pháp đo, cần ghi rõ nếu
paper cần so sánh táo-với-táo tuyệt đối. Ibex có fmax cao hơn hẳn 2 lõi
kia nhưng cũng là lõi lớn nhất (~2,1× RISSP) — hợp lý vì là lõi công
nghiệp tổng quát (PMP, lockstep, ICache dù tắt, decoder nén luôn có).

**Energy/Throughput, dùng P=0,446W thật**:

| Workload | N_ck (PURE) | Energy | Energy/bit | Throughput | Mbps/W |
|---|---:|---:|---:|---:|---:|
| AES ECB | 90 | 1003,5 nJ | 7,8398 nJ/bit | 56,89 Mbps | 127,56 |
| AES CBC/CFB/CTR | 126 | 1404,9 nJ | 10,976 nJ/bit | 40,64 Mbps | 91,11 |
| SHA3 1 block | 496 | 5530,4 nJ | 5,4008 nJ/bit | 82,58 Mbps | 185,16 |
| SHA3 4 block | 1907 | 21,267 µJ | 4,9600 nJ/bit | 89,94 Mbps | 201,66 |
| SHA3 16 block | 7415 | 82,697 µJ | 4,7684 nJ/bit | 93,56 Mbps | 209,78 |
| RSA-2048 | 320974 | 3578,86 µJ | — | 124,62 verify/s | — |

**So RISSP/RV32I** (E tốn thêm = tỉ lệ chu kỳ × tỉ lệ power):

| Workload | Ibex so RISSP | Ibex so RV32I |
|---|---:|---:|
| AES ECB | +12,1% | **−1,5%** |
| AES CBC/CFB/CTR | +11,4% | **−0,5%** |
| SHA3 1 block | +10,5% | **+1,0%** |
| SHA3 4/16 block | +18,0%/+18,3% | +1,6%/+1,8% |
| RSA-2048 | +9,6% | +1,8% |

**Điểm đáng viết cho paper**: dù Ibex to hơn hẳn (2437 LUT) và power cả
SoC cao nhất (0,446W), năng lượng mỗi phép toán rất gần RV32I (chênh dưới
2%, 2 trường hợp AES còn thấp hơn RV32I) nhưng luôn thua RISSP (9,6-18,3%
tốn hơn) — khớp đúng luận điểm chính của paper: kiến trúc song song
chuyên biệt (RISSP) hiệu quả năng lượng hơn cả 2 lõi CPU-tổng-quát, bất kể
pipeline hoá kiểu nào.

**Việc còn lại (không bắt buộc)**: OOC standalone synth cho `ibex_axi_top`
nếu muốn số LUT lõi so sánh cùng phương pháp tuyệt đối với RISSP/RV32I.

### [LỊCH SỬ, ĐÃ BỎ] TRẠNG THÁI CVA6 — thử làm lõi thứ 4, bỏ hẳn

Từng thử đưa OpenHW Group CVA6 làm lõi thứ 4 — sửa 4 bug thật (1 bug
upstream CVA6 ở MMU RV32, 2 hạn chế Vivado XSIM/IP Packager, 1 bug
nghiêm trọng `tc_sram_wrapper.sv` bị `synthesis translate_off` biến RAM
thành black box), đóng gói IP thành công, `synth_design` sạch. **Dừng
hẳn** vì CVA6 một mình dùng 116,5% LUT xc7z020 — không vừa chip. Đã xoá
toàn bộ working directory.

### [LỊCH SỬ, ĐÃ BỎ] TRẠNG THÁI PICORV32 — khảo sát khả thi, bỏ hẳn cùng ngày

Sau CVA6, khảo sát nhanh PicoRV32 — LUT đo thật (OOC) chỉ 916 LUT, nhỏ hơn
RISSP, không boot-offset ẩn. Elaborate sạch nhưng chưa mô phỏng chức năng
trước khi bị bỏ hẳn — người dùng quyết định không cần lõi thứ 4 nữa. Đã xoá.

### 🧮 CÔNG THỨC — mọi con số dẫn ra từ 2 hằng số

`T = 1/f = 25 ns/chu kỳ` (@40MHz) · `P` = tổng on-chip cả SoC, **mỗi SoC
một giá trị riêng**: SE-RISSP **0,407 W** · RV32I **0,438 W** (Implementation,
strategy default).

```
t          = N_ck × T
Energy     = P × t = P × N_ck × T
Throughput = S_block / t          (S_block = 128 bit cho AES-128)
Energy/bit = Energy / S_block     (LUÔN chia S_block, không chia bit cửa sổ đo)
Mbps/W     = Throughput / P
η          = N_ck(lõi) / N_ck(PURE)
verify/s   = 1 / t                (dùng cho RSA, S_block vô nghĩa)
```

Thay số ECB RISSP (PURE=88 ck): `t=2,20µs` → `E=0,407×2,20e-6=895,4 nJ` →
`E/bit=895,4/128=6,9953` → `TP=128/2,20e-6=58,18 Mbps` →
`58,1818/0,407=142,95 Mbps/W` → `η=16/88=18,2%`.

**3 lối tắt kiểm chéo**:
1. `E_ck = P×T` → RISSP **10,175 nJ/ck** · RV32I **10,950 nJ/ck**.
2. `Mbps/W ≡ 1000/(nJ per bit)`: `1000/6,9953 = 142,95`. **Lưu ý hệ số
   1000** (nJ ↔ Mbps).
3. `N_ck × TP = S_block × f` (hằng số): AES = `128 × 40 = 5120`:
   `88×58,1818=5120` ✓ `93×55,0538=5120` ✓
4. So sánh 2 SoC: `E tốn thêm = (tỉ lệ chu kỳ) × (tỉ lệ power)`. AES ECB:
   `(93/88)×(0,438/0,407)=1,1373` → +13,7% ✓

⚠️ **Mbps = 10⁶ bit/s**, KHÔNG phải 2²⁰.
⚠️ `P` là công suất **cả SoC**, "Energy/block" = năng lượng cả hệ tiêu thụ
trong khoảng mã hoá 1 block, KHÔNG phải của riêng lõi AES — phải viết rõ
trong paper.
⚠️ **Không dùng chung 1 giá trị P cho cả 2 SoC** — chính chênh lệch power
mới làm lộ ra kết quả RSA: chu kỳ hoà nhưng năng lượng vẫn chênh 7,6%.

### 📏 CƠ SỞ ĐO ĐÃ CHỐT: dùng PURE, không dùng E2E

Số chu kỳ trích vào paper lấy cửa sổ **PURE**, không lấy END-TO-END —
PURE đo hệ thống làm 1 phép toán, không lẫn chi phí ghi kết quả ra BRAM.

Định nghĩa cửa sổ PURE — **giữ nguyên qua mọi lần đo, mọi lõi CPU**, đổi
là hai bảng hết so sánh được:

| Lõi | PURE = từ → đến | Cách chốt |
|---|---|---|
| AES | ghi `PT[0]` → đọc xong `CT[3]` | theo **địa chỉ từ cuối**, KHÔNG đếm số lần đọc |
| SHA3 | ghi CTRL absorb đầu → đọc xong digest cuối | như trên |
| RSA | ghi `M[0]` → đọc xong `RESULT[63]` | như trên |

Lý do chốt theo địa chỉ: firmware còn poll STATUS không biết trước bao
nhiêu lần, đếm giao dịch sẽ sai.

SHA3: permutation thuần **27 ck cố định**, cửa sổ `iLast→oReady`=28 ck (1
padding + 27 permutation), trần lõi **1611,85 Mbps** (1088 bit/27 ck).

### 🔐 RSA ĐÃ LÊN 2048-BIT THẬT TRONG SoC — PASS 9/9

Thay lõi RSA 32-bit bằng Montgomery word-serial (CIOS), viết lại AXI
wrapper tải toán hạng 2048-bit theo từng từ.

| Chỉ số | Chu kỳ | Thời gian |
|---|---:|---:|
| Lõi (start→done) | **319.813** | 7.995 ms |
| **PURE** (M→RESULT) | **321.105** | **8.03 ms** |
| **Hiệu suất** | **99,60%** | — |

Verify: 8 từ mẫu + XOR-fold cả 64 từ khớp `pow(M,65537,N)` Python.
**Tài nguyên**: IP RSA 7.747 LUT · 4 DSP (giảm từ 11) · WNS +5,308ns @40MHz.

> 🔴 fmax giảm 59→~50,8 MHz sau khi thêm RSA-2048 — kế hoạch nâng clock
> lên 55MHz KHÔNG CÒN KHẢ THI, trần mới ~50MHz, tối đa nên 48MHz.

**File**: `D:\Viettel_semi\SE-RISSP_FULL\gen_rsa2048.py`/`rsa2048_key.py`/
`rsa2048.coe`/`tb_rsa2048.v`. RTL ở `RSA_Core/ws/`. Bản đồ thanh ghi wrapper
(`C_S_AXI_ADDR_WIDTH`=12, base `0x48000000`, range 64K): `0x000-0x0FC`
M[0..63] · `0x100-0x1FC` N · `0x200-0x2FC` R2 · `0x300` E · `0x304` N_INV
· `0x308` CTRL · `0x30C` STATUS · `0x400-0x4FC` RESULT[0..63].

2 bug testbench/firmware đã sửa lúc đưa vào SoC (không phải phần cứng):
timeout tuyệt đối hardcode quá ngắn trong `TB_TAIL` (tham số hoá lại); 1
thanh ghi CPU (`x20`) vừa giữ kết quả vừa làm biến tạm gây lệch 1 ô BRAM
(tách riêng `x30` làm biến tạm).

⚠️ **Còn thiếu để gọi là chuẩn**: hiện là RSA thô (`s^e mod n` rồi so số),
chưa có padding PKCS#1 v1.5 — việc này là phần mềm thuần, không cần sửa
phần cứng.

**📊 SO SÁNH 3 LÕI — BẢNG CHỐT** (PURE đo thật, cùng `P=0,365W`, 40MHz —
⚠️ số cũ, xem bảng Power mới ở § TIẾN ĐỘ HIỆN TẠI):

| Lõi | Lõi (ck) | PURE (ck) | Hiệu suất | Năng lực lõi | Hệ thống đạt | Giao dịch AXI/ck tính |
|---|---:|---:|---:|---:|---:|---:|
| **RSA verify** | 186 | **257** | **72,4%** | 215.054 v/s | 155.642 v/s | 0,04 |
| AES-128 ECB | 16 | **98** | 16,3% | 320 Mbps | 52,24 Mbps | 0,81 |
| AES CBC/CFB/CTR | 16 | **138** | 11,6% | 320 Mbps | 37,10 Mbps | 1,06 |
| SHA3-256 (1 blk) | 27 | **551** | 4,9% | 1611,85 Mbps | 74,34 Mbps | — |
| **SHA3-256 (16 blk)** | 432 | **7695** | **5,6%** | 1611,85 Mbps | 90,16 Mbps | 1,90 |

**Hiệu suất tương quan nghịch hoàn hảo với tỉ lệ giao dịch AXI trên mỗi
chu kỳ tính toán.** RSA gần như không mất gì (tính lâu, dữ liệu ít) → lõi
duy nhất bị giới hạn bởi tính toán. SHA3 mạnh nhất nhưng bị bóp cổ nặng
nhất (mỗi từ 64-bit tốn 3 giao dịch AXI 32-bit). Kết luận định lượng: với
accelerator ăn nhiều dữ liệu, **giao diện AXI4-Lite register-mapped là nút
thắt, không phải thuật toán.**

Dữ liệu test đa dạng hoá: mỗi mode AES dùng 1 vector khác nhau nhưng đều
truy vết được về chuẩn (ECB: FIPS-197 App.C.1 · CBC: SP800-38A F.2.1 ·
CFB: F.3.13 · CTR: F.5.1). Ciphertext kỳ vọng tự tính bằng pycryptodome
trong `gen_all.py` nên đổi vector là `ct` tự cập nhật, không tra bảng tay.

### 🔌 KẾ HOẠCH THÊM UART — giữ nguyên địa chỉ (chưa làm)

Vivado chỉ tự gán cho segment chưa map; dòng đã có giá trị thì giữ
nguyên, miễn KHÔNG bấm "Auto Assign Address" cho cả diagram. Địa chỉ nên
đặt `0x40600000`/64K (default Xilinx, vùng trống). Các bước: NUM_MI 4→5,
add `axi_uartlite` (115200/8N1), nối M04_AXI, Make External, Address
Editor gõ tay (không Auto Assign), Validate → Generate Output Products
(Reset trước) → Synth+Impl.

Vì địa chỉ không đổi, firmware không cần sửa — toàn bộ mốc chu kỳ/
ciphertext/digest/RESULT đã verify giữ nguyên; chỉ LUT/FF/BRAM/Power/WNS
và mọi số Energy cần đo lại 1 lần. `axi_uartlite` rất nhẹ (~150-200 LUT).
**Rủi ro cần theo dõi**: đường tới hạn hiện bị chi phối bởi routing, thêm
nhánh interconnect có thể ăn vào biên fmax — nên làm cùng lúc với việc
nâng clock, chỉ đo lại 1 lần.

### SoC thứ 2: `SE-RISSP_AES_ULTRA` — đủ 4 lõi, đã có số liệu hoàn chỉnh

Project Vivado riêng biệt ở `F:\advance_topic\SE-RISSP_AES_ULTRA` giữ đủ
cả 4 lõi (RISSP+AES+SHA3+RSA), 40MHz, ZedBoard xc7z020 — xem
`Docs/SE-RISSP_FULL.md`. Địa chỉ AXI (4-master): AES `0x40000000`/16K ·
SHA3 `0x44000000`/64K · RSA `0x48000000`/64K · BRAM debug `0xC0000000`/8K.
imem là ROM riêng không qua AXI.

⚠️ **Power hiện hành của SoC này là 0,407W** (số cũ 0,293W chỉ đối chiếu
lịch sử, đo trước khi có RSA-2048 + cầu AXI sửa). fmax hiện ~50,8MHz (số
cũ 59MHz cũng đã hết hạn cùng lý do).

### Cấu trúc thư mục

- `PAPER/` — `RISSP_CORE_PAPER.pdf` (bản thảo) + 1 paper tham khảo chaotic
  image encryption (chỉ dùng citation, không sao chép kỹ thuật).
- `Docs/` — `PaperStrategy.md`, `Vivado.md`, `SHA3_Results.md`,
  `SE-RISSP_FULL.md`. `CLAUDE.md` cố tình giữ ở root.
- `firmware_OTA/`, `firmware_HashImage/` — 2 hướng demo cũ, không còn là
  demo chính nhưng vẫn dùng được (`tb_sha3_multiblock.v` verify SHA3
  nhiều block vẫn còn giá trị tham khảo).

## Cấu trúc file RTL

- `rissp_top.v` — top module, nối fetch + modular_ex + register_file + AXI bridge.
- `fetch_stage.v` — PC register + fetch (BRAM 1-cycle latency).
- `modular_ex.v` — decode opcode/immediate 1 lần, instantiate 3 khối dùng chung (shifter/comparator/adder) + 6 type-block, mux kết quả cuối theo opcode.
- `barrel_shifter.v` — shifter DÙNG CHUNG r_type_block (SLL/SRL/SRA) & i_type_block (SLLI/SRLI/SRAI).
- `comparator.v` — comparator DÙNG CHUNG r_type_block (SLT/SLTU) & i_type_block (SLTI/SLTIU).
- `alu_adder.v` — adder/sub DÙNG CHUNG r_type_block (ADD/SUB) & i_type_block (ADDI/địa chỉ LOAD/target JALR).
- `r_type_block.v`, `i_type_block.v` — sau khi tách 3 khối trên ra ngoài, chỉ còn giữ bitwise (XOR/OR/AND) + (riêng i_type) mux byte/half cho LOAD.
- `b_type_block.v`, `j_type_block.v`, `u_type_block.v`, `s_type_block.v` — độc lập, mỗi block xử lý 1 nhóm lệnh.
- `register_file.v` — 32×32-bit, LUTRAM, đứng ngoài modular_ex.
- `axi_rissp_master.v` — cầu nối dmem sang AXI4 master (stall CPU khi LOAD/STORE).
- `tb_rissp_top.v` — testbench tự kiểm (self-checking) toàn hệ thống.
- `synth_run.tcl` — synth `rissp_top` nguyên khối (OOC) + `opt_design`, lấy tổng LUT.
- `synth_standalone.tcl` — synth từng module riêng lẻ (OOC top độc lập), nguồn số liệu LUT đáng tin cậy nhất.
- `RISSP_CORE/` — bản "gốc sạch" 14 file `.v` synthesizable, nguồn để đóng gói Vivado IP (`Docs/Vivado.md`).
- `rissp_constr.xdc` — file ràng buộc timing, có ghi chú so sánh công bằng LUT/power RISSP vs RV32I.
- `rissp_instruction.md` (root) — 35 lệnh RISSP hỗ trợ + 5 lệnh KHÔNG hỗ trợ (LH/LHU/FENCE/ECALL/EBREAK).
- `D:\Viettel_semi\SE-RISSP_FULL\` (ngoài repo) — firmware+testbench SoC 4 lõi, mỗi chức năng 1 bộ riêng, sinh bằng `gen_all.py`/`gen_rsa2048.py` (đừng sửa tay). `POWER_W=0,407`.
- `F:\advance_topic\RV32I_soc_ULTRA\` (ngoài repo) — SoC thứ 3, bản sao kiến trúc SE-RISSP_AES_ULTRA thay CPU bằng RV32I 5 tầng, địa chỉ AXI trùng khít nên dùng chung `.coe`.
- `F:\advance_topic\RV32I_FIXED\` (ngoài repo) — RV32I đã sửa lỗi đường fetch, đóng gói IP `xilinx.com:user:rv32i_fixed:1.0`.
- `D:\Viettel_semi\RV32I_FULL\` (ngoài repo) — 9 testbench đo chu kỳ SoC RV32I, cùng cơ chế đo RISSP. `POWER_W=0,438`.

---

## TÌNH TRẠNG LÕI RISSP (tối ưu LUT) — kết quả hardware chi tiết

**Tóm tắt**: Chức năng 43/43 PASS, 0 FAIL. LUT: **1018** (AreaOpt, cầu AXI
cũ — số nên dùng cho paper là **1152 default**, xem § TIẾN ĐỘ HIỆN TẠI).
Đã sửa 4 bug chức năng thật trong quá trình audit ban đầu: AUIPC bị bỏ
qua hoàn toàn, SB/SH luôn ghi sai thành full-word, LB/LBU trả sai giá trị,
SRAI/SRA tính sai thành logic-shift. Kiến trúc giữ 100% song song trừ 3
nhượng bộ đã xác nhận (shifter/comparator/adder dùng chung R-type/I-type).

### Chức năng: PASS 100%
`tb_rissp_top.v` qua Vivado xsim — 43/43 lần ghi register file kỳ vọng
khớp đúng thứ tự thực thi. Bao phủ toàn bộ tập lệnh hỗ trợ: R-type,
I-type ALU, LOAD (LW/LB/LBU), STORE (SW/SB/SH), LUI, AUIPC, JAL, JALR, 6
loại branch ở cả 2 trạng thái taken/not-taken.

```
"F:\vivado\Vivado\2024.2\bin\xvlog.bat" *.v
"F:\vivado\Vivado\2024.2\bin\xelab.bat" tb_rissp_top -s tb_snap
"F:\vivado\Vivado\2024.2\bin\xsim.bat" tb_snap -R
```

### LUT từng block (đo ĐỘC LẬP từng module qua `synth_standalone.tcl`)

| Instruction hardware block | LUT (độc lập) | Ghi chú |
|---|---:|---|
| **`barrel_shifter`** (dùng chung) | **165** | SLL/SRL/SRA + SLLI/SRLI/SRAI. Trước gộp: 2 shifter riêng tốn 524 LUT. |
| **`i_type_block`** | **112** | ↓ từ 421 gốc. Còn: bitwise XORI/ORI/ANDI + mux byte/half LOAD. |
| `b_type_block` | 115 | 2 comparator + equality + adder pc+imm. Độc lập. |
| **`r_type_block`** | **64** | ↓ từ 349 gốc. Còn: bitwise XOR/OR/AND. |
| **`register_file`** | **113** | 48 LUT LUTRAM + 65 LUT logic (bypass x0). Ổn định, xem giải thích dưới. |
| `s_type_block` | 71 | Adder rs1+imm + mux đóng gói byte/half/word. |
| `fetch_stage` | 34 | PC register + 2 mux. |
| `u_type_block` | 33 | 1 adder pc+imm cho AUIPC (đã xác nhận tối thiểu). |
| `j_type_block` | 31 | 1 adder pc+imm cho target JAL. |
| **`comparator`** (dùng chung) | **32** | SLT/SLTU + SLTI/SLTIU. |
| **`alu_adder`** (dùng chung) | **32** | ADD/SUB + ADDI/địa chỉ LOAD/target JALR. |
| `axi_rissp_master` | 20 | FSM stall CPU khi LOAD/STORE qua AXI4. |
| **Tổng cộng dồn riêng lẻ** | 922 | Không bằng tổng thiết kế thật — xem dưới. |
| **Tổng thiết kế thật** | **1018** | = 922 + ~193 (logic decode/mux của `modular_ex`, phần "coordinator" chọn+định tuyến toán hạng cho khối dùng chung, không thuộc block nào). |

### Các lần gộp phần cứng r_type_block ↔ i_type_block

Nguyên lý chung: R-type và I-type luôn dùng `rs1_data` làm toán hạng A,
chỉ khác toán hạng B (`rs2_data` vs `imm`). `modular_ex` mux đúng 1 chỗ
(`alu_op_b`), feed vào khối dùng chung.

| Bước gộp | r_type trước→sau | i_type trước→sau | Khối mới | Tổng thiết kế |
|---|---:|---:|---:|---:|
| 1. Barrel shifter | 349→128 | 421→178 | +165 | 1378→**1049** |
| 2. Comparator | 128→96 | 178→146 | +32 | 1049→**1031** |
| 3. Adder | 96→64 | 146→113 | +32 | 1031→**1018** |

Bước 1 lãi nhiều nhất (chỉ cần mux 5-bit shamt). Bước 2 lãi ít (cần mux
32-bit operand-B riêng). Bước 3 lãi tốt hơn bước 2 vì tái dùng lại đúng
mux `alu_op_b` đã tạo cho comparator.

**Vì sao dừng ở đây (không gộp nốt bitwise XOR/OR/AND)?** Sau 3 lần gộp,
`r_type_block` chỉ còn 64 LUT, `i_type_block` còn 112 LUT — gần như toàn
bộ phần còn lại chỉ là bitwise + mux chọn kết quả. Gộp nốt bitwise sẽ biến
2 block thành lớp vỏ mỏng bọc quanh 1 ALU dùng chung hoàn toàn — phương án
đã bị từ chối ngay từ đầu khi hỏi mức độ gộp. Ranh giới hiện tại là điểm
dừng có chủ đích, đã thống nhất với người dùng — **nếu muốn gộp tiếp cần
hỏi lại**, vì đây sẽ là nhượng bộ kiến trúc thứ 4.

### Vì sao LUT của `register_file` từng có vẻ dao động thất thường

`register_file` đứng ngoài modular_ex, LUT thực tế **ổn định 113**, không
đổi theo ngữ cảnh. Cái từng thấy dao động đến từ 2 nguyên nhân:

1. **THẬT**: bản gốc reset toàn mảng 32 thanh ghi bằng vòng `for` — LUTRAM
   không có chân reset hàng loạt, Vivado buộc phải dựng lại bằng FF+mux
   32:1/bit, đắt hơn nhiều (608 LUT, 0 LUTRAM) so với bản đã sửa (113 LUT,
   48 LUTRAM). Đã sửa: bỏ reset-toàn-mảng, x0 bypass ở đường đọc.
2. **ẢO**: synth toàn bộ `rissp_top` với directive area-optimize mặc định
   (Vivado tự flatten hierarchy) khiến `report_utilization -hierarchical`
   gán nhầm logic của module khác (kèm cả `CARRY4` dù register_file không
   có phép cộng nào) vào tên `rf` — không phải phần cứng thật đổi. Tránh
   bằng cách đo `-flatten_hierarchy none` hoặc đo standalone như
   `synth_standalone.tcl` đang làm, và chỉ tin **Total LUTs** dòng
   `rissp_top`, không tin breakdown hierarchy.

---

## Lịch sử các phiên làm việc (tóm tắt — chi tiết debug đã cắt)

- **Phiên 1** (2026-08-05): audit ban đầu, sửa 4 bug chức năng (reset
  toàn mảng register file, SB/SH sai full-word, AUIPC bị bỏ qua, LB/LBU
  sai giá trị, SRAI/SRA logic-shift), viết `tb_rissp_top.v` PASS 43/43.
  LUT lần đầu ~1312-1362.
- **Phiên 2**: audit từng type-block riêng lẻ, xoá 1 adder chết trong
  `i_type_block` (case JALR không bao giờ đọc), dọn 8 port chết.
- **Phiên 3**: giải thích + test trực tiếp nguyên nhân LUT `register_file`
  dao động (xem § ngay trên).
- **Phiên 4-5** (2026-08-06): gộp barrel shifter (1378→1049), rồi
  comparator+adder (→1031→1018), theo đúng phạm vi đã thống nhất với
  người dùng ở mỗi bước.
- **Phiên 6** (2026-08-07): sửa timing AES bằng pipeline nội bộ
  `KeyExpansion` (WNS +13,145ns@50MHz); phát hiện+sửa audit RSA ban đầu
  nhầm core (`control`/Euclid thay vì `rsa`/Montgomery thật), viết
  `tb_rsa_montgomery.v` PASS.
- **Phiên 7**: khảo sát literature, tạo `Docs/PaperStrategy.md` (tần số
  mục tiêu 50MHz, hướng tạo tính mới, baseline Ibex+CVA6).
- **Phiên 8** (2026-08-08/09): dọn thư mục (`PAPER/`+`Docs/`), viết
  firmware OTA, pivot sang hướng "hash the image" (RISSP+SHA3 riêng), viết
  `tb_sha3_multiblock.v` verify message nhiều block.
- **Phiên 9** (2026-08-10): thêm BRAM ảnh riêng + firmware vòng lặp
  (`lw`+`bltu`) thay unroll để hỗ trợ ảnh 512×512 — chứng minh cầu AXI
  `axi_rissp_master.v` là tổng quát, chỉ `imem` mới fetch-only. PASS Lena
  512×512/262144 byte, digest khớp `hashlib.sha3_256`, 1.114.260 chu kỳ.
- **Phiên 10** (2026-08-10/11): chuyển sang SoC 4 lõi
  `SE-RISSP_AES_ULTRA`. Sửa bug lớn: imem 2-chu-kỳ latency vi phạm hợp
  đồng 1-chu-kỳ của `fetch_stage.v` (gây treo máy khi có nhánh, gây lệch
  ghi kết quả `lw` khi không nhánh) — sửa gốc bằng cách tắt
  `Register_PortA_Output_of_Memory_Primitives`. Tối ưu firmware (bỏ NOP
  padding, poll STATUS thật): AES ECB 249→145 ck. Phát hiện chính: lõi
  AES chỉ chạy 16/98 ck (~87% thời gian là giao dịch AXI, không phải mã
  hoá) — SoC nghẽn ở truyền thông, không phải tính toán. Tạo
  `rissp_instruction.md`, cảnh báo LH/LHU không được hỗ trợ.
- **Phiên 11** (2026-08-12): chạy đủ 4 mode AES + 2 message SHA3 + RSA,
  PASS 8/8. Truy nguyên "permutation 42 vs 28 ck" → cả 2 quy về đúng 27 ck
  cố định, chênh lệch 100% là padding. Chốt cơ sở đo = PURE, bỏ E2E. Ghi
  đầy đủ § CÔNG THỨC.
- **Phiên 12** (2026-08-13/14): dựng SoC thứ 3 dùng RV32I. Sửa 2 bug RTL
  thật trong `rv32i_top.v` (mất 1 lệnh mỗi lần stall imem, mọi branch/jump
  dư 4 byte) — cùng nguyên nhân gốc: lõi viết cho imem đọc tổ hợp nhưng
  SoC cấp BRAM trễ 1 chu kỳ. Sửa bằng cơ chế `next_pc`/`Stall` giống
  RISSP, đóng gói IP `rv32i_fixed`. Sửa `axi_rissp_master.v` để cân cầu
  AXI hai lõi (RISSP thắng 8/8 sau khi sửa). Rút ra mô hình 2 hằng số
  (§3, TIẾN ĐỘ HIỆN TẠI). Đo diện tích, phát hiện `DONT_TOUCH`+reset toàn
  mảng đang khoá RV32I — chốt không sửa RTL RV32I, báo cáo cả 2 con số.
- **Phiên 13** (2026-08-15): thử CVA6 làm lõi thứ 4 — đóng IP thật, phát
  hiện không vừa xc7z020 (116,5% LUT), dừng hẳn theo yêu cầu người dùng.
  Tổng hợp toàn bộ số liệu 3 SoC thành artifact cho paper; sửa 1 lỗi tính
  tay (Energy RSA-2048 của Ibex dùng nhầm `POWER_W` của RISSP trong log
  testbench, số đúng dùng P=0,446W thật = 3578,86 µJ).
- **Phiên 2026-10-08**: đưa toàn bộ 6 project + IP + `.coe` + testbench lên
  GitHub private `thanhtruong332/RISSP-Paper-Vivado` để mở ở máy công ty,
  kiểm chứng trên bản clone (PASS 4 mô phỏng + 1 synthesis). Xem § BẢN SAO
  GITHUB. Người dùng chốt: **chỉ làm việc với những gì CLAUDE.md có nhắc
  tới** — các thư mục không có trong tài liệu (`SHA3_Core_mark2/3`,
  `soc_upgrade_20260916`, `github_upload`, `_audit_tmp`, `firmware_Aes`…)
  không đụng vào, không đưa lên repo.

---

## Cách chạy lại toàn bộ verify

**Test chức năng** (Vivado xsim, không cần iverilog):
```
"F:\vivado\Vivado\2024.2\bin\xvlog.bat" *.v
"F:\vivado\Vivado\2024.2\bin\xelab.bat" tb_rissp_top -s tb_snap
"F:\vivado\Vivado\2024.2\bin\xsim.bat" tb_snap -R
```

**Tổng LUT toàn thiết kế**:
```
"F:\vivado\Vivado\2024.2\bin\vivado.bat" -mode batch -source synth_run.tcl
```
→ xem `util_after_opt.rpt` (sau `opt_design`, hiện tại: 1018 — số này dùng
cầu AXI cũ, xem cảnh báo ở § TIẾN ĐỘ HIỆN TẠI).

**LUT từng block riêng lẻ**:
```
"F:\vivado\Vivado\2024.2\bin\vivado.bat" -mode batch -source synth_standalone.tcl
```
→ xem `util_standalone_<module>.rpt` cho từng module.

**Trong Vivado GUI (project mode)**: mặc định "Vivado Synthesis Defaults"
ra số cao hơn và bảng Hierarchy hiện `rf` to bất thường (artifact, xem §
giải thích register_file). Để ra số gần với script: đổi Strategy sang
`Flow_AreaOptimized_high`, Reset Runs, Run Synthesis rồi Run Implementation
(bao gồm `opt_design`), xem **Total LUTs** ở dòng `rissp_top` (không xem
breakdown hierarchy). Nhớ thêm `barrel_shifter.v`, `comparator.v`,
`alu_adder.v` vào danh sách file nguồn.

---

## Quyết định đã chốt

- Kiến trúc song song giữ nguyên **trừ 3 nhượng bộ đã xác nhận**:
  `r_type_block`/`i_type_block` dùng chung `barrel_shifter`/`comparator`/
  `alu_adder`. Mọi block khác (B/J/U/S) và phần bitwise còn lại vẫn 100%
  độc lập.
- Tổng LUT lõi (script AreaOpt, cầu AXI cũ): **1018**. **Còn cách mục
  tiêu 1000 khoảng 18 LUT** — dừng lại có chủ đích vì bước tiếp theo khả
  thi duy nhất (gộp bitwise) sẽ xoá gần hết ranh giới R-type/I-type —
  đúng phương án đã bị từ chối lúc đầu. Nếu muốn ép nốt xuống dưới 1000
  bằng cách này, **cần hỏi lại và xác nhận rõ** đây là nhượng bộ kiến
  trúc thứ 4.
- **Cơ sở đo chu kỳ**: cửa sổ **PURE**, chốt theo **địa chỉ từ cuối**
  (không đếm số giao dịch). Giữ nguyên qua mọi lõi CPU.
- **Strategy tổng hợp**: **default** cho tất cả (SoC lẫn số diện tích
  lõi). Không trích số `AreaOptimized_high` vào paper — số nên dùng cho
  paper là **1152 LUT (default)**.
- **Cầu AXI phải giống nhau cho mọi lõi** — đã sửa `axi_rissp_master.v`
  (dùng chung bởi RISSP và Ibex). Cầu riêng của RV32I vốn đã nhanh bằng
  bản đã sửa.
- **KHÔNG sửa RTL của RV32I** (giữ nguyên `DONT_TOUCH` + reset toàn
  mảng), báo cáo cả 2 con số trong paper (1626 as-provided / 1204 sau khi
  gỡ khoá) để không bị phản biện gỡ mất kết quả.
- **Mỗi SoC dùng giá trị `P` riêng** (0,407W RISSP · 0,438W RV32I ·
  0,446W Ibex). Không dùng chung 1 giá trị cho cả ba.
- **Bug ALU SRA của RV32I** (`ALU.v`, `>>` phải là `>>>`) mới xác nhận
  sửa cho SoC test wolfSSL — **chưa kiểm tra trên `RV32I_soc_ULTRA`**
  (SoC chính của paper). Cần rà soát nếu firmware assembly HW-accelerator
  có dùng SRA/SRAI.
- **Đã bỏ hẳn mục "FIRMWARE PHẦN MỀM THUẦN (SOFTWARE-ONLY)"** (2026-08-29,
  theo yêu cầu người dùng) — bảng PURE cycles của nhánh AES/SHA3/RSA tự
  viết tay (RISSP 16.498/142.740/59.899.645 ck...) không còn trong tài
  liệu này. Nguồn software-only DUY NHẤT còn giữ lại là **§ wolfSSL THẬT
  TRÊN BARE-METAL** (thư viện production thật, PASS 3/3 lõi). Firmware
  nguồn của nhánh tự viết vốn đã xoá khỏi máy từ trước (2026-08-18) nên
  quyết định này chỉ xoá khỏi tài liệu, không mất thêm gì.
