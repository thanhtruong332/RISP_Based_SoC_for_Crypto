//Author       : Thanh Truong
`timescale 1ns / 1ps
module barrel_shifter (
    input  [31:0] data,
    input  [4:0]  shamt,
    input         left,   // 1 = shift_left (SLL/SLLI), 0 = shift_right (SRL/SRA/SRLI/SRAI)
    input         arith,  // 1 = // Arithmetic right shift (SRA/SRAI); ignored when left=1
    output reg [31:0] result
);

    always @(*) begin
        if (left)       result = data << shamt;
        else if (arith) result = $signed(data) >>> shamt;
        else            result = data >> shamt;
    end
endmodule
