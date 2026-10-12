//Author       : Thanh Truong
`timescale 1ns / 1ps
module j_type_block (
    input  [31:0] pc,          
    input  [31:0] insn,         
    output reg [31:0] next_pc       
);

wire [31:0] imm = {{11{insn[31]}}, insn[31], insn[19:12], insn[20], insn[30:21], 1'b0};

always @(*) begin
    next_pc = pc + imm;  // Jump target
end

endmodule
