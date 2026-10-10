# RISSP Paper — Vivado workspace (3 SoC chính + 3 SoC wolfSSL)

Toàn bộ project Vivado, IP đã đóng gói, firmware `.coe` và testbench của paper
*"An Application-Specific RISSP-Based SoC for Secure Edge Computing…"*.
Clone về là mở `.xpr` dùng được ngay, không cần đóng gói lại IP.

Đã kiểm chứng trên 1 bản clone ở thư mục khác máy gốc (2026-10-08) — xem cuối file.

## Yêu cầu

- **Vivado 2024.2** (bản khác sẽ đòi upgrade IP → số liệu không còn so sánh được với paper).
- **Clone vào đường dẫn ngắn**, ví dụ `D:\RISSP` — đường dẫn file dài nhất trong repo ~180 ký tự,
  Windows/Vivado lỗi khi vượt 260.
  ```
  git clone https://github.com/thanhtruong332/RISSP-Paper-Vivado.git D:\RISSP
  ```
- Board ZedBoard đã kèm trong `board_files/`, project tự trỏ tới — không cần cài từ Vivado Store.
- Không cần chạy lại synthesis/implementation để mở project; muốn số LUT/Power thì tự Run Synthesis/Implementation.

## Cấu trúc (giữ đúng cây thư mục của máy gốc để đường dẫn tương đối hoạt động)

```
advance_topic/
  SE-RISSP_AES_ULTRA/   SoC chính: RISSP  + AES + SHA3 + RSA-2048
  RV32I_soc_ULTRA/      SoC chính: RV32I 5 tầng + 3 IP trên
  Ibex_SoC/             SoC chính: Ibex 2 tầng + 3 IP trên (+ UART)
  RISSP_software/       SoC wolfSSL (CPU + BRAM, không accelerator)
  RV32I_software/       SoC wolfSSL
  Ibex_software/        SoC wolfSSL
  RSA_mark03/           IP RSA-2048 (dùng chung cả 3 SoC chính)
  RV32I_FIXED/          IP rv32i_fixed (+ project đóng gói)
  Ibex_Core/            IP ibex_core
SE_RISSP_LIBRARY/       IP RISSP_CORE_NEW, AES_NEOS, SHA_3/SHA3_hardware_new_1_0
firmware_testbench/     firmware, testbench và vector kiểm chứng đi kèm repository
  SE-RISSP_FULL/        TOÀN BỘ .coe (dùng chung cho cả 3 lõi) + testbench RISSP + gen_all.py
  RV32I_FULL/           testbench RV32I
  Ibex_FULL/            testbench Ibex + run_manual_sim.tcl / run_all.bat
RISSP_cORE/             RTL gốc RISSP, CLAUDE.md, Docs, AES/SHA3/RSA RTL, firmware wolfSSL
  firmware_SW_Crypto/wolfssl_build/   firmware + testbench cô lập wolfSSL
  firmware_SW_Crypto/wolfssl_src/     wolfSSL đã vá cho bare-metal (upstream bceb9fb6, 7 file sửa)
board_files/            ZedBoard board files
```

## Chạy mô phỏng (cách GUI, giống trên máy gốc)

Mỗi SoC chính: 1 file `.coe` nạp vào `blk_mem_gen_0` + 1 testbench. Chi tiết từng bài:
`firmware_testbench/SE-RISSP_FULL/README.md`, `firmware_testbench/RV32I_FULL/README.md`, `firmware_testbench/Ibex_FULL/README.md`.

1. Mở `.xpr` → Block Design → double-click `blk_mem_gen_0` → Other Options → Coe File =
   `firmware_testbench/SE-RISSP_FULL/<bai>.coe`.
2. Validate → chuột phải `design_1.bd` → **Reset Output Products** → **Generate Output Products**.
3. Add Sources (simulation) → testbench tương ứng → Set as Top → Run Behavioral Simulation.

`.coe` đang nạp sẵn khi mở: SE-RISSP_AES_ULTRA = `sha3.coe` · RV32I_soc_ULTRA = `rsa2048.coe` ·
Ibex_SoC = `rsa2048.coe` · 3 project wolfSSL = `rissp_wolfssl.coe`.

