# RSA word-serial Montgomery — bản viết lại, hỗ trợ RSA-2048

Thay cho `RSA_Core/RSA_core.v` (32-bit, nhân tổ hợp toàn dải). Bản cũ **không
mở rộng được**: chi phí bộ nhân tăng theo bình phương độ rộng → 2048-bit cần
~45 000 DSP. Bản này dùng **đúng một bộ MAC 32×32 lặp lại** (thuật toán CIOS),
nên số bộ nhân **không đổi** theo độ rộng toán hạng.

## File

| File | Nội dung |
|---|---|
| `rsa_modexp_ws.v` | Lõi. Tham số `S` = số từ 32-bit (64 → 2048 bit), `CONST_TIME` |
| `tb_rsa_2048_ct1.v` | Testbench tự kiểm, đối chiếu `pow(M,65537,N)` của Python |
| `rsa2048_*.mem` | Vector: `N`, `M` (chữ ký), `R2`, `C` (kết quả kỳ vọng) |
| `synth_rsa.tcl` | Synth OOC lấy số tài nguyên/timing |

`n0inv = 0xcbbb0d9f` cho vector 2048-bit (truyền qua cổng, không nằm trong `.mem`).

## Đã verify bằng mô phỏng thật (Vivado xsim)

| Độ rộng | S | `CONST_TIME=1` | `CONST_TIME=0` | Kết quả |
|---:|---:|---:|---:|:--:|
| 128-bit | 4 | 2 349 ck | 1 404 ck | ✅ PASS |
| 256-bit | 8 | 6 937 ck | 4 132 ck | ✅ PASS |
| **2048-bit** | **64** | **319 809 ck** | **190 164 ck** | ✅ **PASS** |

Tất cả đối chiếu với `pow(M, 65537, N)` tính bằng Python, khớp từng từ 32-bit.

### Kênh kề thời gian — đã bịt

Cùng modulus, hai số mũ **cùng 17 bit** nhưng khác số bit 1:

| Số mũ | popcount | `CONST_TIME=1` | `CONST_TIME=0` |
|---|---:|---:|---:|
| `65537` | 2 | **2 349** | 1 404 |
| `0x1FFFF` | 17 | **2 349** | 2 349 |

`CONST_TIME=1` bất biến; bản không constant-time lệch **67 %** theo số bit 1
của số mũ — chính là lỗ hổng của `RSA_core.v` cũ ([dòng 94](../RSA_core.v#L94),
nhánh `if (E[bit_idx])`).

Với **verify bằng khoá công khai** thì `E` ai cũng biết nên `CONST_TIME=0` vẫn
an toàn và nhanh gần gấp đôi. Với thao tác dùng **khoá bí mật** thì bắt buộc
`CONST_TIME=1`.

## Tài nguyên — synth OOC, xc7z020, chu kỳ 25 ns (S=64, CONST_TIME=1)

| | Giá trị | Tỉ lệ |
|---|---:|---:|
| Slice LUT | **3 571** | 6.71 % |
| Slice Register | 4 314 | 4.05 % |
| Block RAM | **0** | 0 % |
| **DSP** | **4** | 1.82 % |
| **WNS @40 MHz** | **+11.650 ns** | fmax ≈ **75 MHz** |

**Bản 2048-bit dùng ÍT DSP hơn bản 32-bit cũ** (4 vs ~11) — vì tái sử dụng một
bộ nhân thay vì ba bộ nhân tổ hợp song song. Và fmax cao hơn trần hiện tại của
SoC (59 MHz), nên không trở thành đường tới hạn mới.

## Hiệu năng dự kiến trong SoC

| | @40 MHz | @55 MHz |
|---|---:|---:|
| `CONST_TIME=1` | 8.00 ms/verify | 5.81 ms |
| `CONST_TIME=0` | 4.75 ms/verify | 3.46 ms |

Chi phí giao diện: mỗi verify cần nạp `M` (64 từ) + đọc kết quả (64 từ) = 128
giao dịch AXI ≈ 1 150 ck. So với 319 809 ck tính toán → **hiệu suất ~99.6 %**,
tỉ lệ giao dịch/chu-kỳ-tính = **0.0004**.

Điểm neo "compute-bound" dịch xa thêm ~50 lần so với bản 32-bit:

| Lõi | Giao dịch AXI / ck tính | Hiệu suất |
|---|---:|---:|
| **RSA-2048 (bản này)** | **0.0004** | **~99.6 %** |
| RSA-32 (bản cũ) | 0.02 | 85.7 % |
| AES-128 | 0.81 | 16.3 % |
| SHA3-256 | 1.90 | 5.6 % |

Dải trải rộng **4 750 lần** — quan hệ nghịch giữa mật độ giao dịch và hiệu suất
trở nên rất khó bác bỏ.

## Chi phí chu kỳ

Mỗi phép nhân Montgomery ≈ `2S² + 6S + 8` chu kỳ. Số phép nhân cho một luỹ thừa:

- `CONST_TIME=1`: `2·e_bits + 3` (e=65537 → 37)
- `CONST_TIME=0`: `e_bits + popcount(e) + 3` (e=65537 → 22)

Kiểm: S=64, CT=1 → `37 × (8192+384+8) = 317 828` ≈ đo được **319 809** (lệch 0.6 %).

## Việc còn lại để đưa vào SoC

1. Viết AXI4-Lite wrapper: `M`/`N`/`R2` nạp theo từng từ qua `wr_sel`/`wr_addr`,
   `n0inv`/`e`/`e_bits` là thanh ghi đơn, kết quả đọc qua `rd_addr`.
2. Đóng gói IP, thay `RSA_mark03_0` trong Block Design.
3. Sinh lại firmware: nạp 64 từ thay vì 1 từ (vòng lặp, không unroll).
4. Chạy lại Implementation lấy LUT/power/WNS mới cho cả SoC.

AES, SHA3 và RISSP **không bị ảnh hưởng** — số liệu của ba lõi đó giữ nguyên.
