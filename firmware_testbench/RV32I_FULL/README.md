# RV32I_FULL — testbench đo chu kỳ cho SoC dùng lõi RV32I

Bộ testbench cho `F:\advance_topic\RV32I_soc_ULTRA` (design_1_wrapper:
`rv32i_fixed_0` + AES + SHA3 + RSA + UART + BRAM debug, 40MHz, xc7z020).

Mục đích: đo số chu kỳ của hệ dùng lõi **RV32I 5 tầng** để đối chiếu trực
tiếp với bảng số liệu của hệ dùng **RISSP**.

## Firmware — dùng lại nguyên xi, không sửa gì

Bản đồ địa chỉ AXI của 2 SoC **trùng khít** (AES `0x40000000`, SHA3
`0x44000000`, RSA `0x48000000`, BRAM `0xC0000000`), nên `.coe` dùng chung.
Lấy tại `D:\Viettel_semi\SE-RISSP_FULL\`:

| Testbench | File `.coe` cần nạp vào `blk_mem_gen_0` |
|---|---|
| `tb_rv32i_ecb` | `aes_ecb.coe` (43 từ) |
| `tb_rv32i_cbc` | `aes_cbc.coe` (55 từ) |
| `tb_rv32i_cfb` | `aes_cfb.coe` (55 từ) |
| `tb_rv32i_ctr` | `aes_ctr.coe` (55 từ) |
| `tb_rv32i_sha3` | `sha3.coe` (150 từ) — 1 block, 128 B |
| `tb_rv32i_sha3_4` | `sha3_4.coe` (51 từ) — 4 block, 536 B |
| `tb_rv32i_sha3_16` | `sha3_16.coe` (51 từ) — 16 block, 2168 B |
| `tb_rv32i_rsa2048` | **`rsa2048.coe`** (731 từ) — RSA-2048 verify |
| `tb_rv32i_ecb_dbg` | `aes_ecb.coe` — bản trace, in mọi giao dịch AXI |

Đã kiểm chứng bằng cách giải mã toàn bộ `.coe`: chỉ dùng opcode
LUI/I/LOAD/STORE/BRANCH/JAL và **mọi truy cập bộ nhớ đều là word
(`funct3=2`)** — nên việc lõi RV32I bỏ qua `funct3` ở tầng MEM
(không có LB/LH/SB/SH thật) không ảnh hưởng.

> ⚠️ Nếu sau này chạy RSA: SoC này dùng `RSA_WIDTH=2048`
> (`C_S00_AXI_ADDR_WIDTH=12`) nên phải dùng **`rsa2048.coe`**, KHÔNG phải
> `rsa.coe` (bản 32-bit, bản đồ thanh ghi khác hẳn).

## Quy trình chạy

1. Vivado → mở `RV32I_soc_ULTRA.xpr`.
2. Block Design → `blk_mem_gen_0` → *Other Options* → `Load Init File` →
   trỏ tới file `.coe` tương ứng.
3. **Validate Design**.
4. Sources → chuột phải `design_1.bd` → **Reset Output Products** → rồi
   **Generate Output Products**.
   *(Bỏ bước Reset thì Vivado giữ MIF cũ và bạn sẽ đo lại đúng số của lần
   chạy trước — đã dính lỗi này thật.)*
5. Add Sources → *Add or create simulation sources* → thêm file
   `tb_rv32i_<mode>.v` → set làm **Top** của simulation set.
6. Run Simulation → Run Behavioral Simulation.

Kiểm tra nhanh đã nạp đúng `.coe`: nếu mốc chu kỳ in ra **giống hệt** lần
chạy mode khác thì MIF chưa đổi.

## Đọc kết quả

Testbench in 4 cửa sổ đo, **giống hệt** cách đo của bộ RISSP nên so sánh
được trực tiếp:

| | Nội dung |
|---|---|
| `[1]` Lõi AES | CTRL → `aes_done` — chỉ phần mã hoá |
| `[2]` **PURE** | PT[0] → đọc xong CT — **cơ sở đã chốt cho paper** |
| `[3]` FULL | KEY[0] → đọc xong CT |
| `[4]` END-TO-END | PT[0] → ghi xong 4 từ ra BRAM |

Mỗi testbench tự in luôn dòng `Chenh lech PURE: … ck so voi RISSP` để khỏi
phải tra tay.

Mốc của hệ RISSP (đã đo thật, 40MHz) — mỗi testbench tự in kèm dòng
`Chenh lech PURE` nên không phải tra tay:

| Bài | Lõi | PURE | E2E |
|---|---:|---:|---:|
| AES ECB | 16 | **88** | 117 |
| AES CBC / CFB / CTR | 16 | **124** | 153 |
| SHA3 1 block | 28 | **492** | 549 |
| SHA3 4 block | 28 | **1771** | 1828 |
| SHA3 16 block | 28 | **6871** | 6928 |
| RSA-2048 | 319813 | *321105 (chưa chạy lại)* | *321179* |

> ⚠️ Số RISSP ở trên là **sau khi sửa `axi_rissp_master`** (2026-08-13, bỏ độ
> trễ 1 ck của `write_done_all`). Riêng RSA-2048 vẫn là số **trước** khi sửa —
> cần chạy lại `tb_rsa2048` trên SoC RISSP; ước tính ~320850 sau khi sửa.

## Hai lưu ý về số liệu

**`POWER_W = 0.365` là công suất của SoC RISSP**, đặt tạm để công thức chạy
được — SoC RV32I chưa Run Implementation. ⇒ **cột chu kỳ là số đúng**; mọi
số `nJ` và `Mbps/W` còn tạm thời. Sau khi Run Impl, thay `POWER_W` bằng
Total On-Chip Power của chính project này rồi chạy lại.

**Cầu AXI của 2 lõi ĐÃ được cân bằng** (2026-08-13). Trước đó
`axi_rissp_master` chốt kết thúc bằng `write_done_all` tính từ cờ đã thanh ghi
→ trễ 1 ck, tốn **5 ck/giao dịch** so với **4 ck** của cầu RV32I. Đã sửa: chốt
theo bắt tay B (chuẩn AXI cấm slave phát `BVALID` trước khi nhận đủ AW+W, nên
B đã hàm ý AW/W xong) và theo bắt tay R. Bỏ được 5 thanh ghi cờ ⇒ module
**nhỏ đi**: LUT 22→15, FF 146→141, và `tb_rissp_top` vẫn PASS 43/43.

⇒ Hai lõi giờ chạy cùng một cầu về mặt chi phí, nên số liệu so sánh là
vi kiến trúc thuần. Ibex dùng chung `axi_rissp_master` nên **phải đồng bộ bản
mới sang `IBEX_CORE/rtl/`** trước khi đo, nếu không Ibex bị thiệt 1 ck/giao dịch.

## Kết quả đã đo — RISSP thắng 7/7

Cơ sở PURE, 40 MHz, cùng SoC, cùng firmware, cùng cầu AXI:

| Workload | RISSP | RV32I | Δ | RISSP nhanh hơn | Tách nguyên nhân |
|---|---:|---:|---:|---:|---|
| AES-128 ECB | 88 | 93 | 5 | 5,4% | 5 đọc × 1 |
| AES-128 CBC | 124 | 129 | 5 | 3,9% | 5 đọc × 1 |
| AES-128 CFB | 124 | 129 | 5 | 3,9% | 5 đọc × 1 |
| AES-128 CTR | 124 | 129 | 5 | 3,9% | 5 đọc × 1 |
| SHA3-256 · 1 block | 492 | 500 | 8 | 1,6% | 8 đọc × 1 |
| SHA3-256 · 4 block | 1771 | 1911 | 140 | 7,3% | 66 nhánh×2 + 8 đọc |
| SHA3-256 · 16 block | 6871 | 7419 | 548 | 7,4% | 270 nhánh×2 + 8 đọc |
| RSA-2048 | *chưa* | *chưa* | | *dự kiến ~0%* | CPU chỉ đứng nhìn |

Toàn bộ khoảng cách quy về **đúng hai hằng số**, cả hai truy ngược ra được RTL:

- **1,00 ck / lần đọc** — `axi_rissp_master` bật `RREADY` ngay ở `IDLE`; cầu
  RV32I phải đợi bắt tay `ARREADY` xong.
- **2,00 ck / nhánh taken** — `Flush = (ID_EX_Branch && Branch_taken) ||
  ID_EX_Jump` của RV32I xoá cả `IF_ID` lẫn `ID_EX`; RISSP single-cycle không có
  bong bóng. Module `Branch_prediction` của RV32I **không phải** bộ dự đoán —
  nó chỉ đánh giá điều kiện, tên gây hiểu nhầm.

Nhóm đối chứng: SHA3 1-block chạy firmware **unroll, 0 nhánh** → giai đoạn nạp
message ra **397 = 397**, chênh lệch biến mất sạch. Chi phí mỗi từ 64-bit:
RISSP **25,00 ck** · RV32I **27,00 ck** — lệch đúng 2,00.

Với AES, bốn trong năm giai đoạn bằng nhau từng chu kỳ một
(`KEY→PT` 36=36 · `PT→CTRL` 35=35 · `CTRL→done` 16=16 · `CT→BRAM` 29=29);
toàn bộ chênh lệch dồn vào `done→CT` (37 vs 42).
