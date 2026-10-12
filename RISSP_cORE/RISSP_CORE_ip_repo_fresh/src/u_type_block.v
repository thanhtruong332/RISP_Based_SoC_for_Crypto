//Author       : Thanh Truong
`timescale 1ns / 1ps
module u_type_block (
    input  [31:0] pc,          
    input  [31:0] insn,        
    output reg [31:0] rdest_data   
);

wire [6:0]  opcode = insn[6:0];
wire [31:0] imm = {insn[31:12], 12'b0};  // Upper 20 bits

always @(*) begin
    if (opcode == 7'b0110111) rdest_data = imm;        // LUI
    else                      rdest_data = pc + imm;   // AUIPC
end

endmodule
