# RV32I_FIXED

Project Vivado chứa lõi **RV32I 5 tầng đã sửa lỗi đường fetch**, đóng gói sẵn
thành IP để kéo thẳng vào Block Design.

- Part: `xc7z020clg484-1` · Board: **ZedBoard** (`digilentinc.com:zedboard:part0:1.0`)
- IP: `xilinx.com:user:rv32i_fixed:1.0` — hiện trong IP Catalog với tên
  **RV32I Core (FIXED - imem 1-cycle)**
- IP repo: `F:\advance_topic\RV32I_FIXED\ip_repo\` (đã trỏ sẵn trong project)

Cổng của IP **giống hệt** `rv32i_pure` cũ (`M00_AXI`, `inst_addr`,
`inst_data`, `m00_axi_aclk/aresetn`, `m00_axi_init_axi_txn`) nên thay vào SoC
là nối dây y như cũ, **không đổi địa chỉ AXI, không sửa firmware**.

---

## Lỗi đã sửa

Lõi gốc được viết cho **bộ nhớ lệnh đọc tổ hợp** (`src/Instruction_memory.v`:
`assign Instruction = mem[pc[31:2]]`, độ trễ 0). SoC lại cấp cho nó
`blk_mem_gen` là **BRAM trễ 1 chu kỳ**. Thanh ghi dôi ra trong đường fetch
không nằm trong tầm kiểm soát của `Stall` và không được tính vào sổ sách PC,
sinh ra 2 lỗi độc lập:

**Lỗi 1 — mất đúng 1 lệnh mỗi lần stall.** `INST_ADDR` bám theo `pc`, mà `pc`
bị đóng băng khi stall → BRAM đọc lại địa chỉ đó và ghi đè lên lệnh đang chờ
ở ngõ ra. `IF_ID` tự giữ được nội dung của nó, nhưng không ai giữ hộ thanh
ghi bên trong BRAM.

Vì mọi lệnh nhớ đều gây stall, và firmware có nhịp `lui/addi/sw` = 3 lệnh —
đúng bằng khoảng cách fetch→MEM — nên nạn nhân luôn là **lệnh nhớ kế tiếp**.
Kết quả: 14 lệnh `sw` chỉ ra được **9** giao dịch AXI.

**Lỗi 2 — mọi branch/jump dư 4 byte.** `IF_ID_pc` chốt theo `pc_reg` hiện
tại, còn `INST_DATA` là lệnh của địa chỉ trước đó → lệch 1 nhịp. Vì
`branch_target = pc_of_instruction + offset` nên mọi `beq`/`jal` nhảy quá 4
byte. (Chứng cứ trên SoC thật: `j halt` ở `0xA8` là vòng lặp tại chỗ nhưng
PC max đo được là `0xB0`.)

## Cách sửa — giống cơ chế RISSP đã dùng

`rissp_top.v` dòng 18 + `fetch_stage.v` dòng 18 của repo RISSP_cORE.

`src/PC.v` — chỉ **thêm dây**, không đổi logic:
```verilog
output wire [31:0] next_pc_out;
assign next_pc_out = next_pc;
```

`src/rv32i_top.v` — thay 1 dòng:
```verilog
assign INST_ADDR = (!rst_n) ? 32'h0        // nap dung lenh dau tien
                 : (Stall)  ? pc           // giu lenh dang cho o ngo ra BRAM
                            : next_pc_w;   // gui dia chi som 1 chu ky