Ibex chạy không cần GUI: `firmware_testbench/Ibex_FULL/run_all.bat tb_ibex_ecb aes_ecb`
(đặt biến `XILINX_VIVADO` nếu Vivado không nằm ở `F:\vivado\Vivado\2024.2`).

## ⚠️ Trạng thái cần biết

- **RV32I_soc_ULTRA đã nâng IP `rv32i_fixed` lên revision 2** (2026-10-08, sửa bug SRA
  `>>`→`>>>` trong `ALU.v` — khác rev 1 đúng 1 dòng). Không còn IP bị khoá. Chu kỳ 8/8 workload
  không đổi (firmware không dùng SRA/SRAI), nhưng **LUT/FF/Power/WNS của RV32I trong CLAUDE.md là số
  rev 1 → chạy lại Synthesis + Implementation để lấy số mới** trước khi đưa vào paper.
- **Ibex_SoC**: project đặt define `SYNTHESIS` cho mô phỏng (bắt buộc — tắt DPI-C của lowRISC).
  Run Simulation GUI tự dùng; nếu tự viết flow dòng lệnh phải thêm `-d SYNTHESIS` cho `xvlog`.
- **3 project wolfSSL**: chỉ RV32I_software có testbench SoC (`tb_wolfssl_software`, `tb_aes_sha3_multi`).
  Số liệu wolfSSL của RISSP/Ibex đo bằng testbench cô lập `RISSP_cORE/firmware_SW_Crypto/wolfssl_build/tb_isolate_*.v`.
  RSA-2048 wolfSSL chạy ~7 giờ mô phỏng.
- Các script `.tcl` lịch sử trong `RISSP_cORE/firmware_SW_Crypto/` còn đường dẫn tuyệt đối của máy gốc
  (`F:/`, `D:/`) — sửa trước khi dùng.

## Khác biệt so với máy gốc (chỉ để chạy được ở máy khác)

- Các đường dẫn tuyệt đối của máy phát triển và thư mục board XHub đã được đổi sang đường dẫn tương đối trong repository.
- 3 project wolfSSL: gỡ tham chiếu tới file của nhánh "phần mềm tự viết tay" đã xoá
  (`*_sw.coe`, `tb_*_software.v`); RISSP_software/Ibex_software đổi `.coe` từ file đã xoá sang
  `rissp_wolfssl.coe` và sinh lại `blk_mem_gen_0`.
- Ibex_SoC: gỡ 56 tham chiếu mô phỏng tới `ipshared/7317` (thư mục không còn tồn tại từ khi đóng gói lại IP).
- `Ibex_FULL/run_manual_sim.tcl`, `run_all.bat`: đường dẫn theo vị trí script; dùng file IP gộp
  `ibex_axi_top_combined.sv` (bản gốc tìm 56 file lẻ đã không còn → script gốc đang hỏng).
- Không đưa lên: `*.runs`, `*.sim`, `*.cache`, bitstream, log (tự sinh lại).

## Kết quả kiểm chứng trên bản clone (2026-10-08, Vivado 2024.2)

| Kiểm tra | Kết quả |
|---|---|
| Mở 6 project: file thiếu / file trỏ ra ngoài repo / IP repo thiếu | 0 / 0 / 0 |
| Board ZedBoard | tìm thấy (3 SoC chính) |
| Validate BD / IP bị khoá | OK 6/6 / 0 |
| SE-RISSP_AES_ULTRA · `tb_sha3` | PASS, PURE 492 ck |
| Ibex_SoC · `tb_ibex_rsa2048` | PASS, PURE 320974 ck |
| Ibex_SoC · `run_manual_sim.tcl tb_ibex_ecb` | PASS, PURE 90 ck |
| RV32I_soc_ULTRA (rev 2) · 8 workload | 8/8 PASS: ECB 93 · CBC/CFB/CTR 129 · SHA3 500/1911/7419 · RSA 321039 ck |
| RV32I_soc_ULTRA (rev 1, trước nâng cấp) · Run Synthesis | Complete, 0 error, 0 critical warning |

Số chu kỳ khớp đúng bảng trong `RISSP_cORE/CLAUDE.md`.
