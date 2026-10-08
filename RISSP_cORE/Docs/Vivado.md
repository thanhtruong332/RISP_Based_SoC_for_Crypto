# Đóng gói RISSP_CORE thành IP block trong Vivado

Hướng dẫn từng bước để đóng gói `rissp_top` (đã tối ưu LUT + fix bug, xem
`CLAUDE.md`) thành 1 IP tái sử dụng được, add vào Block Design (IP
Integrator), và kết nối vào SoC (ví dụ Zynq-7000, board ZedBoard/PYNQ-Z1,
part `xc7z020clg484-1` — đúng part đã dùng để đo LUT).

## 0. Hiểu rõ giao diện của `rissp_top` trước khi đóng gói

`rissp_top.v` có 3 nhóm cổng, cần đối xử KHÁC NHAU khi package:

| Nhóm cổng | Loại | Cách kết nối trong SoC |
|---|---|---|
| `clk`, `rst_n` | Clock/Reset thường | Vivado tự nhận diện, auto-connect được. **`rst_n` là ACTIVE-LOW** (chú ý cực tính). |
| `imem_addr` (out), `imem_rdata` (in) | Cổng bộ nhớ lệnh kiểu BRAM 1-cycle latency, **KHÔNG phải AXI** | Không auto-connect được — phải nối tay vào 1 Block Memory Generator (xem Bước 6). |
| `m_axi_*` (awaddr/awprot/awvalid/awready, wdata/wstrb/wvalid/wready, bresp/bvalid/bready, araddr/arprot/arvalid/arready, rdata/rresp/rvalid/rready) | **AXI4-LITE MASTER** | Auto-connect được vào Interconnect/PS qua Connection Automation (Bước 5). |

