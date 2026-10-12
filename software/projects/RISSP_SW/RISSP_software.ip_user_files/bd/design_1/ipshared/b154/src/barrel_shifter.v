`timescale 1ns / 1ps
// Barrel shifter shared by r_type_block (SLL/SRL/SRA) and i_type_block
// (SLLI/SRLI/SRAI). Both formats encode the direction (funct3) and
// logical/arithmetic select (insn[30]) at the same bit positions, so
// modular_ex only muxes the shift amount (rs2 for R-type, insn[24:20]
// for I-type).
module barrel_shifter (
    input  [31:0] data,
    input  [4:0]  shamt,
    input         left,   // 1 = dịch trái (SLL/SLLI), 0 = dịch phải (SRL/SRA/SRLI/SRAI)
    input         arith,  // 1 = dịch phải có dấu (SRA/SRAI); bỏ qua khi left=1
    output reg [31:0] result
);
    // Do not mix $signed()/unsigned operands in one ternary: Verilog would
    // evaluate the whole expression as unsigned and >>> would become a
    // logical shift.
    always @(*) begin
        if (left)       result = data << shamt;
        else if (arith) result = $signed(data) >>> shamt;
        else            result = data >> shamt;
    end
endmodule
