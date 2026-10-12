`timescale 1ns / 1ps
module r_type_block (
    input  [31:0] pc,          
    input  [31:0] insn,         
    input  [31:0] rs1_data,   
    input  [31:0] rs2_data,     
    input  [31:0] shift_result,
    input         cmp_lt_signed,
    input         cmp_lt_unsigned,
    input  [31:0] alu_result,
    output reg [31:0] rdest_data   
);

wire [2:0] funct3 = insn[14:12];

always @(*) begin
    // Execute ALU operation
    case (funct3)
3'b000: rdest_data = alu_result;                      // ADD/SUB (shared adder)
                    3'b001: rdest_data = shift_result;                    // SLL     (shared barrel shifter)
                    3'b010: rdest_data = cmp_lt_signed   ? 32'd1 : 32'd0; // SLT     (shared comparator)
                    3'b011: rdest_data = cmp_lt_unsigned ? 32'd1 : 32'd0; // SLTU    (shared comparator)
                    3'b100: rdest_data = rs1_data ^ rs2_data;             // XOR
                    3'b101: rdest_data = shift_result;                    // SRL/SRA (shared barrel shifter)
                    3'b110: rdest_data = rs1_data | rs2_data;             // OR
                    3'b111: rdest_data = rs1_data & rs2_data;             // AND

        default: rdest_data = 32'b0;
    endcase
end

endmodule
