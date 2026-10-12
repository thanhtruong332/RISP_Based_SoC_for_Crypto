//Author       : Thanh Truong
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
    wire [4:0]  shift_shamt  = (opcode == 7'b0110011) ? rs2_data[4:0] : insn[24:20];
    wire        shift_left   = (funct3 == 3'b001);
    wire        shift_arith  = insn[30];
    wire [31:0] shift_result;
  barrel_shifter shifter (
        .data   (rs1_data),
        .shamt  (shift_shamt),
        .left   (shift_left),
        .arith  (shift_arith),
        .result (shift_result)
    );
    wire [31:0] imm_i    = {{20{insn[31]}}, insn[31:20]};
    wire [31:0] alu_op_b = (opcode == 7'b0110011) ? rs2_data : imm_i;
    wire        cmp_lt_signed, cmp_lt_unsigned;
    comparator cmp (
        .op_a        (rs1_data),
        .op_b        (alu_op_b),
        .lt_signed   (cmp_lt_signed),
        .lt_unsigned (cmp_lt_unsigned)
    );
    
    wire        alu_sub = (opcode == 7'b0110011) && (funct3 == 3'b000) && insn[30];
    wire [31:0] alu_result;
    
    alu_adder adder (
        .op_a   (rs1_data),
        .op_b   (alu_op_b),
        .sub    (alu_sub),
        .result (alu_result)
    );

    wire [31:0] b_next_pc, j_next_pc, i_next_pc_jalr, r_rdest, i_rdest, u_rdest;
    wire [31:0] i_dmem_addr, s_dmem_addr, s_dmem_wdata;
    wire [3:0]  s_dmem_wstrb;
    // R-Type Instruction Block
    r_type_block r_blk (
        .pc              (pc),
        .insn            (insn),
        .rs1_data        (rs1_data),
        .rs2_data        (rs2_data),
        .shift_result    (shift_result),
        .cmp_lt_signed   (cmp_lt_signed),
        .cmp_lt_unsigned (cmp_lt_unsigned),
        .alu_result      (alu_result),
        .rdest_data      (r_rdest)
    );

    // I-Type Instruction Block
    i_type_block i_blk (
        .pc              (pc),
        .insn            (insn),
        .rs1_data        (rs1_data),
        .dmem_rdata      (dmem_rdata),
        .shift_result    (shift_result),
        .cmp_lt_signed   (cmp_lt_signed),
        .cmp_lt_unsigned (cmp_lt_unsigned),
        .alu_result      (alu_result),
        .next_pc         (i_next_pc_jalr),
        .rdest_data      (i_rdest),
        .dmem_addr       (i_dmem_addr)     // Note: dmem_read removed from port list
    );

    // B-Type Instruction Block (Branches)
    b_type_block b_blk (
        .pc              (pc),
        .insn            (insn),
        .rs1_data        (rs1_data),
        .rs2_data        (rs2_data),
        .next_pc         (b_next_pc)
    );

    // J-Type Instruction Block (Jumps)
    j_type_block j_blk (
        .pc              (pc),
        .insn            (insn),
        .next_pc         (j_next_pc)
    );

    // U-Type Instruction Block (Upper Immediates)
    u_type_block u_blk (
        .pc              (pc),
        .insn            (insn),
        .rdest_data      (u_rdest)
    );

    // S-Type Instruction Block (Stores)
    s_type_block s_blk (
        .pc              (pc),
        .insn            (insn),
        .rs1_data        (rs1_data),
        .rs2_data        (rs2_data),
        .dmem_addr       (s_dmem_addr),
        .dmem_wdata      (s_dmem_wdata),
        .dmem_wstrb      (s_dmem_wstrb)
    );

    always @(*) begin
        next_pc    = pc + 4; 
        rdest_data = 32'b0;
        rdest_addr = insn[11:7];
        rf_wen     = 1'b0;
        dmem_addr  = 32'b0;
        dmem_wdata = 32'b0;
        dmem_wstrb = 4'b0000;
        dmem_read  = 1'b0;

        case (opcode)
            7'b0110111, 7'b0010111: begin // LUI, AUIPC
                rdest_data = u_rdest; rf_wen = 1'b1;
            end
            7'b0010011: begin // I-type ALU
                rdest_data = i_rdest; rf_wen = 1'b1;
            end
            7'b0000011: begin // LOAD (lb/lbu/lw)
                dmem_addr  = i_dmem_addr;
                dmem_read  = 1'b1;
                rdest_data = i_rdest; rf_wen = 1'b1;
            end
            7'b0100011: begin // STORE (sb/sh/sw)
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
