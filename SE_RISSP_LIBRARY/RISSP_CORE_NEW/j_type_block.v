`timescale 1ns / 1ps
module j_type_block (
    // ===== INPUTS =====
    input  [31:0] pc,           // Program Counter từ FETCH
    input  [31:0] insn,         // Instruction từ IMEM

    // ===== OUTPUTS =====
    output reg [31:0] next_pc       // Next PC (pc + offset)
    // Không có rdest_data/rdest_addr: giá trị trả về (link) của JAL là pc+4,
    // giống hệt JALR -- modular_ex đã tính CHUNG 1 lần cho cả 2 lệnh (mutual
    // exclusive theo opcode) thay vì mỗi block tự có 1 adder pc+4 riêng.
    // rdest_addr cũng do modular_ex tự decode 1 lần dùng chung mọi opcode.
);

// ===== DECODE INSTRUCTION FIELDS =====
wire [31:0] imm = {{11{insn[31]}}, insn[31], insn[19:12], insn[20], insn[30:21], 1'b0};

// ===== EXECUTION LOGIC =====
always @(*) begin
    next_pc = pc + imm;  // Jump target
end

endmodule