`timescale 1ns / 1ps
// Comparator shared by r_type_block (SLT/SLTU) and i_type_block
// (SLTI/SLTIU). op_a is always rs1_data; op_b is rs2_data (R-type) or imm
// (I-type), selected once in modular_ex.
module comparator (
    input  [31:0] op_a, op_b,
    output        lt_signed,
    output        lt_unsigned
);
    assign lt_signed   = ($signed(op_a) < $signed(op_b));
    assign lt_unsigned = (op_a < op_b);
endmodule
