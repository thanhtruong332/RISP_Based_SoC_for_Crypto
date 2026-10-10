# Tập lệnh của core RISSP

Liệt kê **đầy đủ** các lệnh mà core RISSP (bản tối ưu 1018 LUT) thực thi
được, trích trực tiếp từ RTL trong `RISSP_CORE/` — không phải từ tài liệu:
`modular_ex.v` (mux theo opcode) + 6 type-block + 3 khối dùng chung
(`alu_adder.v`, `comparator.v`, `barrel_shifter.v`).

**Tổng: 35 lệnh** (RV32I chuẩn có 37 lệnh tính toán + 3 lệnh hệ thống = 40).

---

## Bảng tổng hợp nhanh

| Nhóm | Opcode | Số lệnh | Danh sách |
|---|---|---:|---|
| R-type | `0110011` | 10 | ADD SUB SLL SLT SLTU XOR SRL SRA OR AND |
| I-type ALU | `0010011` | 9 | ADDI SLTI SLTIU XORI ORI ANDI SLLI SRLI SRAI |
| LOAD | `0000011` | 3 | LB LW LBU |
| STORE | `0100011` | 3 | SB SH SW |
| Branch | `1100011` | 6 | BEQ BNE BLT BGE BLTU BGEU |
| Jump | `1101111` / `1100111` | 2 | JAL JALR |
| Upper-imm | `0110111` / `0010111` | 2 | LUI AUIPC |

---

## 1. R-type — `opcode = 0110011`

Khối: `r_type_block.v` (chỉ còn XOR/OR/AND + mux chọn) + 3 khối dùng chung.

| funct3 | funct7 / `insn[30]` | Lệnh | Chức năng | Phần cứng thực thi |
|:---:|:---:|---|---|---|
| `000` | `0000000` (bit30=0) | **ADD** | `rd = rs1 + rs2` | `alu_adder` (dùng chung) |
| `000` | `0100000` (bit30=1) | **SUB** | `rd = rs1 - rs2` | `alu_adder` (dùng chung) |
| `001` | `0000000` | **SLL** | `rd = rs1 << rs2[4:0]` | `barrel_shifter` (dùng chung) |
| `010` | `0000000` | **SLT** | `rd = (rs1 <ₛ rs2) ? 1 : 0` | `comparator` (dùng chung) |
| `011` | `0000000` | **SLTU** | `rd = (rs1 <ᵤ rs2) ? 1 : 0` | `comparator` (dùng chung) |
| `100` | `0000000` | **XOR** | `rd = rs1 ^ rs2` | logic riêng trong `r_type_block` |
| `101` | `0000000` (bit30=0) | **SRL** | `rd = rs1 >> rs2[4:0]` (logic) | `barrel_shifter` |
| `101` | `0100000` (bit30=1) | **SRA** | `rd = rs1 >>> rs2[4:0]` (số học) | `barrel_shifter` |
| `110` | `0000000` | **OR** | `rd = rs1 \| rs2` | logic riêng |
| `111` | `0000000` | **AND** | `rd = rs1 & rs2` | logic riêng |

---

## 2. I-type ALU — `opcode = 0010011`

Khối: `i_type_block.v`. Immediate: `imm = SignExt(insn[31:20])` (12-bit).

| funct3 | `insn[30]` | Lệnh | Chức năng | Phần cứng |
|:---:|:---:|---|---|---|
| `000` | — | **ADDI** | `rd = rs1 + imm` | `alu_adder` (dùng chung) |
| `010` | — | **SLTI** | `rd = (rs1 <ₛ imm) ? 1 : 0` | `comparator` (dùng chung) |
| `011` | — | **SLTIU** | `rd = (rs1 <ᵤ imm) ? 1 : 0` | `comparator` (dùng chung) |
| `100` | — | **XORI** | `rd = rs1 ^ imm` | logic riêng |
| `110` | — | **ORI** | `rd = rs1 \| imm` | logic riêng |
| `111` | — | **ANDI** | `rd = rs1 & imm` | logic riêng |
| `001` | `0` | **SLLI** | `rd = rs1 << shamt` | `barrel_shifter` |
| `101` | `0` | **SRLI** | `rd = rs1 >> shamt` (logic) | `barrel_shifter` |
| `101` | `1` | **SRAI** | `rd = rs1 >>> shamt` (số học) | `barrel_shifter` |

`shamt = insn[24:20]` (5 bit).

> **Lưu ý lịch sử**: SRAI/SRA từng bị bug tính thành dịch logic (ternary trộn
> `$signed()`/unsigned). Đã sửa bằng if-else tường minh trong
> `barrel_shifter.v`, verify lại PASS.

