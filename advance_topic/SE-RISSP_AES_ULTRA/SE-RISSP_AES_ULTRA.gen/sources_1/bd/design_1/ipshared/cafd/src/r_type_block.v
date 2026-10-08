`timescale 1ns / 1ps
module r_type_block (
    // ===== INPUTS =====
    input  [31:0] pc,           // Program Counter (không dùng: R-type không đổi PC/địa chỉ)
    input  [31:0] insn,         // Instruction từ IMEM
    input  [31:0] rs1_data,     // Register source 1 data từ RF
    input  [31:0] rs2_data,     // Register source 2 data từ RF
    // shift_result/cmp_*/alu_result: kết quả từ barrel_shifter, comparator,
    // adder DÙNG CHUNG với i_type_block (đặt/điều khiển ở modular_ex) -- 3
    // nhượng bộ kiến trúc duy nhất giữa 2 block. Chỉ còn bitwise (XOR/OR/AND)
    // dưới đây là hoàn toàn độc lập/riêng của block này.
    input  [31:0] shift_result,
    input         cmp_lt_signed,
    input         cmp_lt_unsigned,
    input  [31:0] alu_result,

    // ===== OUTPUTS =====
    // Chỉ rdest_data: next_pc/rdest_addr/rs1_addr/rs2_addr đã bỏ vì modular_ex
    // không bao giờ nối các port đó (rdest_addr/rs1_addr/rs2_addr đã được
    // modular_ex tự decode 1 lần dùng chung cho mọi opcode; next_pc luôn là
    // pc+4 mặc định, cũng đã có sẵn ở modular_ex) -- giữ lại chỉ tạo dead logic.
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