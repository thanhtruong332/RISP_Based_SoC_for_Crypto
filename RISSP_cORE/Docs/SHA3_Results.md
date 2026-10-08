# SHA3-256 — kết quả đo theo độ dài message (SoC `SE-RISSP_AES_ULTRA`)

**Trạng thái: ✅ HOÀN TẤT 3/3 điểm, PASS hết** (2026-08-12)

**Cấu hình**: 40 MHz (`T = 25 ns/ck`) · **`P = 0.365 W`** (đo lại 2026-08-12,
thay cho 0.293 W cũ) · **`E_ck = 9.125 nJ/ck`**
**Lõi**: SHA3-256, rate 1088 bit, capacity 512 bit — không đổi giữa các lần chạy.
**Chọn độ dài**: `message = N × 136 − 8` byte → message + 1 từ padding = đúng
N rate block, không có block lẻ làm nhiễu.

> ⚠️ Các testbench in ra Energy theo `P = 0.293 W` (giá trị cũ). Mọi số nJ và
> Mbps/W dưới đây **đã tính lại** theo 0.365 W. `gen_all.py` đã sửa, lần chạy
> sau sẽ in đúng.

---

## Bảng A — Mốc chu kỳ thô

| Bản | N | Msg (B) | Từ | absorb1 | iLast | oReady | DIGEST | BRAM | absorb_cnt | PASS |
|---|---:|---:|---:|---:|---:|---:|---:|---:|:--:|:--:|
| `sha3` | 1 | 128 | 16 | 86 | 531 | 559 | 637 | 702 | — | ✅ |
| `sha3_4` | 4 | 536 | 67 | 88 | 1965 | 1993 | 2071 | 2136 | 67/67 ✅ | ✅ |
| `sha3_16` | 16 | 2168 | 271 | 88 | 7677 | 7705 | 7783 | 7848 | 271/271 ✅ | ✅ |

**Ba chi phí cố định — bất biến qua cả 3 lần chạy** (bằng chứng độc lập cho
mô hình):

| Giai đoạn | N=1 | N=4 | N=16 |
|---|---:|---:|---:|
| Permutation cuối (`iLast→oReady`) | 28 | 28 | 28 |
| Đọc 8 từ digest (`oReady→DIGEST`) | **78** | **78** | **78** |
| Ghi BRAM (`DIGEST→BRAM`) | **65** | **65** | **65** |

## Bảng B — Hiệu năng (cơ sở PURE)

| Bản | N | Msg (B) | PURE (ck) | Throughput | Energy/hash | nJ/bit | Mbps/W | Utilization |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| `sha3` | 1 | 128 | 551 | **74.34 Mbps** | 5 027.9 nJ | 4.9100 | 203.66 | 4.90 % |
| `sha3_4` | 4 | 536 | 1 983 | **86.50 Mbps** | 18 094.9 nJ | 4.2199 | 236.97 | 5.45 % |
| `sha3_16` | 16 | 2 168 | 7 695 | **90.16 Mbps** | 70 216.9 nJ | 4.0485 | 247.01 | 5.61 % |
| *tiệm cận* | ∞ | — | — | *91.36 Mbps* | — | — | *250.3* | *5.67 %* |

Hằng số lõi (không đổi theo N): **permutation 27 ck · peak 1611.85 Mbps ·
rate 1088 bit**.

## Bảng C — Xác minh

| Bản | Digest (4 từ đầu) | XOR-fold | Kết quả |
|---|---|---|:--:|
| `sha3` | `d1985c30 73f0ff34 c1717893 0e28f04e` | `25836f4b` | ✅ |
| `sha3_4` | `7df3d9cd 8212808e b2a3ac20 38893a49` | `efe1162a` | ✅ |
| `sha3_16` | `c14e1d9a 4b135dc8 b88f8272 0d4088bb` | `92089715` | ✅ |

Thêm (`tb_sha3_multiblock.v`, đã PASS): 137 B (từ lẻ) · 272 B (đúng ranh giới
block, buộc sinh block padding thứ 3) · 300 B (3 block + từ lẻ).

---

## 📌 MÔ HÌNH ĐÃ XÁC LẬP

$$\text{PURE}(N) = 76 + 28.02 \times W + 27 \qquad (W = 17N - 1 \text{ từ})$$

| N | Dự đoán | Đo được | Sai lệch |
|---:|---:|---:|---:|
| 1 | 551.0 | 551 | 0.00 % |
| 4 | 1 980.0 | 1 983 | +0.15 % |
| 16 | 7 696.1 | 7 695 | −0.01 % |

Ba ước lượng độc lập của `b` từ ba cặp điểm: **28.078 · 28.016 · 28.000** —
khớp nhau trong 0.3 %. Tuyến tính gần như hoàn hảo.

Diễn giải hai tham số:
- `b = 28.0 ck/từ 64-bit` = chi phí nạp qua AXI (3 giao dịch 32-bit × ~8 ck
  + ~4 ck lệnh CPU của vòng lặp)
- `a = 76 ck` ≈ đúng **78 ck đọc digest** đo được ⇒ chi phí khởi động thực
  chất bằng 0

### Kết luận: 15/16 permutation bị che hoàn toàn

Giả thuyết cạnh tranh, kiểm bằng `PURE₁₆ − PURE₁ = 7144 ck` (255 từ, 15 block):

| Giả thuyết | Dự đoán | Sai lệch so với 7144 |
|---|---:|---:|
| **Permutation bị che** (chỉ tốn feed) | 255 × 28.0 = **7 140** | **+4 ck** ✅ |
| Permutation tính đủ (+27/block) | 7 140 + 405 = 7 545 | −401 ck ❌ |

Nạp một block mất ~476 ck còn permutation chỉ 27 ck ⇒ permutation **luôn
xong trước khi CPU nạp đủ block kế tiếp**. Chỉ permutation cuối cùng lộ ra.

---

## Câu cho paper (đã có số)

> Tăng dữ liệu **16 lần** (128 → 2 168 byte) chỉ cải thiện throughput
> **+21.3 %** (74.34 → 90.16 Mbps), và bão hoà ở **91.36 Mbps** — đạt 98.7 %
> trần ngay tại N=16. Utilization của lõi gần như không đổi (**4.9 % →
> 5.6 %**, trần 5.67 %). Nút thắt là **chi phí nạp mỗi từ 64-bit (28.0 ck)**,
> không phải overhead khởi động (≈0) cũng không phải thời gian tính toán
> (15/16 lần permutation bị che hoàn toàn).

Suy ra trực tiếp: **tăng tốc lõi Keccak không cải thiện hệ thống chút nào** —
nó đã nhanh hơn đường nạp dữ liệu tới mức tàng hình. Chỉ đổi giao diện
(burst/DMA/đường 64-bit) mới có tác dụng.

---

## Không đưa vào bảng chính

- Message 128-**bit** (permutation 42 ck / 121.90 Mbps) — nhiễu padding, chỉ
  dùng làm ví dụ trong phần methodology.
- Cột END-TO-END — phụ lục, vì gồm cả ghi BRAM debug (hạ tầng test).
- Lena 512×512 — SoC 2 lõi khác + mô hình AXI hành vi, **ngoài scope**.
