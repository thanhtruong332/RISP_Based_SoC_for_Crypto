`timescale 1ns / 1ps
// Adder/subtractor DÙNG CHUNG giữa r_type_block (ADD/SUB) và i_type_block
// (ADDI / địa chỉ LOAD / target JALR) -- nhượng bộ kiến trúc thứ 3 (sau
// barrel_shifter, comparator), đã xác nhận với người dùng. op_a luôn là
// rs1_data cho cả 2 dạng lệnh; op_b dùng LẠI đúng mux đã có cho comparator
// (rs2_data cho R-type, imm_i cho I-type -- imm_i cũng chính là immediate mà
// ADDI/LOAD/JALR đều dùng, theo chuẩn RV32I I-type) nên không tốn thêm mux
// 32-bit nào -- đây là lý do gộp adder "lãi" hơn hẳn gộp comparator.
module alu_adder (
    input  [31:0] op_a, op_b,
    input         sub,   // 1 = trừ (chỉ SUB của R-type dùng); 0 = cộng
    output [31:0] result
);
    assign result = sub ? (op_a - op_b) : (op_a + op_b);
endmodule
