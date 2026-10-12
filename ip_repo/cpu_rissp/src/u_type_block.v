`timescale 1ns / 1ps
module u_type_block (
    // ===== INPUTS =====
    input  [31:0] pc,           // Program Counter từ FETCH
    input  [31:0] insn,         // Instruction từ IMEM

    // ===== OUTPUTS =====
    // Không có next_pc/rdest_addr: U-type không đổi PC (luôn pc+4 mặc định ở
    // modular_ex), rdest_addr do modular_ex tự decode 1 lần dùng chung.
    output reg [31:0] rdest_data    // Result data ghi vào RF
);

// ===== DECODE INSTRUCTION FIELDS =====
wire [6:0]  opcode = insn[6:0];
wire [31:0] imm = {insn[31:12], 12'b0};  // Upper 20 bits

// ===== EXECUTION LOGIC =====
// Đây là adder DUY NHẤT và CẦN THIẾT của block này: AUIPC bắt buộc phải có
// pc+imm, không thể giảm thêm mà không phá kiến trúc song song. Nhánh LUI
// dùng imm thẳng (không tốn adder) -- 2 nhánh share chung 1 mux ngõ ra, đã
// tối thiểu (1 adder cho cả block, không có adder thừa/trùng).
always @(*) begin
    if (opcode == 7'b0110111) rdest_data = imm;        // LUI
    else                      rdest_data = pc + imm;   // AUIPC
end

endmodule