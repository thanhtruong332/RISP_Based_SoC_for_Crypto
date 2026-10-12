## ================================================================
##  rissp_constraints.xdc - template rang buoc cho RISSP tren Zynq-7020
##
##  LUU Y QUAN TRONG cho so sanh cong bang voi RV32I:
##  - Phai dat CUNG mot chu ky clock cho ca 2 core khi so power/area,
##    neu khong so sanh vo nghia (power ti le voi f).
##  - RISSP single-cycle co critical path DAI hon (ca datapath trong 1
##    chu ky) nen KHONG dat clock qua nhanh. Dat bang tan so ma CA HAI
##    core deu dat duoc positive slack, roi so power tai diem do.
## ================================================================

## --- Clock chinh ---
## Vi du 10 MHz (100 ns). CHINH lai cho khop thi nghiem cua boss.
## Neu core chay tren SoC voi PS clock, dung ten clock tuong ung.
create_clock -period 100.000 -name sys_clk [get_ports clk]

## --- Input/Output delay (neu core standalone, dat gia tri an toan) ---
set_input_delay  -clock sys_clk 2.000 [all_inputs]
set_output_delay -clock sys_clk 2.000 [all_outputs]

## --- Reset la async, khong rang buoc timing qua no ---
set_false_path -from [get_ports rst_n]

## ================================================================
##  GHI CHU tuong tu cho RV32I (dat trong xdc rieng cua RV32I):
##  - Cung create_clock -period 100.000
##  - LUU Y: rv32i_top co nhieu (* DONT_TOUCH = "yes" *) tren cac
##    pipeline register va module (RF, ALU, Control_unit, PC...).
##    DONT_TOUCH NGAN Vivado toi uu/share -> RV32I dang bi "khoa" khong
##    cho toi uu. Neu muon so sanh CONG BANG ve muc do toi uu, nen:
##      + Hoac BO het DONT_TOUCH tren ca 2 core (ca 2 deu duoc toi uu),
##      + Hoac GIU tren ca 2 (ca 2 deu khong duoc toi uu).
##    Hien tai RISSP KHONG co DONT_TOUCH con RV32I CO -> RV32I dang bi
##    thiet thoi ve toi uu, nhung dong thoi cac pipeline FF cua no khong
##    bi merge nen giu dung so lieu. Day la yeu to lam lech so sanh.
## ================================================================