```

Không đụng `Control_unit`, `ALU`, `Forwarding_unit`, `Hazard_detection` hay
bất kỳ tầng pipeline nào.

> ⚠️ **Đã thử và SAI**: ép `Instruction` về NOP lúc reset. Nó ăn mất đúng 1
> nhịp fetch — lệnh thứ 2 (`lui x8`) bị nuốt, địa chỉ BRAM ra `0x00000000`
> thay vì `0xC0000000`. Không cần ép: `IF_ID` đã tự reset về 0, và mã lệnh
> `0x00000000` không khớp case nào trong `Control_unit` nên vốn đã là no-op.

## Đã verify

Mô phỏng cô lập (lõi + cầu AXI thật, imem mô hình BRAM trễ 1 chu kỳ, slave
AXI4-Lite luôn sẵn sàng), chạy `aes_ecb.hex`:

| | Trước sửa | Sau sửa |
|---|---:|---:|
| Giao dịch ghi (đúng 14) | **9** ❌ | **14** ✓ |
| Giao dịch đọc (đúng 5) | 6 (lặp/thiếu) ❌ | **5** ✓ |

Thứ tự và dữ liệu sau khi sửa — đúng hoàn toàn:
```
KEY  0x40000010/14/18/1C = 00010203 04050607 08090a0b 0c0d0e0f
PT   0x40000000/04/08/0C = 00112233 44556677 8899aabb ccddeeff
CTRL 0x40000020 = 1
đọc  0x40000030/34/38/3C  (mỗi địa chỉ đúng 1 lần)
BRAM 0xC0000000/04/08/0C/10
```

Tổng hợp OOC (`synth_design -mode out_of_context`, chiến lược mặc định):
**1625 LUT · 1695 FF · 0 LUTRAM**, không ERROR.

> Con số này **chưa so được** với 1018 LUT của RISSP: RISSP đo bằng
> `AreaOptimized_high` + `opt_design -directive ExploreArea`, còn lõi này vẫn
> đang giữ `DONT_TOUCH` trên RF/ALU/Control_unit/PC và vẫn reset toàn mảng
> thanh ghi trong `Register_file.v` (phá LUTRAM — RISSP đo được 495 LUT thật
> cho riêng chuyện này). Muốn so công bằng phải gỡ 2 thứ đó ở cả hai lõi
> trước.

## Cách dùng

1. Mở `RV32I_FIXED.xpr` → IP Catalog → **User Repository** → kéo
   *RV32I Core (FIXED - imem 1-cycle)* vào Block Design.
   Hoặc thêm `F:\advance_topic\RV32I_FIXED\ip_repo` vào *IP Repositories* của
   project SoC hiện có rồi thay khối `rv32i_pure_0` bằng khối này.
2. Nối y hệt khối cũ: `M00_AXI` → interconnect · `inst_addr` → `xlslice_0`
   (**phải là `[14:2]`, 13 bit**) · `inst_data` ← `blk_mem_gen_0/douta` ·
   clock/reset như cũ.
3. `blk_mem_gen_0` phải **tắt** *Register PortA Output of Memory Primitives*
   (độ trễ đúng 1 chu kỳ — lõi này giờ yêu cầu đúng hợp đồng đó).
4. Địa chỉ AXI giữ nguyên: AES `0x40000000` · SHA3 `0x44000000` · RSA
   `0x48000000` · UART `0x40600000` · BRAM `0xC0000000`.

Testbench đo chu kỳ: `firmware_testbench/RV32I_FULL/tb_rv32i_{ecb,cbc,cfb,ctr}.v`
— dùng lại được nguyên xi, chỉ cần đổi tên instance nếu khối trong BD đổi tên.

## Còn tồn đọng (chưa sửa, ngoài phạm vi yêu cầu)

- `Hazard_detection` và `Forwarding_unit` đọc `Instruction[24:20]` làm `rs2`
  cho **mọi** lệnh, kể cả lệnh không có `rs2`. Ví dụ thật trong firmware:
  `lw x21, 0x34(x11)` có `Instruction[24:20] = 0x14 = 20`, trùng `rd=20` của
  `lw x20` ngay trước → **hazard giả**, thêm bong bóng thừa. Chỉ tốn chu kỳ,
  không sai kết quả — nhưng làm RV32I chậm đi một cách không chính đáng nếu
  dùng làm baseline.
- Không hỗ trợ truy cập dưới word: `funct3` bị bỏ qua ở tầng MEM, `WSTRB`
  cứng `4'b1111` → LB/LBU/LH/LHU/SB/SH đều hành xử như LW/SW. Firmware crypto
  hiện tại chỉ dùng word nên không ảnh hưởng.
