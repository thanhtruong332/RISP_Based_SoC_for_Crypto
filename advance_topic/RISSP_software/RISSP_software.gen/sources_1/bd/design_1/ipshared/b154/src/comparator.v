`timescale 1ns / 1ps
// Comparator DÙNG CHUNG giữa r_type_block (SLT/SLTU) và i_type_block
// (SLTI/SLTIU) -- nhượng bộ kiến trúc thứ 2 (sau barrel_shifter), đã xác
// nhận với người dùng. op_a luôn là rs1_data cho cả 2 dạng lệnh; chỉ op_b
// khác nhau (rs2_data cho R-type, imm cho I-type) -- modular_ex mux đúng 1
// chỗ duy nhất rồi feed vào đây, adder/bitwise của 2 block vẫn tách biệt.
module comparator (
    input  [31:0] op_a, op_b,
    output        lt_signed,
    output        lt_unsigned
);
    assign lt_signed   = ($signed(op_a) < $signed(op_b));
    assign lt_unsigned = (op_a < op_b);
endmodule
