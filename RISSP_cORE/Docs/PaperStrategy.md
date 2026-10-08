# Chiến lược paper: "An Application-Specific RISSP-Based SoC for Secure Edge
# Computing with Performance Evaluation against RISC-V"

Tài liệu tổng hợp từ khảo sát literature 2024-2026 (qua web search, không phải
suy đoán) để trả lời 3 câu hỏi: (1) tần số hoạt động nên nhắm bao nhiêu, (2)
ứng dụng cụ thể nào cho AES/SHA3/RSA khả thi để viết paper, (3) hướng đi nào
tạo tính mới và có cơ hội đậu ở conference/journal quốc tế. Tất cả nguồn được
dẫn link ở cuối mỗi mục.

---

## 1. Tần số hoạt động (frequency) nên nhắm tới bao nhiêu?

### Số liệu đã có trong tay (từ chính project này)
Sau khi sửa xong bug timing AES (xem `AES_CORE/AES.md`), SoC
`SE-RISSP_AES_ULTRA` đo thật trên `xc7z020clg484-1`:
- Ở constraint 40MHz (25ns): **WNS = +8.097ns** — dư khá nhiều.
- Ước tính Fmax ≈ 1/(25ns − 8.097ns) ≈ **~59MHz** (cần đo lại thật ở
  constraint 50MHz để xác nhận, xem hội thoại trước).

### Số liệu đối chiếu từ literature (SoC RISC-V + crypto cho IoT/edge, FPGA)
| Paper | Board/part | Tần số | Ghi chú |
|---|---|---:|---|
| Crypto-RV (2026) — co-processor hợp nhất SHA-256/512, SM3, SHA3-256, SHAKE-128/256, AES-128, Haraka | Xilinx **ZCU102** (Zynq UltraScale+, class cao hơn hẳn 7020) | **160MHz** | 0.851W, speedup 165-1061× so với RISC-V baseline |
| QUASAR — PQC (ML-KEM/ML-DSA/SLH-DSA) trên CV32E40P | **Zynq-7000** (cùng họ với xc7z020 đang dùng) | **110MHz** | chỉ +19% LUT overhead so với core trần |
| Lightweight crypto SoC (ASIC 130nm, không phải FPGA) | 130nm CMOS, 33k gate | **50MHz** | tham chiếu cho lớp thiết bị IoT low-cost |
| SHA-3 accelerator cho VPN/IoT gateway (Artix-7) | Artix-7 | **210MHz** | thiên về throughput accelerator đơn lẻ, không phải SoC đầy đủ |

**Nhận xét**: literature cho lớp **SoC RISC-V + crypto trên Zynq-7000/Artix-7
(cùng class FPGA với RISSP)** hội tụ quanh **50-160MHz**, trong đó bản thân
nhóm dùng **đúng họ chip Zynq-7000** (QUASAR) chọn **110MHz**. Các con số cao
hơn (160-210MHz) đều dùng **ZCU102 (UltraScale+, tốc độ cao hơn 7020 rất
nhiều)** hoặc chỉ đo 1 accelerator đơn lẻ, không phải cả SoC tích hợp CPU.

### Khuyến nghị
- **50MHz là điểm nhắm an toàn, có tiền lệ tốt** (khớp đúng con số 130nm ASIC
  IoT reference, và trong khoảng dưới của 50-160MHz cluster) — dùng làm
  **operating frequency chính thức để report trong paper** (đã đo được real
  WNS dương ở đây).
- Nên **thêm 1 dòng "Fmax ước tính ~59MHz"** như 1 số phụ (không phải số
  chính) để cho thấy còn margin, nhưng phải đo lại bằng constraint thật ở
  50MHz/~59MHz trước khi in vào paper — không dùng số ngoại suy làm số công
  bố chính thức (reviewer FPGA thường soi kỹ chỗ này).
