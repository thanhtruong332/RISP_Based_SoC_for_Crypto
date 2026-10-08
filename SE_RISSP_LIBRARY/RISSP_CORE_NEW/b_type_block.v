`timescale 1ns / 1ps
module b_type_block (
    // ===== INPUTS =====
    input  [31:0] pc,           // Program Counter từ FETCH
    input  [31:0] insn,         // Instruction từ IMEM
    input  [31:0] rs1_data,     // Register source 1 data từ RF
    input  [31:0] rs2_data,     // Register source 2 data từ RF

    // ===== OUTPUTS =====
    // Không có rs1_addr/rs2_addr: modular_ex tự decode 1 lần dùng chung mọi
    // opcode, không cần block nào tự decode lại.
    output reg [31:0] next_pc   // Next PC (pc+4 hoặc pc+offset)
);

// ===== DECODE INSTRUCTION FIELDS =====
wire [2:0]  funct3 = insn[14:12];
wire [31:0] imm = {{19{insn[31]}}, insn[31], insn[7], insn[30:25], insn[11:8], 1'b0};

// Branch decision
reg branch_taken;

// ===== EXECUTION LOGIC =====
always @(*) begin
    // Compare and decide branch
    case (funct3)
        3'b000: branch_taken = (rs1_data == rs2_data);                    // BEQ
        3'b001: branch_taken = (rs1_data != rs2_data);                    // BNE
        3'b100: branch_taken = ($signed(rs1_data) < $signed(rs2_data));   // BLT
        3'b101: branch_taken = ($signed(rs1_data) >= $signed(rs2_data));  // BGE
        3'b110: branch_taken = (rs1_data < rs2_data);                     // BLTU
        3'b111: branch_taken = (rs1_data >= rs2_data);                    // BGEU
        default: branch_taken = 1'b0;
    endcase
    
    // Calculate next PC
    next_pc = branch_taken ? (pc + imm) : (pc + 4);
end

endmodule