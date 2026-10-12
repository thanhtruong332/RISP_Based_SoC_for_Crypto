`timescale 1ns / 1ps
module r_type_block (
    // ===== INPUTS =====
    input  [31:0] pc,           // Program Counter (không dùng: R-type không đổi PC/địa chỉ)
    input  [31:0] insn,         // Instruction từ IMEM
    input  [31:0] rs1_data,     // Register source 1 data từ RF
    input  [31:0] rs2_data,     // Register source 2 data từ RF
    // shift_result / cmp_* / alu_result come from the barrel shifter,
    // comparator and adder shared with i_type_block (in modular_ex).
    // The bitwise operations (XOR/OR/AND) below are local to this block.
    input  [31:0] shift_result,
    input         cmp_lt_signed,
    input         cmp_lt_unsigned,
    input  [31:0] alu_result,

    // ===== OUTPUTS =====
    // Only rdest_data: rdest_addr/rs1_addr/rs2_addr are decoded once in
    // modular_ex, and the default next_pc (pc+4) is also produced there.
    output reg [31:0] rdest_data    // Result data ghi vào RF
);

// ===== DECODE INSTRUCTION FIELDS =====
wire [2:0] funct3 = insn[14:12];

// ===== EXECUTION LOGIC =====
always @(*) begin
    // Execute ALU operation
    case (funct3)
        3'b000: rdest_data = alu_result;  // ADD/SUB (adder dùng chung)

        3'b001: rdest_data = shift_result;  // SLL (barrel_shifter dùng chung)

        3'b010: rdest_data = cmp_lt_signed   ? 32'd1 : 32'd0;  // SLT  (comparator dùng chung)

        3'b011: rdest_data = cmp_lt_unsigned ? 32'd1 : 32'd0;  // SLTU (comparator dùng chung)

        3'b100: rdest_data = rs1_data ^ rs2_data;  // XOR

        3'b101: rdest_data = shift_result;  // SRL/SRA (barrel_shifter dùng chung)

        3'b110: rdest_data = rs1_data | rs2_data;  // OR

        3'b111: rdest_data = rs1_data & rs2_data;  // AND

        default: rdest_data = 32'b0;
    endcase
end

endmodule