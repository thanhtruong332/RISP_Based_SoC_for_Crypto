//Author       : Thanh Truong
`timescale 1ns / 1ps
module alu_adder (
    input  [31:0] op_a, op_b,
    input         sub,   
    output [31:0] result
);
    assign result = sub ? (op_a - op_b) : (op_a + op_b);
endmodule
