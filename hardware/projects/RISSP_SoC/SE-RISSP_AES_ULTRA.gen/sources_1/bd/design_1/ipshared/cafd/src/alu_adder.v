`timescale 1ns / 1ps
// Adder/subtractor shared by r_type_block (ADD/SUB) and i_type_block
// (ADDI / LOAD address / JALR target). op_a is always rs1_data; op_b reuses
// the comparator's operand-B mux (rs2_data for R-type, imm_i for I-type),
// so no extra 32-bit mux is needed.
module alu_adder (
    input  [31:0] op_a, op_b,
    input         sub,   // 1 = trừ (chỉ SUB của R-type dùng); 0 = cộng
    output [31:0] result
);
    assign result = sub ? (op_a - op_b) : (op_a + op_b);
endmodule