---

## 3. LOAD — `opcode = 0000011` ⚠️ **chỉ 3/5 lệnh**

Khối: `i_type_block.v`. Địa chỉ `rs1 + imm` tính bằng `alu_adder` dùng chung.
Byte-lane chọn theo `addr[1:0]` (bus dữ liệu 32-bit).

| funct3 | Lệnh | Chức năng |
|:---:|---|---|
| `000` | **LB** | nạp 1 byte, **sign-extend** lên 32-bit |
| `010` | **LW** | nạp nguyên 32-bit |
| `100` | **LBU** | nạp 1 byte, **zero-extend** lên 32-bit |
| `001` | ~~LH~~ | ❌ **KHÔNG CÓ** — rơi vào `default`, trả về `0` |
| `101` | ~~LHU~~ | ❌ **KHÔNG CÓ** — rơi vào `default`, trả về `0` |

---

## 4. STORE — `opcode = 0100011`

Khối: `s_type_block.v` (có adder `rs1+imm` riêng, độc lập theo paper).
Immediate: `imm = SignExt({insn[31:25], insn[11:7]})`.

| funct3 | Lệnh | `dmem_wstrb` sinh ra theo `addr[1:0]` |
|:---:|---|---|
| `000` | **SB** | `0001` / `0010` / `0100` / `1000` (theo `addr[1:0]` = 00/01/10/11) |
| `001` | **SH** | `0011` (`addr[1]=0`) hoặc `1100` (`addr[1]=1`) |
| `010` | **SW** | `1111` |

> **Lưu ý lịch sử**: SB/SH từng bị bug luôn ghi thành full-word
> (`s_type_block` chưa được nối vào `modular_ex`). Đã sửa và verify.

---

## 5. Branch — `opcode = 1100011`

Khối: `b_type_block.v` — **hoàn toàn độc lập**, có comparator + adder riêng
(không dùng chung với R/I-type).
Immediate: `imm = SignExt({insn[31], insn[7], insn[30:25], insn[11:8], 1'b0})`.
`next_pc = taken ? (pc + imm) : (pc + 4)`.

| funct3 | Lệnh | Điều kiện nhảy |
|:---:|---|---|
| `000` | **BEQ** | `rs1 == rs2` |
| `001` | **BNE** | `rs1 != rs2` |
| `100` | **BLT** | `rs1 <ₛ rs2` (có dấu) |
| `101` | **BGE** | `rs1 ≥ₛ rs2` (có dấu) |
| `110` | **BLTU** | `rs1 <ᵤ rs2` (không dấu) |
| `111` | **BGEU** | `rs1 ≥ᵤ rs2` (không dấu) |

---

## 6. Jump

| Opcode | Lệnh | next_pc | rd | Khối |
|---|---|---|---|---|
| `1101111` | **JAL** | `pc + imm_J` | `pc + 4` | `j_type_block.v` (adder riêng) |
| `1100111` | **JALR** | `(rs1 + imm_I) & ~1` | `pc + 4` | `alu_adder` dùng chung |

`imm_J = SignExt({insn[31], insn[19:12], insn[20], insn[30:21], 1'b0})`.
JALR xoá bit 0 của địa chỉ đích đúng chuẩn RV32I.
`rdest_data = pc + 4` do chính `modular_ex` tính (dùng chung 1 adder cho cả
JAL lẫn JALR, không để mỗi block có adder `pc+4` riêng).

---

## 7. Upper-immediate

Khối: `u_type_block.v`. `imm = {insn[31:12], 12'b0}`.

| Opcode | Lệnh | Chức năng | Chi phí |
|---|---|---|---|
| `0110111` | **LUI** | `rd = imm` | miễn phí (không qua adder) |
| `0010111` | **AUIPC** | `rd = pc + imm` | 1 adder — đã xác nhận tối thiểu |

> **Lưu ý lịch sử**: AUIPC từng bị **bỏ sót hoàn toàn** (không có case trong
> `modular_ex`). Đã thêm và verify.

---

## ❌ Những gì core KHÔNG hỗ trợ

| Lệnh / nhóm | Hành vi khi gặp | Mức nguy hiểm |
|---|---|---|
| **LH**, **LHU** | Trả về `0`, **không báo lỗi** | 🔴 **Cao** — xem cảnh báo dưới |
| **FENCE** (`0001111`) | `default: ;` → chạy như NOP | 🟢 Thấp (single-cycle, không cần) |
| **ECALL**, **EBREAK** (`1110011`) | `default: ;` → chạy như NOP | 🟡 Không có OS/debug |
| **CSR** (Zicsr: CSRRW/CSRRS/…) | `default: ;` → NOP | 🟡 Không có thanh ghi hệ thống |
| **M extension** (MUL/DIV/REM) | `default: ;` → NOP | 🟡 Phải làm nhân/chia bằng phần mềm |
| A / F / D / C extension | Không có | 🟢 Ngoài phạm vi RV32I |

