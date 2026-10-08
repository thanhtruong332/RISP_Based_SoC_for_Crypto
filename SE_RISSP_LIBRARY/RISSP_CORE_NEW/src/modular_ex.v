`timescale 1ns / 1ps

module modular_ex (
    input  [31:0] pc, insn, rs1_data, rs2_data, dmem_rdata,
    output reg [31:0] next_pc, rdest_data,
    output reg [4:0]  rdest_addr,
    output reg        rf_wen,
    output reg [31:0] dmem_addr, dmem_wdata,
    output reg [3:0]  dmem_wstrb,
    output reg        dmem_read,
    output wire [4:0] rs1_addr, rs2_addr
);
    assign rs1_addr = insn[19:15];
    assign rs2_addr = insn[24:20];
    wire [6:0] opcode = insn[6:0];
    wire [2:0] funct3 = insn[14:12];

    // barrel_shifter DÙNG CHUNG giữa r_type_block (SLL/SRL/SRA) và
    // i_type_block (SLLI/SRLI/SRAI) -- thoả hiệp DUY NHẤT của kiến trúc song
    // song, đã xác nhận với người dùng (xem CLAUDE.md). rs1_data là toán
    // hạng chung cho cả 2 dạng lệnh; chỉ nguồn shamt khác nhau (thanh ghi
    // rs2 cho R-type, hằng số insn[24:20] cho I-type). left/arith lấy thẳng
    // từ funct3/insn[30] vì RV32I mã hoá 2 bit này CÙNG vị trí cho cả R-type
    // và I-type shift, không cần mux theo opcode.
    wire [4:0]  shift_shamt  = (opcode == 7'b0110011) ? rs2_data[4:0] : insn[24:20];
    wire        shift_left   = (funct3 == 3'b001);
    wire        shift_arith  = insn[30];
    wire [31:0] shift_result;
    barrel_shifter shifter (.data(rs1_data), .shamt(shift_shamt), .left(shift_left),
                             .arith(shift_arith), .result(shift_result));

    // alu_op_b: mux toán hạng B DÙNG CHUNG cho cả comparator (dưới) VÀ adder
    // (dưới nữa) -- rs2_data cho R-type, imm_i cho I-type. imm_i cũng chính
    // là immediate mà ADDI/LOAD/JALR đều dùng (chuẩn RV32I I-type), nên adder
    // dùng chung không cần thêm mux nào khác ngoài cái này.
    wire [31:0] imm_i    = {{20{insn[31]}}, insn[31:20]};
    wire [31:0] alu_op_b = (opcode == 7'b0110011) ? rs2_data : imm_i;

    // comparator DÙNG CHUNG giữa r_type_block (SLT/SLTU) và i_type_block
    // (SLTI/SLTIU) -- nhượng bộ kiến trúc thứ 2, cùng nguyên lý shifter ở trên.
    wire        cmp_lt_signed, cmp_lt_unsigned;
    comparator cmp (.op_a(rs1_data), .op_b(alu_op_b),
                     .lt_signed(cmp_lt_signed), .lt_unsigned(cmp_lt_unsigned));

    // alu_adder DÙNG CHUNG giữa r_type_block (ADD/SUB) và i_type_block
    // (ADDI / địa chỉ LOAD / target JALR) -- nhượng bộ kiến trúc thứ 3, tận
    // dụng lại alu_op_b ở trên nên không tốn thêm mux 32-bit nào. sub chỉ = 1
    // khi đúng là lệnh SUB của R-type (funct3=000 và insn[30]=1); insn[30]
    // ở các trường hợp khác (SRA/SRAI) không liên quan tới adder này.
    wire        alu_sub = (opcode == 7'b0110011) && (funct3 == 3'b000) && insn[30];
    wire [31:0] alu_result;
    alu_adder adder (.op_a(rs1_data), .op_b(alu_op_b), .sub(alu_sub), .result(alu_result));

    // Instantiate (mỗi block là 1 đơn vị thực thi song song theo đúng type của nó;
    // modular_ex chỉ mux kết quả theo opcode, KHÔNG tính lại logic của block con)
    wire [31:0] b_next_pc, j_next_pc, i_next_pc_jalr, r_rdest, i_rdest, u_rdest;
    wire [31:0] i_dmem_addr, s_dmem_addr, s_dmem_wdata;
    wire [3:0]  s_dmem_wstrb;
    r_type_block r_blk (.pc(pc), .insn(insn), .rs1_data(rs1_data), .rs2_data(rs2_data),
                         .shift_result(shift_result),
                         .cmp_lt_signed(cmp_lt_signed), .cmp_lt_unsigned(cmp_lt_unsigned),
                         .alu_result(alu_result),
                         .rdest_data(r_rdest));
    i_type_block i_blk (.pc(pc), .insn(insn), .rs1_data(rs1_data), .dmem_rdata(dmem_rdata),
                         .shift_result(shift_result),
                         .cmp_lt_signed(cmp_lt_signed), .cmp_lt_unsigned(cmp_lt_unsigned),
                         .alu_result(alu_result),
                         .next_pc(i_next_pc_jalr), .rdest_data(i_rdest), .dmem_addr(i_dmem_addr)); // dmem_read đã bỏ khỏi port
    b_type_block b_blk (.pc(pc), .insn(insn), .rs1_data(rs1_data), .rs2_data(rs2_data), .next_pc(b_next_pc));
    j_type_block j_blk (.pc(pc), .insn(insn), .next_pc(j_next_pc));
    u_type_block u_blk (.pc(pc), .insn(insn), .rdest_data(u_rdest));
    s_type_block s_blk (.pc(pc), .insn(insn), .rs1_data(rs1_data), .rs2_data(rs2_data),
                         .dmem_addr(s_dmem_addr), .dmem_wdata(s_dmem_wdata), .dmem_wstrb(s_dmem_wstrb));

    always @(*) begin
        // --- GIÁ TRỊ MẶC ĐỊNH ---
        next_pc    = pc + 4; 
        rdest_data = 32'b0;
        rdest_addr = insn[11:7];
        rf_wen     = 1'b0;
        dmem_addr  = 32'b0;
        dmem_wdata = 32'b0;
        dmem_wstrb = 4'b0000;
        dmem_read  = 1'b0;

        case (opcode)
            7'b0110111, 7'b0010111: begin // LUI, AUIPC (u_type_block tự phân biệt qua opcode)
                rdest_data = u_rdest; rf_wen = 1'b1;
            end
            7'b0010011: begin // I-type ALU
                rdest_data = i_rdest; rf_wen = 1'b1;
            end
            7'b0000011: begin // LOAD (lb/lbu/lw - i_type_block đã xử lý đúng theo funct3)
                dmem_addr  = i_dmem_addr;
                dmem_read  = 1'b1;
                rdest_data = i_rdest; rf_wen = 1'b1;
            end
            7'b0100011: begin // STORE (sb/sh/sw - s_type_block xử lý đúng theo funct3)
                dmem_addr  = s_dmem_addr;
                dmem_wdata = s_dmem_wdata;
                dmem_wstrb = s_dmem_wstrb;
                rf_wen     = 1'b0;
            end
            7'b1100011: next_pc = b_next_pc;
            7'b1101111, 7'b1100111: begin // JAL, JALR
                next_pc = (opcode == 7'b1101111) ? j_next_pc : i_next_pc_jalr;
                rdest_data = pc + 4; rf_wen = 1'b1;
            end
            7'b0110011: begin rdest_data = r_rdest; rf_wen = 1'b1; end
            default: ;
        endcase
    end
endmodule