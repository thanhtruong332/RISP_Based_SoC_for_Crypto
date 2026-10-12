//Author       : Thanh Truong
`timescale 1ns / 1ps
module comparator (
    input  [31:0] op_a, op_b,
    output        lt_signed,
    output        lt_unsigned
);
    assign lt_signed   = ($signed(op_a) < $signed(op_b));
    assign lt_unsigned = (op_a < op_b);
endmodule