### 🔴 Cảnh báo quan trọng về LH/LHU

Đây là cạm bẫy nguy hiểm nhất: `i_type_block.v` chỉ decode `funct3` =
`000`/`010`/`100` cho LOAD; `001` (LH) và `101` (LHU) rơi vào `default` và
**trả về 0 một cách âm thầm** — không exception, không cờ báo lỗi.

Trình biên dịch C **rất hay sinh LH/LHU** khi gặp `short`, `int16_t`,
`uint16_t`, hoặc khi truy cập struct có trường 16-bit. Chương trình sẽ
biên dịch sạch, chạy không crash, nhưng **đọc ra toàn số 0**.

**Đây là lý do toàn bộ firmware trong `firmware_HashImage/`,
`firmware_OTA/` và `firmware_testbench/SE-RISSP_FULL/` đều viết bằng assembly
thuần, chỉ dùng `lw`/`sw`.**

Nếu muốn viết firmware bằng C, chọn 1 trong 2:
1. Chỉ dùng kiểu 32-bit (`int`, `uint32_t`) và tránh `short`/`int16_t`,
   rồi kiểm tra lại bằng `objdump -d | grep -E "\blhu?\b"` để chắc chắn
   không có lệnh nào lọt.
2. Bổ sung LH/LHU vào `i_type_block.v` — **chi phí rất nhỏ**, vì mux
   byte-lane + sign-extend đã có sẵn ở đó cho LB/LBU, chỉ cần thêm 2 nhánh
   `case` chọn half-word (`addr[1]`) tương tự cách `s_type_block` đã làm
   cho SH.

---

## Ghi chú kiến trúc

- **`rdest_addr = insn[11:7]`** được `modular_ex` decode **1 lần duy nhất**
  dùng chung mọi opcode (không block nào tự decode lại).
- **`rf_wen`** bật cho: R-type, I-type ALU, LOAD, LUI, AUIPC, JAL, JALR.
  Tắt cho: STORE, Branch.
- **`x0`** được bảo vệ ở **cả 2 đường** trong `register_file.v`: đường đọc
  có mux `(addr == 0) ? 0 : regs[addr]` (không phụ thuộc reset — đây là lý
  do bỏ được vòng reset toàn mảng, tiết kiệm 495 LUT), và đường ghi có điều
  kiện `wen && (rdest_addr != 0)`.
- **3 khối dùng chung** giữa R-type và I-type (`alu_adder`, `comparator`,
  `barrel_shifter`) là 3 nhượng bộ **duy nhất** của kiến trúc song song;
  B/J/U/S-type vẫn 100% độc lập. Xem `CLAUDE.md` mục "Các lần gộp phần cứng".

## ⚠️ Ràng buộc bắt buộc khi tích hợp SoC

`fetch_stage.v` yêu cầu bộ nhớ lệnh (imem) có **độ trễ đọc đúng 1 chu kỳ**
(nó phát `imem_addr = next_pc` sớm 1 chu kỳ). Nếu BRAM cấu hình 2 chu kỳ
(bật "Register PortA Output of Memory Primitives"):

- **Mọi lệnh nhánh rẽ** (6 lệnh Branch + JAL + JALR) **tính sai địa chỉ
  đích** → CPU treo.
- Code thẳng dòng vẫn chạy nhưng **kết quả `lw` về trễ 1 lệnh** → dữ liệu
  ghi ra bị lệch 1 ô nhớ.

Đây là ràng buộc phần cứng, **không sửa được bằng firmware**. Chi tiết +
bằng chứng mô phỏng: `firmware_testbench/SE-RISSP_FULL/README.md`.

---

## Kiểm chứng

Toàn bộ 35 lệnh trên nằm trong `tb_rissp_top.v` với **43 phép kiểm tra
PASS** (6 lệnh branch được test ở **cả 2 trạng thái** taken/not-taken):

```
"F:\vivado\Vivado\2024.2\bin\xvlog.bat" *.v
"F:\vivado\Vivado\2024.2\bin\xelab.bat" tb_rissp_top -s tb_snap
"F:\vivado\Vivado\2024.2\bin\xsim.bat" tb_snap -R
```
