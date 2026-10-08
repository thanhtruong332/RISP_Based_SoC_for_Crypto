# RSA_Core — Kiểm tra & xác nhận

Lõi RSA phần cứng — **Montgomery modular exponentiation**, gắn vào SoC qua
AXI4-Lite ở base `0x48000000` (`RSA_mark03_0`, xem
`F:\advance_topic\RSA_mark03\RSA_mark03_1_0\hdl\`).

## SỬA LẠI QUAN TRỌNG (2026-08-07): audit trước đây kiểm tra NHẦM core

Bản `RSA_core.v` cũ trong thư mục này (module `control`/`inverter`/`mod_exp`,
tự dò `e` bằng extended-Euclid từ `p,q`) — tuy đã audit kỹ và PASS testbench
— **không phải core thật được AXI wrapper gọi**. Đọc kỹ
`RSA_mark03_slave_lite_v1_0_S00_AXI.v` (file wrapper thật) thì thấy nó
instantiate:
```verilog
rsa #(.WIDTH(32), .E_BITS(32)) u_rsa (
    .clk(...), .rst(...), .start(...),
    .M(r_m), .E(r_e), .N(r_n), .N_INV(r_ninv), .R2_MOD_N(r_r2),
    .C(core_c), .done(core_done)
);
```
— một module `rsa` (Montgomery) hoàn toàn khác, nằm trong 1 file **trùng tên**
`RSA_core.v` nhưng ở đường dẫn khác
(`F:\advance_topic\RSA_mark03\RSA_mark03_1_0\src\RSA_core.v`) — 2 file cùng
tên, khác nội dung hoàn toàn, dễ nhầm nếu không đọc kỹ đường dẫn.

**Đã sửa**: nội dung `RSA_Core/RSA_core.v` trong thư mục này bây giờ là
đúng bản Montgomery thật (copy từ `RSA_mark03_1_0/src/`), viết testbench mới
verify lại từ đầu — xem kết quả bên dưới. Tài liệu này viết lại hoàn toàn
theo đúng core thật, không còn tham chiếu bản `control`/Euclid cũ.

## Vì sao đây là tin tốt cho paper

Core Montgomery này **nhận `M, E, N` trực tiếp từ bên ngoài** (không tự suy
`e` từ `p,q` như bản cũ) — đúng mô hình **RSA verify chuẩn công nghiệp**:
thiết bị biên chỉ cần biết **public key `(N,E)`**, không bao giờ cần biết
`p,q` (giữ đúng thuộc tính bảo mật RSA — biết `p,q` thì tính được cả khoá bí
mật `d`). `N_INV` (`= -N⁻¹ mod 2³²`) và `R2_MOD_N` (`= 2⁶⁴ mod N`) là 2 tham
số Montgomery chuẩn, tính offline bằng Python lúc build/release rồi nạp vào
như hằng số — đúng quy ước đã ghi sẵn trong comment gốc của AXI wrapper.

→ **Không cần sửa RTL gì thêm** để làm demo "verify chữ ký số" cho paper —
core đã làm đúng việc này sẵn.

## Cấu trúc file

- `RSA_core.v` — chứa 3 module: `montgomery_reduce` (1 bước rút gọn Montgomery
  REDC, 2 chu kỳ: tính `m` rồi tính `t=(T+m·N)>>32` + trừ có điều kiện),
  `montgomery_mul` (nhân Montgomery = REDC(A·B)), `rsa` (bình phương-và-nhân
  8-trạng-thái dùng `montgomery_mul` làm khối tính lặp lại, xử lý đúng 32 bit
  số mũ `E` mỗi lần, kể cả bit 0 ở đầu).

## Register map (AXI, base `0x48000000`)

| Offset | R/W | Thanh ghi | Ghi chú |
|---|---|---|---|
| `0x00` | W | `M` | Bản tin đầu vào (với verify chữ ký: đây là **chữ ký**) |
| `0x04` | W | `E` | Số mũ công khai (VD `65537` chuẩn công nghiệp) |
| `0x08` | W | `N` | Modulus (`p·q`) |
| `0x0C` | W | `N_INV` | `-N⁻¹ mod 2³²`, tính offline |
| `0x10` | W | `R2_MOD_N` | `2⁶⁴ mod N`, tính offline |
| `0x14` | W | `CTRL` | bit0 = start (xung 1 chu kỳ) |
| `0x18` | R | `STATUS` | bit0 = done |
| `0x1C` | R | `RESULT` | `C = M^E mod N` |

## Kết quả mô phỏng — verify lại từ đầu (không tin comment cũ, tự đo)

Viết testbench mới `tb_rsa_montgomery.v` (không có sẵn trong project cũ —
`tb_rsa.v` cũ chỉ test bản `control`/Euclid, không liên quan module `rsa`
này), đối chiếu `pow(msg, e, n)` tính bằng Python cho 4 case, gồm cả case
dùng **`e=65537` — số mũ công khai chuẩn công nghiệp thật** (không phải số
tự sinh như bản cũ):

```
"F:\vivado\Vivado\2024.2\bin\xvlog.bat" RSA_core.v tb_rsa_montgomery.v
"F:\vivado\Vivado\2024.2\bin\xelab.bat" tb_rsa_montgomery -s tb_rsa_mont_snap
"F:\vivado\Vivado\2024.2\bin\xsim.bat" tb_rsa_mont_snap -R
```

| Case | n | e | msg (M) | C kỳ vọng (Python `pow`) | Kết quả |
|---|---:|---:|---:|---:|---|
| `wikipedia_classic` | 3233 | 17 | 65 | 2790 | **PASS** (181 chu kỳ) |
| `msg_needs_reduce` | 3233 | 17 | 3300 (> n) | 641 | **PASS** (181 chu kỳ) |
| `bigger_n` | 60491 | 17 | 12345 | 41476 | **PASS** (181 chu kỳ) |
| `e65537_industry_std` | 4292870399 | **65537** | 777777 | 2879956855 | **PASS** (181 chu kỳ) |

```
[PASS] wikipedia_classic C=2790 (0x00000ae6) sau 181 chu ky
[PASS] msg_needs_reduce C=641 (0x00000281) sau 181 chu ky
[PASS] bigger_n C=41476 (0x0000a204) sau 181 chu ky
[PASS] e65537_industry_std C=2879956855 (0xaba8a777) sau 181 chu ky
ALL RSA MONTGOMERY TESTS PASS - khop pow(msg,e,n) Python
```

→ **Kết luận: `montgomery_reduce`, `montgomery_mul`, `rsa` đều đúng**, kể cả
với `e=65537` và modulus gần đầy 32-bit (`n=4292870399`, sát trần
`2³²-1=4294967295`) — đúng chuẩn RSA verify công nghiệp (khác hẳn `e` tự sinh
bất thường của bản `control`/Euclid cũ). **181 chu kỳ cố định** mỗi lần verify
(luôn xử lý đủ 32 bit của `E`, không phụ thuộc giá trị `E` thật — do vòng
lặp chạy cố định `E_BITS=32` lần bất kể bit cao có bằng 0 hay không).

## Lưu ý khi dùng (không phải bug, cần biết trước khi tích hợp)

1. **`WIDTH=32` → không phải RSA production-grade**: `N` tối đa gần
   `2^32 ≈ 4.3 tỷ` — quá yếu để bảo mật thật (RSA thực tế cần `N` ≥ 2048-bit).
   Đây là core phục vụ minh hoạ kiến trúc/demo cho paper (đúng tinh thần các
   core khác trong project — RISSP/AES cũng ở quy mô nghiên cứu, không phải
   sản phẩm thương mại). Cần ghi rõ giới hạn này trong phần Limitations của
   paper.
2. **`N_INV`/`R2_MOD_N` phải tính đúng offline** trước khi nạp — công thức:
   `N_INV = (-modinv(N, 2^32)) mod 2^32`, `R2_MOD_N = 2^64 mod N` (dùng
   Python `pow(N, -1, 2**32)` và `pow(2, 64, N)`). Nạp sai 2 giá trị này sẽ
   ra kết quả sai mà không có cảnh báo gì từ RTL (không có cơ chế tự kiểm
   tra tính hợp lệ của `N_INV`/`R2_MOD_N`).
3. **181 chu kỳ cố định mỗi lần gọi** (không tối ưu theo `E` thực tế có ít
   bit 1 hay không) — nếu cần tối ưu hiệu năng có thể sửa để bỏ qua các bit
   0 ở đầu `E` (giảm chu kỳ khi `E` nhỏ hơn 32-bit thật), nhưng **không sửa
   nếu không có yêu cầu cụ thể** — 181 chu kỳ ở 50MHz chỉ ~3.6µs, không phải
   nút thắt cho ứng dụng secure boot/verify (tần suất thấp).
4. Không có cơ chế kiểm tra `N` có phải hợp số hợp lệ (`p·q` với `p,q` nguyên
   tố) hay không — nạp `N` sai vẫn chạy ra 1 kết quả (sai về mặt toán học),
   không có cảnh báo.

## Đối chiếu với vai trò trong paper

Vì core chỉ cần `(N,E)` công khai — đúng mô hình **verify chữ ký số / secure
boot** (thiết bị xác minh chữ ký ký ngoại tuyến bởi khoá bí mật `d` tại máy
chủ build/release, không bao giờ giữ `p,q,d`). Đây là điểm khác biệt quan
trọng so với đánh giá sai trước đó (nghĩ rằng RSA_core cần `p,q` nên không
verify chuẩn được) — xem cập nhật tương ứng trong `../PaperStrategy.md`.