- **Không cần đua lên 100MHz+**: mục tiêu paper là "edge computing" (ưu tiên
  công suất thấp, không phải throughput cao) — literature cùng class thiết
  bị (QUASAR, ASIC 130nm) đều dừng ở 50-110MHz, không có áp lực phải đua tần
  số với các paper dùng FPGA cao cấp hơn (ZCU102).
- **Quan trọng cho phần so sánh công bằng** (đúng tinh thần ghi chú trong
  `rissp_constr.xdc`): phải benchmark RISSP và baseline RV32I **ở CÙNG 1 tần
  số** (50MHz), không so LUT/power ở tần số khác nhau — đây là lỗi hay gặp
  nhất khiến reviewer reject phần so sánh.

**Nguồn**: [Crypto-RV (arXiv 2602.04415)](https://arxiv.org/abs/2602.04415) ·
[QUASAR (MDPI Electronics)](https://www.mdpi.com/2079-9292/15/10/2154) ·
[SHA-3 Accelerator Artix-7 (ResearchGate)](https://www.researchgate.net/publication/398074904_Design_of_an_Energy-Efficient_SHA-3_Accelerator_on_Artix-7_FPGA_for_Secure_Network_Applications) ·
[FPGA IoT gateway/power benchmark search set](https://www.mdpi.com/2673-4591/118/1/61)

---

## 2. Ứng dụng cụ thể cho từng loại crypto — cái nào khả thi, applicable cao

### AES — khả thi CAO, nên là trục chính của paper
**Ứng dụng cụ thể nên viết**: mã hoá payload TLS/DTLS giữa edge node và
cloud, mã hoá firmware/OTA update trước khi ghi flash, mã hoá dữ liệu
sensor/telemetry lúc lưu trữ (data-at-rest) hoặc lúc truyền (data-in-transit)
cho IoT gateway, endpoint VPN/IPsec nhẹ. 4 mode RISSP đã có (ECB/CBC/CTR/CFB)
— **CTR đặc biệt hợp** vì mô hình stream phù hợp telemetry real-time, tránh
được vấn đề padding của ECB/CBC.

**Vì sao khả thi**: đây là hướng **đông đảo nhất trong literature 2024-2026**
(AES-RV, AESware, Crypto-RV đều lấy AES làm trục) — nghĩa là có nhiều số để
so sánh (fair benchmark), nhưng cũng nghĩa là **cạnh tranh cao nhất, cần điểm
khác biệt rõ** (xem Mục 3).

### SHA3 — khả thi CAO, có 3 nhánh ứng dụng mạnh
1. **Secure boot / chain-of-trust**: hash firmware image để verify tính toàn
   vẹn trước khi CPU thực thi — ứng dụng trực tiếp, không cần thêm gì.
2. **Cầu nối sang Post-Quantum Cryptography (PQC)** — đây là điểm **rất đáng
   khai thác**: chuẩn NIST FIPS 203 (ML-KEM, tức Kyber) và FIPS 204 (ML-DSA,
   tức Dilithium) đều **dùng chính SHAKE/Keccak (họ SHA3) làm khối lõi bên
   trong**. Vì RISSP đã có 1 core SHA3 chạy thật, đo timing thật — có thể
   khẳng định "SHA3 core này là building block tái sử dụng được cho PQC
   tương lai" mà **không cần tự làm PQC đầy đủ** — chỉ cần 1 đoạn Future Work
   có dẫn chứng cụ thể (NIST FIPS 203/204) là đã bắt kịp xu hướng nóng nhất
   hiện tại (nhiều paper 2025-2026: QUASAR, NTT-ML-KEM accelerator, IDEMIA
   PQC hardware — xem Mục 3).
3. **Hash làm nguồn entropy/key-derivation cho các sơ đồ bảo mật khác**
   (không tự làm, chỉ trích dẫn làm literature support) — ví dụ
   [Arif *et al.*, "A Novel Chaotic Permutation-Substitution Image
   Encryption Scheme Based on Logistic Map and Random Substitution," IEEE
   Access, 2022](../PAPER/A_Novel_Chaotic_Permutation-Substitution_Image_Encryption_Scheme_Based_on_Logistic_Map_and_Random_Substitution.pdf)
   dùng **SHA-2 256** (không phải SHA-3 — 2 họ hoàn toàn khác nhau, **không
   tái dùng RTL được**) để hash ảnh gốc, sinh 4 khoá khởi tạo cho logistic
   map `μX(1-X)` điều khiển hoán vị hàng/cột + thay thế AES S-Box. **Không
   sao chép lại scheme này** (khác thuật toán hash, cần thêm khối logistic
   map + permutation chưa có trong project) — chỉ dùng làm dẫn chứng cho
   Related Work: "hash 1 ảnh/dữ liệu" là primitive nền tảng xuất hiện trong
   nhiều lớp ứng dụng bảo mật (integrity **và** key-derivation cho mã hoá),
   củng cố luận điểm 1 lõi SHA3 phần cứng có giá trị sử dụng rộng, không chỉ
   1 use-case hẹp.

### RSA — khả thi TRUNG BÌNH, cần framing đúng để tránh bị bẻ
**Cảnh báo quan trọng từ literature**: nhiều nghiên cứu fog/edge computing
chỉ ra **ECC hiệu quả hơn RSA rõ rệt cho thiết bị biên** — giảm ~50% năng
lượng, throughput gấp đôi RSA trong hầu hết kịch bản. RSA với key 2048/3072
bit cũng tốn LUT/thời gian đáng kể trên FPGA nhỏ. Nếu paper quảng bá RSA như
"giải pháp mã hoá throughput cao cho edge" thì **reviewer ở HOST/DATE rất dễ
bắt bẻ** vì đây là kiến thức phổ biến trong ngành.

**Cách framing đúng để RSA vẫn có giá trị trong paper**:
- Định vị RSA cho **chữ ký số/verify trong secure boot** (thao tác không
  thường xuyên, không cần throughput cao — điểm yếu tốc độ của RSA không
  quan trọng ở use-case này).
- Định vị cho **tương thích PKI/TLS hiện hữu** (nhiều hệ thống enterprise
  vẫn bắt buộc hỗ trợ RSA certificate dù đã có ECDHE cho key exchange).
- Nên có 1 câu rõ ràng trong Limitations/Future Work: "RSA được chọn vì
  tương thích hạ tầng PKI hiện có; ECC/PQC signature (ML-DSA) là hướng mở
  rộng tương lai cho throughput cao hơn" — chủ động nêu trước để reviewer
  không cần hỏi.

**CẬP NHẬT 2026-08-07 — tin tốt, đã sửa 1 nhầm lẫn audit trước đó**: phát
hiện `RSA_Core/RSA_core.v` cũ trong repo audit **nhầm core** — module thật
được AXI wrapper gọi (`rsa`, Montgomery, base `0x48000000`) nhận `M,E,N`
**trực tiếp từ bên ngoài**, không tự suy `e` từ `p,q` như bản đã audit nhầm
trước đó. Đã viết testbench mới verify lại, **PASS cả với `e=65537` chuẩn
công nghiệp thật**. Nghĩa là:
- **Không cần sửa RTL gì để làm demo "verify chữ ký số"** — kế hoạch sửa
  RTL thêm bypass mode đã bàn trước đây (khi tưởng RSA cần `p,q`) **không
  còn cần thiết**, core đã đúng mô hình verify chuẩn sẵn.
- Ứng dụng "RSA verify chữ ký firmware trong secure boot/OTA" giờ **khả thi
  CAO** (không còn "trung bình" như đánh giá trước) — chỉ còn giới hạn về
  quy mô khoá (`WIDTH=32`, không production-grade), không còn giới hạn về
  mô hình hoạt động. Chi tiết đầy đủ xem `RSA_Core/RSA.md`.

**Nguồn**: [Fog computing ECC vs RSA (PMC)](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5620735/) ·
[Crypto-RV — bộ thuật toán được coi là "đầy đủ" gồm SHA-256/512, SM3, SHA3,
SHAKE, AES, Haraka (không có RSA)](https://arxiv.org/abs/2602.04415) ·
[NIST FIPS 203/204 tổng quan PQC](https://arxiv.org/pdf/2510.10436)

---

## 3. Hướng đi để có tính mới và đậu conference quốc tế

### 3.1 Bối cảnh cạnh tranh — RẤT sát, cần đọc kỹ để tránh trùng lặp

| Paper | Năm | Cách tiếp cận |
|---|---|---|
| [AES-RV](https://arxiv.org/pdf/2505.11880) | 2025 | Custom **instruction extension** AES trên core RISC-V có sẵn |
| [AESware](https://www.sciencedirect.com/science/article/pii/S2215098624002805) | 2024 | AES accelerator dùng chung cho **multicore** RISC-V |
| [Crypto-RV](https://arxiv.org/abs/2602.04415) | 2026 | Co-processor hợp nhất **8 thuật toán hash/cipher** (không RSA), datapath 64-bit |
| [SAILOR](https://arxiv.org/pdf/2602.24166) | 2026 | RISC-V siêu nhẹ cho IoT security |
| [QUASAR](https://www.mdpi.com/2079-9292/15/10/2154) | 2025 | PQC (ML-KEM/ML-DSA/SLH-DSA) trên **CV32E40P**, tối thiểu hoá LUT overhead |
| [CryptRISC](https://arxiv.org/pdf/2602.20285) | 2026 | RISC-V bảo mật, **có chống side-channel (power)** |
| [ITUS](https://www.researchgate.net/publication/341244240_ITUS_A_Secure_RISC-V_System-on-Chip), [DITES](https://pmc.ncbi.nlm.nih.gov/articles/PMC9416496/) | 2020-2022 | TEE SoC, RSA+AES+SHA1 qua bus, secure boot Chain-of-Trust |
| [TEE SoC tương thích TLS 1.3](https://www.mdpi.com/2079-9292/13/13/2508) | 2024 | HMAC-SHA2, Ed/EdDSA, RSA, AEAD |
| ["SoC 32-bit RISC-V + lightweight crypto cores"](https://doi.org/10.3390/fi15050186) (MDPI Future Internet) | — | **Gần như trùng tên đề tài với paper của bạn** — cần đọc kỹ để né trùng |

**Điểm chung của TẤT CẢ các paper trên**: họ lấy 1 core RISC-V **có sẵn,
kiến trúc thông thường** (CV32E40P, Rocket, PicoRV32-class — ALU dùng chung
thông thường) rồi **gắn thêm** crypto qua (a) mở rộng tập lệnh (custom ISA
extension) hoặc (b) coprocessor gắn bus. **Không ai động vào vi kiến trúc lõi
CPU** — đây chính là khoảng trống RISSP có thể lấp.

### 3.2 Trục khác biệt thật sự của RISSP (đã có sẵn, chỉ cần nhấn mạnh đúng)

RISSP không phải "core thường + gắn thêm crypto" — kiến trúc **modular
execution** (mỗi loại lệnh R/I/B/J/U/S có khối phần cứng riêng chạy song
song, chọn qua mux theo opcode, xem `CLAUDE.md`) là thay đổi ở **chính vi
kiến trúc datapath CPU**, không phải lớp accelerator gắn ngoài. Kết hợp với
việc tích hợp **3 thuật toán (AES+SHA3+RSA) qua AXI4-Lite** thay vì mở rộng
tập lệnh, đây là **2 điểm khác biệt thật, có thể định lượng**, khác hẳn
pattern "core có sẵn + ISA extension cho 1 họ thuật toán" đang chiếm gần hết
literature hiện tại.

**Khuyến nghị hành động cụ thể**:
1. **Đo baseline "shared-ALU" thật để so sánh công bằng** — tiêu đề paper
   hứa "Performance Evaluation against RISC-V" nên **bắt buộc phải có** 1
   core RV32I single-cycle thông thường (ALU dùng chung hoàn toàn cho mọi
   loại lệnh, KHÔNG modular) đo ở **cùng part, cùng 50MHz** làm đối chứng —
   hiện `CLAUDE.md` chỉ có số RISSP (1018 LUT), chưa thấy số baseline shared-
   ALU thật để đối chiếu. Đây là con số quan trọng nhất bài báo cần có, dễ
   làm (chỉ cần build 1 bản "gộp hết" từ chính RTL đang có).
2. Nhấn rõ trong Related Work: toàn bộ bảng ở Mục 3.1 đều là "core có sẵn +
   extension", RISSP là "co-design vi kiến trúc lõi + crypto subsystem" —
   đây là câu differentiation trực tiếp, dễ viết, có dẫn chứng rõ.

### 3.3 3 hướng bổ sung để tăng tính mới (xếp theo độ ưu tiên/độ khó)

**(A) Cầu nối PQC qua SHA3 (dễ làm, giá trị cao)** — thêm 1 đoạn
Discussion/Future Work nêu rõ SHA3/SHAKE trong RISSP tái dùng được cho
ML-KEM/ML-DSA (FIPS 203/204), trích literature PQC-on-RISC-V đang rất nóng
(QUASAR, NTT-ML-KEM accelerator, IDEMIA công bố hardware PQC 03/2025). Không
cần code thêm gì, chỉ cần 1 đoạn phân tích có trích dẫn — chi phí thấp, tín
hiệu bắt kịp xu hướng cao.

**(B) Side-channel — nêu rõ là giới hạn đã biết, không né tránh (trung
bình khó)** — `CryptRISC` (2026) cho thấy **giới học thuật đang chuyển sang
đòi hỏi chống side-channel** cho RISC-V secure SoC. RISSP hiện chưa có
countermeasure nào (không bắt buộc phải làm ngay), nhưng paper nên có 1 câu
chủ động thừa nhận: "threat model hiện tại giả định không có physical/power
side-channel access; countermeasure (masking AES, constant-time RSA) là
hướng mở rộng" — tránh để reviewer tự phát hiện và dùng làm lý do reject.

**(C) Demo ứng dụng end-to-end (khó hơn, giá trị cao nhất nếu kịp thời
gian)** — hầu hết paper đối thủ chỉ báo cáo **microbenchmark từng thuật
toán** (cycles, LUT, power), không có demo hệ thống hoàn chỉnh. RISSP có sẵn
cả AES+SHA3+RSA — có thể dựng 1 kịch bản **"secure OTA firmware update"**
thật: RSA verify chữ ký firmware → SHA3 hash kiểm tra toàn vẹn → AES giải mã
payload → ghi vào bộ nhớ chương trình. Đây là **use-case điển hình secure
edge computing**, biến paper từ "bảng benchmark component" thành "system-
level contribution" — nhiều venue ứng dụng (MDPI Future Internet/Electronics,
IEEE IoT Journal, DATE Application track) đánh giá cao hướng này hơn hẳn.

### 3.4 Venue khuyến nghị (xếp theo độ khả thi thực tế)

**Nhóm an toàn, phù hợp maturity hiện tại** (RTL đã chạy thật, đo timing
Vivado thật, chưa có side-channel countermeasure, phù hợp bài báo dạng
system/application):
- **MDPI *Electronics*** hoặc ***Future Internet*** hoặc ***Cryptography***
  — đã tìm thấy **nhiều paper gần như trùng đề tài** được đăng ở đây (SoC
  32-bit RISC-V + lightweight crypto cores; Low-Power IoT RISC-V + Hybrid
  Encryption Accelerator) — open access, review nhanh, đúng niche.

**Nhóm tầm trung, đáng thử** (cần nhấn mạnh rõ điểm 3.2/3.3):
- **IEEE ISVLSI 2026** — CFP nêu rõ chủ đề *hardware security, cryptography,
  PUF circuits, IoT* — khớp trực tiếp.
- **IEEE ICECS** — đã có tiền lệ đúng dạng đề tài ("RISC-V Cores with
  AES-256 Accelerators", ICECS 2024) được chấp nhận.

**Nhóm cao hơn, cần đầu tư thêm (ít nhất làm (A) và (B) ở Mục 3.3)**:
- **DATE** — có tiền lệ TYRCA (RISC-V accelerator cho code-based crypto,
  DATE 2025) đúng dạng "accelerator tích hợp vào RISC-V".
- **IEEE HOST 2026** (Washington DC, 4-7/5/2026) — CFP rất rộng ("mọi giao
  điểm hardware-security") nhưng cộng đồng review chuyên sâu bảo mật, gần
  như chắc chắn sẽ hỏi về threat model/side-channel — chỉ nên nộp nếu đã làm
  ít nhất mục (B).
- **ISCAS 2026** (Thượng Hải) — có track "Intelligent Cyber Security
  Systems" khớp chủ đề.

**Khuyến nghị lộ trình**: nộp bản đầu ở nhóm MDPI/ISVLSI/ICECS trước (rủi ro
thấp, đúng niche, có tiền lệ rõ) — nếu còn thời gian và làm thêm được ít
nhất hướng (A) hoặc (C) ở Mục 3.3, mới nhắm DATE/HOST/ISCAS cho bản mở rộng.

**Nguồn**: [HOST 2026 CFP](https://host.conferences.computer.org/2026/call-for-papers/) ·
[ISCAS 2026 CFP](https://2026.ieee-iscas.org/cfp/call_for_papers.html) ·
[ISVLSI 2026 CFP](https://ieee-isvlsi.github.io/ISVLSI_2026_Website/call-for-papers/index.html) ·
[MDPI Future Internet — SoC RISC-V + lightweight crypto](https://doi.org/10.3390/fi15050186) ·
[MDPI Electronics — Low-Power IoT RISC-V Hybrid Encryption](https://www.mdpi.com/2079-9292/12/20/4222) ·
[MDPI Cryptography journal scope](https://www.mdpi.com/journal/cryptography)

---

## 4. Baseline core so sánh — đã chốt scope (2026-08-07)

### Vì sao không so trực tiếp RISSP với RocketChip/CVA6 như 2 core "ngang hàng"
RISSP là single-cycle, không pipeline, không cache, không MMU — đúng nghĩa
**microcontroller-class**. RocketChip (5 tầng pipeline) và CVA6 (6 tầng,
**boot được Linux**, có MMU/cache) là **application-class** — khác hẳn lớp
thiết kế. So LUT/tần số trực tiếp coi như ngang hàng sẽ bị reviewer
HOST/DATE/ISCAS bắt bẻ ngay vì đây là kiến thức phổ biến trong ngành.

### Số liệu baseline cùng lớp đã tìm được (dùng làm đối chứng)
| Core | Part đo | LUT | FF | Tần số | Nguồn |
|---|---|---:|---:|---:|---|
| **Ibex** (2-stage, small config) | **XC7Z020 — đúng part RISSP đang dùng** | 3.161 | 1.933 | ~50MHz | [lowRISC Ibex update](https://lowrisc.org/news/an-update-on-ibex-our-microcontroller-class-cpu-core/) |
| **PicoRV32** | XC7A35T (cùng họ fabric Artix-7 với PL của XC7Z020) | 1.765 | 1.075 | — | [PicoRV32 GitHub](https://github.com/YosysHQ/picorv32) |
| CV32E40P (RI5CY) | 65nm ASIC (không phải FPGA, chỉ tham khảo) | ~9.072 (tương đương gate) | — | — | khảo sát trước |

### Quyết định scope (người dùng chọn — mức "Vừa")
1. **Ibex** — tích hợp THẬT hệ AXI4-Lite crypto subsystem (AES+SHA3+RSA)
   giống hệt RISSP đang có. Ibex dùng bus request/grant riêng (không AXI
   native) → cần viết **1 bridge request/grant ↔ AXI4-Lite master** (tham
   khảo cách lowRISC làm trong hệ sinh thái OpenTitan/Ibex demo system).
2. **CVA6** — tích hợp THẬT, dễ hơn Ibex vì **có sẵn AXI master interface**
   ngay từ thiết kế gốc ([openhwgroup/cva6](https://github.com/openhwgroup/cva6))
   — cắm thẳng vào cùng peripheral AXI4-Lite (AES/SHA3/RSA) hiện có, không
   cần bridge riêng.
3. **RocketChip** — **không tự tích hợp**, chỉ trích số liệu LUT/tần số từ
   chính paper/tài liệu gốc của RocketChip (dùng TileLink nội bộ, cần
   TileLink→AXI4 bridge — công sức lớn nhất trong 3 core, không đáng đánh
   đổi trong scope "Vừa" đã chọn). Đưa vào bảng "landscape" phụ, ghi rõ nhãn
   "application-class, số liệu trích dẫn — không tự đo trong nghiên cứu
   này" để minh bạch với reviewer.

### Cấu trúc bảng kết quả nên có trong paper
- **Bảng chính (controlled experiment)**: RISSP vs Ibex vs CVA6, CÙNG 1 hệ
  crypto subsystem AXI4-Lite, CÙNG part `xc7z020clg484-1`, CÙNG tần số
  50MHz — cột LUT/FF/power/WNS. Đây là bảng trả lời trực tiếp "Performance
  Evaluation against RISC-V" trong tiêu đề.
- **Bảng landscape (phụ, trích dẫn)**: thêm PicoRV32, CV32E40P, RocketChip —
  ghi rõ cột "Source" (tự đo / trích literature) và cột "Design class"
  (microcontroller-class / application-class) để không bị hiểu nhầm là so
  sánh công bằng.

### Việc cần làm tiếp (theo thứ tự ưu tiên)
1. Build baseline "shared-ALU RISSP-twin" (đã khuyến nghị ở Mục 3.2) — làm
   trước vì dùng lại 100% RTL đang có, nhanh nhất.
2. Tích hợp CVA6 (dễ hơn Ibex vì AXI native) — làm trước Ibex để có kết quả
   sớm.
3. Viết bridge request/grant→AXI4-Lite cho Ibex, tích hợp.
4. Đóng timing 50MHz cho cả 2 SoC mới (Ibex-crypto, CVA6-crypto) bằng đúng
   quy trình đã dùng cho RISSP (`report_timing_summary` sau `opt_design`).
5. Gom số RocketChip từ literature vào bảng landscape.

## Tóm tắt hành động đề xuất
1. **Tần số**: report chính thức **50MHz** (đã đo WNS dương thật), ghi thêm
   Fmax ước tính sau khi đo lại bằng constraint thật.
2. **Ứng dụng**: AES → TLS/OTA/telemetry (trục chính); SHA3 → secure boot +
   nêu rõ cầu nối PQC (FIPS 203/204); RSA → định vị lại thành "chữ ký/secure
   boot/tương thích PKI", không quảng bá là giải pháp throughput cao.
3. **Tính mới**: nhấn mạnh RISSP là **co-design vi kiến trúc lõi (modular
   execution) + crypto subsystem AXI**, khác hẳn pattern "core có sẵn + ISA
   extension" đang chiếm literature — và **bắt buộc đo thêm baseline** để
   tiêu đề "Performance Evaluation against RISC-V" có số liệu đối chứng cụ
   thể: (a) shared-ALU RISSP-twin (tự build), (b) Ibex + CVA6 tích hợp thật
   cùng crypto subsystem (đã chốt scope, xem Mục 4), (c) RocketChip/PicoRV32/
   CV32E40P chỉ trích literature vào bảng landscape phụ.
4. **Venue**: bắt đầu từ MDPI Electronics/Future Internet/Cryptography hoặc
   ISVLSI/ICECS (rủi ro thấp, đúng niche); DATE/HOST/ISCAS là mục tiêu vươn
   tới sau khi bổ sung hướng PQC-bridge hoặc side-channel discussion.