**Lưu ý quan trọng về `m_axi_*`**: bộ tín hiệu này **không có** `awlen/awsize/
awburst/arlen/arsize/arburst/awid/arid/wlast/rlast` — tức là **AXI4-LITE**,
không phải AXI4 đầy đủ (không hỗ trợ burst). Khi package, phải xác nhận
Vivado gán đúng interface type là **AXI4LITE** (xem Bước 2, mục "Ports and
Interfaces") — nếu bị gán nhầm thành AXI4 đầy đủ, Connection Automation ở
Bước 5 có thể báo lỗi hoặc kết nối sai.

**Về kiến trúc SoC**: RISSP có bộ nhớ lệnh (`imem`) **riêng, tách biệt**
khỏi hệ thống AXI — đây là core dạng "accelerator/co-processor" với chương
trình lệnh nạp riêng vào 1 BRAM cục bộ (qua Bước 6), **không phải** CPU dùng
chung không gian địa chỉ chương trình với lõi ARM của Zynq PS. Đường AXI
Master (`m_axi_*`) chỉ dùng để RISSP truy cập **dữ liệu** (LOAD/STORE) vào bộ
nhớ hệ thống (DDR qua PS, hoặc 1 vùng BRAM/AXI slave khác).

## 1. Chuẩn bị danh sách file nguồn cần đóng gói

Chỉ đóng gói **14 file RTL synthesizable**, **KHÔNG** đưa `tb_rissp_top.v`
(testbench, không tổng hợp được) vào fileset chính:

```
rissp_top.v          <- top module, chọn làm "Top" khi package
modular_ex.v
r_type_block.v
i_type_block.v
b_type_block.v
j_type_block.v
u_type_block.v
s_type_block.v
barrel_shifter.v      (dùng chung R-type/I-type)
comparator.v          (dùng chung R-type/I-type)
alu_adder.v           (dùng chung R-type/I-type)
register_file.v
fetch_stage.v
axi_rissp_master.v
```

**QUAN TRỌNG (sửa lỗi hay gặp `[Ipptcl 7-1483] No files matching ... found`)**:
bước "Package a specified directory" ở dưới KHÔNG PHẢI chỉ là nơi *xuất* IP
ra — Vivado **quét ngay thư mục bạn trỏ tới để tìm file RTL có sẵn**. Nếu trỏ
vào 1 thư mục rỗng (chưa có `.v` nào), Vivado báo lỗi ngay vì không tìm thấy
gì để đóng gói.

**Cấu trúc 2 tầng đang dùng (đã dọn sẵn, không cần làm lại)**:
- **`F:\RISSP_cORE\RISSP_CORE\`** — bản "gốc sạch": chỉ chứa đúng 14 file
  `.v` liệt kê ở trên, phẳng, giống hệt cấu trúc `AES_CORE`. Đây là nơi
  DUY NHẤT bạn nên sửa file khi cần cập nhật RTL cho IP (không sửa trực tiếp
  trong `D:\SE_RISSP_LIBRARY\...` để tránh lệch bản).
- **`D:\SE_RISSP_LIBRARY\RISSP_CORE_NEW\`** — bản "thư viện", đã đồng bộ y
  hệt nội dung `RISSP_CORE\` ở trên (đã copy sẵn, đã dọn sạch mọi file rác
  Vivado sinh ra từ lần thử trước). Đây là thư mục bạn **trỏ wizard vào**
  ở Bước 2 — vì nó nằm ngay trong `D:\SE_RISSP_LIBRARY` (nơi bạn quản lý các
  IP khác như AES, RSA, SHA3,...), tiện theo dõi chung.

Mỗi khi sửa RTL trong `F:\RISSP_cORE\RISSP_CORE\`, nhớ đồng bộ lại sang
`D:\SE_RISSP_LIBRARY\RISSP_CORE_NEW\` (copy đè 14 file `.v`, không đụng vào
`component.xml`/`xgui` nếu đã package rồi) trước khi mở lại wizard package —
xem Bước 10 để biết quy trình cập nhật IP đầy đủ.

*(Ghi chú riêng: có 1 file `rissp_constr.xdc` — ràng buộc timing kèm ghi chú
về cách so sánh công bằng RISSP với RV32I — được tìm thấy trong lần thử
trước và đã copy giữ lại ở `F:\RISSP_cORE\rissp_constr.xdc`. File này KHÔNG
cần đưa vào lúc package IP (constraints thường gán ở project SoC cuối cùng,
không nằm trong IP) — chỉ cần biết nó vẫn còn, không bị mất.)*

## 2. Mở wizard "Create and Package New IP"

1. Mở Vivado (không nhất thiết cần project — wizard này tạo project tạm
   riêng để package).
2. Menu **Tools → Create and Package New IP…**
3. Màn hình chào mừng → **Next**.
4. Chọn **"Package a specified directory"** (KHÔNG chọn "Create a new AXI4
   peripheral" — cái đó sinh code mẫu mới, không dùng RTL đã có; cũng không
   chọn "Package your current project" vì ta chưa có project chứa sẵn RTL).
5. Ở màn "Package a Specified Directory":
   - **Specify local or remote repository path**: gõ/browse tới thư mục thư
     viện IP đã copy sẵn RTL vào, ví dụ **`D:\SE_RISSP_LIBRARY\RISSP_CORE_NEW`**
     (xem lưu ý ở Bước 1 — thư mục này PHẢI đã có sẵn 14 file `.v` từ trước,
     không được trỏ vào thư mục rỗng).
   - **Next**.
6. Vivado tạo 1 project tạm và mở giao diện **Package IP** (nhiều tab bên
   trái: Identification, Compatibility, File Groups, Customization
   Parameters, Ports and Interfaces, Customization GUI, Review and Package).

### Tab "Identification"
- **Vendor**: tên bạn/tổ chức, ví dụ `rissp.local` (không bắt buộc domain
  thật).
- **Library**: `user` (mặc định, để nguyên).
- **Name**: `rissp_core`.
- **Version**: `1.0`.
- **Display Name**: `RISSP RV32I Core`.
- **Description**: mô tả ngắn, ví dụ "Single-cycle RV32I core, modular
  parallel execution, AXI4-Lite master datapath".

### Tab "Compatibility"
- Tick family **Zynq-7000** (vì đã đo LUT trên `xc7z020clg484-1`). Nếu chưa
  chắc board đích, có thể để "All" nhưng tick riêng Zynq-7000 giúp IP hiện
  đúng khi lọc trong IP Catalog của project SoC sau này.

### Tab "File Groups"
1. Kiểm tra danh sách **"Design Sources"** — vì thư mục thư viện đã chỉ chứa
   sẵn đúng 14 file RTL (không có `tb_rissp_top.v`), Vivado thường tự quét
   ra đủ và đúng ngay. Nếu thiếu file nào, dùng nút **"Add Files"** (biểu
   tượng dấu +) để bổ sung.
   - *Nếu bạn trỏ thẳng wizard vào `F:\RISSP_cORE` (cách thay thế nêu ở Bước
     1) thay vì thư mục thư viện riêng*: Vivado sẽ tự quét thấy luôn cả
     `tb_rissp_top.v` và đưa vào Design Sources — phải tìm file này trong
     danh sách → chuột phải → **"Remove File..."** (chọn gỡ tham chiếu,
     không xoá file thật trên ổ đĩa) vì nó là testbench, không tổng hợp
     được.
2. Chuột phải vào `rissp_top.v` trong danh sách → **"Set as Top"** (nếu chưa
   tự nhận đúng top module).
3. (Tuỳ chọn) Muốn đóng gói kèm `tb_rissp_top.v` để người dùng IP có sẵn bài
   test tham khảo: copy thêm file này vào thư mục thư viện, rồi trong Package
   IP bấm nút **"Advanced"** ở trên bảng File Groups → chuyển sang fileset
   **Simulation** (`xilinx_anylanguagesimulation` / "sim_1") → **"Add
   Files"** → add `tb_rissp_top.v` vào ĐÓ, không phải vào Design Sources.

### Tab "Ports and Interfaces" — bước quan trọng nhất
1. Vivado tự động quét cổng của `rissp_top` và cố suy luận (auto-infer) các
   chuẩn bus interface dựa theo tên tín hiệu. Nếu danh sách chưa xuất hiện
   đầy đủ, bấm nút **"Merge changes from File Groups Wizard"** hoặc chuột
   phải vùng trống → **"Auto Infer Interfaces"**.
2. Sau khi auto-infer, kiểm tra kỹ từng dòng:
   - **`clk`** → phải hiện là 1 Clock interface (icon đồng hồ), Mode =
     *System* hoặc *Slave* (clock input luôn là slave theo quy ước IP-XACT).
   - **`rst_n`** → phải hiện là 1 Reset interface. Click vào dòng này, xem
     panel **"Interface Properties"** bên dưới → tìm thuộc tính
     **POLARITY** → phải là **ACTIVE_LOW**. Nếu Vivado tự suy luận sai thành
     ACTIVE_HIGH (hiếm khi xảy ra vì tên có hậu tố `_n`, nhưng vẫn nên kiểm
     tra), sửa lại thủ công tại đây — **sai bước này sẽ khiến core bị treo
     reset vĩnh viễn khi tích hợp vào SoC thật**.
   - **Nhóm `m_axi_*`** → phải gộp thành 1 dòng interface duy nhất, cột
     "Interface Name" hiện dạng `M_AXI` (hoặc tương tự), **Mode = Master**.
     Click vào dòng này, xem **"Interface Properties"**:
     - Thuộc tính bus definition phải là **AXI4LITE** (không phải AXI4). Nếu
       Vivado lỡ gán thành AXI4 đầy đủ: xoá interface này (chọn dòng → phím
       Delete), rồi chuột phải vùng trống → **"Add Bus Interface..."** → chọn
       kiểu **AXI4** trong danh sách nhưng ở bước cấu hình chi tiết chọn rõ
       **"Interface Mode: Master"** và **"AXI4LITE"** ở phần Protocol, sau đó
       map thủ công từng tín hiệu `m_axi_awaddr → AWADDR`, `m_axi_awvalid →
       AWVALID`, ... (map đúng tên hậu tố, Vivado thường tự gợi ý đúng nếu
       tên tín hiệu đã theo chuẩn — mà tên trong `rissp_top.v` ĐÃ theo đúng
       chuẩn AXI (`m_axi_awaddr`, `m_axi_wdata`,...) nên trường hợp phải map
       tay thường không xảy ra).
     - **ASSOCIATED_CLKS**: đảm bảo trỏ đúng tới `clk` (thường tự động vì
       thiết kế chỉ có 1 clock).
     - **ASSOCIATED_RESETS**: trỏ tới `rst_n`.
   - **`imem_addr`, `imem_rdata`** → sẽ **KHÔNG** được gộp vào interface nào
     (không có chuẩn bus tương ứng với kiểu cổng BRAM đơn giản này) — đây là
     **bình thường và đúng như dự kiến**. Cứ để chúng ở dạng "External Port"
     (cổng rời), sẽ nối tay ở Bước 6.
3. Nếu có cổng nào lẽ ra phải là input/output nhưng Vivado hiện sai chiều —
   sửa lại ở cột "Direction" ngay trong bảng.

### Tab "Customization Parameters"
- RTL hiện tại không có `parameter` Verilog nào (không tham số hoá độ rộng
  địa chỉ, độ sâu bộ nhớ, v.v.) → tab này **để trống**, bấm Next.

### Tab "Customization GUI"
- Không cần chỉnh (chỉ dùng khi có Customization Parameters ở trên) → Next.

### Tab "Review and Package"
- Xem lại toàn bộ tóm tắt (VLNV, số file, số interface).
- Bấm **"Package IP"** (nút ở góc dưới bên phải) để hoàn tất — Vivado sinh
  file `component.xml` cùng toàn bộ RTL đã copy vào thư mục IP đích, đóng
  project tạm.

## 3. Thêm IP Repository vào project SoC đích

1. Mở (hoặc tạo mới) project Vivado cho SoC, target part đúng board dùng
   thật (ví dụ `xc7z020clg484-1` cho ZedBoard).
2. **File → Project Settings…** (hoặc icon bánh răng "Settings" ở Project
   Manager) → mục **IP → Repository**.
3. Bấm **"+"** (Add Repository...) → trỏ tới thư mục thư viện IP đã đóng gói
   ở Bước 2, ví dụ **`D:\SE_RISSP_LIBRARY\RISSP_CORE_NEW`** (hoặc thư mục cha
   `D:\SE_RISSP_LIBRARY` nếu sau này bạn để nhiều IP khác nhau làm nhiều thư
   mục con bên trong — Vivado quét đệ quy nên trỏ vào thư mục cha vẫn tìm ra
   hết).
4. Vivado quét và liệt kê IP tìm thấy (sẽ hiện `RISSP RV32I Core`) → **OK**.
5. Bấm **"Refresh All"** nếu IP Catalog chưa cập nhật ngay.
6. Kiểm tra: mở **IP Catalog** (Window → IP Catalog nếu chưa hiện sẵn), gõ
   tìm "rissp" → phải thấy IP xuất hiện dưới nhóm **"User Repository"**.

## 4. Tạo Block Design và add IP

1. **Flow Navigator → IP INTEGRATOR → Create Block Design** → đặt tên (ví
   dụ `soc_design`) → OK.
2. Trong canvas Block Design, bấm **"+"** (Add IP) → tìm `rissp_core` →
   double-click để thêm vào canvas.
3. Nếu SoC dùng Zynq PS: add thêm IP **"ZYNQ7 Processing System"** → sau khi
   thêm, banner xanh "Run Block Automation" xuất hiện ở đầu canvas → bấm
   **Run Block Automation** → tick chọn PS → Apply (cấu hình mặc định theo
   board, hoặc chỉnh DDR/clock theo board thật nếu dùng board file có sẵn).

## 5. Kết nối AXI Master của RISSP vào hệ thống

1. Sau khi có cổng `M_AXI` của `rissp_core` còn để trống trên canvas, banner
   xanh **"Run Connection Automation"** sẽ xuất hiện (hoặc bấm icon tương
   ứng ở đầu canvas thủ công).
2. Bấm **Run Connection Automation** → tick chọn `M_AXI` (của rissp_core) ở
   danh sách bên trái.
3. Ở panel bên phải, chọn đích kết nối:
   - **Nếu muốn RISSP truy cập DDR qua PS**: chọn cổng `S_AXI_HP0` (hoặc
     `S_AXI_GP0`) của Zynq PS. HP port cho băng thông cao hơn, phù hợp nếu
     RISSP truy cập dữ liệu nhiều; GP port đơn giản hơn, đủ dùng nếu chỉ
     LOAD/STORE ít.
   - **Nếu muốn RISSP dùng 1 vùng BRAM riêng làm dmem** (không qua PS): chọn
     tự thêm **AXI BRAM Controller** + **Block Memory Generator** — Vivado
     Connection Automation có thể tự đề xuất option "New AXI BRAM
     Controller" ngay trong danh sách đích kết nối.
4. Bấm **OK/Apply** — Vivado tự thêm **AXI Interconnect** (hoặc
   **SmartConnect** tuỳ version Vivado) + **Processor System Reset** + toàn
   bộ dây nối clock/reset cần thiết giữa RISSP, Interconnect, và đích đã
   chọn.
5. Vì `M_AXI` là AXI4-LITE, Interconnect/SmartConnect sẽ tự làm việc
   chuyển đổi protocol nếu đích là AXI4 đầy đủ (như HP port) — không cần
   chỉnh gì thêm. Nếu bước Connection Automation không hiện được lựa chọn
   đích hợp lý nào, quay lại kiểm tra mục "Interface Type = AXI4LITE" ở
   Bước 2.

## 6. Kết nối `imem` (bộ nhớ lệnh) — PHẢI NỐI TAY

Đây là bước **không tự động hoá được** vì `imem_addr`/`imem_rdata` không
theo chuẩn bus nào Vivado nhận diện.

1. Add IP **"Block Memory Generator"** vào canvas (bấm "+" như thêm IP
   khác, gõ tìm "Block Memory Generator").
2. Double-click vào IP vừa thêm để mở **Re-customize IP**, cấu hình:
   - **Basic tab**: Memory Type = **Single Port ROM** (nếu chương trình cố
     định, nạp sẵn lúc tạo bitstream) hoặc **Single Port RAM** (nếu muốn nạp
     lại được sau này qua 1 cổng khác/JTAG).
   - **Port A Options**: Port A Width = **32**, Port A Depth = tuỳ kích
     thước chương trình thực tế (ví dụ 1024 word = 4KB — đủ cho chương trình
     test hiện tại ~250 byte, nên đặt dư ra cho chương trình thật).
   - **QUAN TRỌNG — Output Register**: phải **BẬT** ("Primitives Output
     Register" / "Core Output Register" tuỳ bản Vivado) để có độ trễ đọc
     đúng **1 chu kỳ đồng bộ** — khớp với hành vi mà `fetch_stage.v` đang
     giả định (xem comment "BRAM 1-cycle latency" trong `CLAUDE.md`). Nếu
     tắt Output Register, core sẽ fetch sai lệnh do timing không khớp.
   - **Other Options tab**: nếu chọn ROM, nạp nội dung chương trình qua file
     `.coe` (memory init file) tại đây; nếu RAM, có thể để trống và nạp sau
     bằng cách khác.
3. Ở canvas, nối **thủ công bằng dây** (không phải AXI, kéo dây tay hoặc
   click 2 đầu cổng):
   - `rissp_core/imem_addr` → `blk_mem_gen_0/addra`
   - `blk_mem_gen_0/douta` → `rissp_core/imem_rdata`
   - `blk_mem_gen_0/clka` → cùng nguồn clock đang cấp cho `rissp_core/clk`
   - Nếu chọn Single Port RAM: `blk_mem_gen_0/ena` → tie cố định lên `1`
     (luôn enable đọc), `blk_mem_gen_0/wea` → tie `0` (không ghi, trừ khi có
     nhu cầu nạp lại chương trình lúc chạy thì nối `wea`/`dina` tới nguồn
     ghi tương ứng, ví dụ 1 AXI BRAM Controller port B nếu muốn PS nạp lại
     chương trình cho RISSP qua phần mềm).
   - Có thể tie hằng số bằng cách add IP **"Constant"** (giá trị 0 hoặc 1,
     độ rộng 1 bit) rồi nối dây, hoặc chuột phải cổng chưa nối → **"Make
     External"** nếu muốn đưa ra ngoài port top-level thay vì tie cứng.

## 7. Clock & Reset cho `rissp_core`

- **`clk`**: nối vào cùng clock domain với các IP khác trong hệ thống — nếu
  dùng Zynq PS, thường lấy từ `FCLK_CLK0` (đã tự nối nếu dùng Connection
  Automation ở Bước 5; nếu chưa, nối tay `zynq_ps/FCLK_CLK0` →
  `rissp_core/clk` và `blk_mem_gen_0/clka`). Nếu cần tần số khác, chèn thêm
  **Clocking Wizard**.
- **`rst_n`**: **ACTIVE-LOW**. Nếu hệ thống đã có **Processor System Reset**
  IP (tự thêm khi chạy Connection Automation ở Bước 5), lấy đúng ngõ ra
  **`peripheral_aresetn`** (đã active-low sẵn, đúng tên có hậu tố `n`) nối
  vào `rissp_core/rst_n`. **TUYỆT ĐỐI KHÔNG** dùng ngõ `peripheral_reset`
  (active-high, không có hậu tố `n`) nối thẳng vào `rst_n` — sẽ khiến core
  bị giữ ở trạng thái reset vĩnh viễn (hoặc chạy sai hoàn toàn nếu cực tính
  đảo ngược), vì register_file/fetch_stage/axi_rissp_master trong thiết kế
  đều dùng `if (!rst_n)` (reset khi mức thấp).

## 8. Validate, gán địa chỉ, generate

1. **Tools → Validate Design** (hoặc icon dấu tích ở thanh công cụ Block
   Design) — sửa hết cảnh báo/lỗi đỏ nếu có (thường là cổng chưa nối, clock
   chưa gán).
2. Mở tab **Address Editor** (cạnh tab Diagram trong Block Design) — vì
   `rissp_core` đóng vai trò AXI Master, cần **gán vùng địa chỉ** (address
   range) mà `M_AXI` được phép truy cập tới (ví dụ 1 vùng trong DDR, hoặc
   vùng BRAM Controller đã thêm ở Bước 5/6). Nếu không gán, RISSP sẽ không
   biết địa chỉ nào hợp lệ khi phát LOAD/STORE — Vivado thường tự gán mặc
   định hợp lý sau Connection Automation, nhưng nên kiểm tra lại thủ công ở
   đây, đặc biệt nếu chương trình chạy trên RISSP có địa chỉ dmem cố định
   (ví dụ chương trình test SW/LW dùng địa chỉ 0/4/8/12 như trong
   `tb_rissp_top.v` — cần đảm bảo vùng địa chỉ gán cho RISSP bao trùm dải
   này, hoặc RISSP dùng offset phù hợp với vùng thật đã gán).
3. Save Block Design (Ctrl+S).
4. Chuột phải file `.bd` trong Sources panel → **"Generate Block Design"**
   (hoặc **"Generate Output Products"**) → chọn Synthesis Options phù hợp
   (Global thường đủ) → Generate.
5. Chuột phải file `.bd` → **"Create HDL Wrapper..."** → chọn **"Let Vivado
   manage wrapper and auto-update"** (khuyến nghị, để wrapper tự cập nhật
   mỗi khi Block Design đổi) → OK.

## 9. Synthesis / Implementation / Bitstream

Từ đây làm như 1 project Vivado bình thường:
1. **Run Synthesis** → **Run Implementation** → **Generate Bitstream** (từ
   Flow Navigator, hoặc chuột phải wrapper → Generate Bitstream trực tiếp).
2. Sau khi Synthesis xong, **Report Utilization** sẽ hiện `rissp_core_0`
   (hay tên instance) như 1 khối trong hierarchy tổng — LUT của riêng khối
   này vẫn theo đúng số đã đo trong `CLAUDE.md` (~1018 LUT cho toàn bộ
   `rissp_top`, cộng thêm phần AXI Interconnect/BRAM/Processor System Reset
   do Vivado tự thêm khi tích hợp — những phần này KHÔNG tính vào con số
   1018 đã đo riêng cho lõi CPU).

## 10. Cập nhật IP sau khi sửa RTL thêm

Nếu sau này tiếp tục sửa/tối ưu RTL (ví dụ gộp thêm bitwise như đã bàn trong
`CLAUDE.md`), lặp lại phần đóng gói theo đúng bản RTL mới:

0. **Đồng bộ trước**: sửa file `.v` trong `F:\RISSP_cORE\RISSP_CORE\` (bản
   gốc sạch), rồi copy đè đúng các file đã đổi sang
   `D:\SE_RISSP_LIBRARY\RISSP_CORE_NEW\` (chỉ copy đè file `.v`, giữ nguyên
   `component.xml`/`xgui` đã có).
1. **Tools → Create and Package New IP…** → lần này chọn **"Edit"** thay vì
   tạo mới nếu Vivado hỏi (hoặc mở lại project tạm packaging cũ bằng
   `Tools → Package IP` nếu vẫn còn project đó).
2. Tab **File Groups** → bấm **"Merge changes from File Groups Wizard"** để
   Vivado quét lại thư mục nguồn, phát hiện file đã đổi.
3. Tab **Review and Package** → tăng **Version** (ví dụ `1.0` → `1.1`) để
   phân biệt bản cũ/mới → **"Re-Package IP"**.
4. Quay lại project SoC: trong Block Design, chuột phải khối `rissp_core` →
   **"Upgrade IP..."** (nếu Vivado tự phát hiện bản mới trong repository) —
   xác nhận để cập nhật instance sang bản RTL mới, giữ nguyên toàn bộ dây
   nối đã có trong Block Design.
5. Validate lại + Generate + build lại như Bước 8-9.
