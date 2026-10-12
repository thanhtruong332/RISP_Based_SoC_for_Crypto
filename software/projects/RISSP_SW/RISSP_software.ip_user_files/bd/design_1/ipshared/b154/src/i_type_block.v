`timescale 1ns / 1ps

module i_type_block (
    input  [31:0] pc,
    input  [31:0] insn,
    input  [31:0] rs1_data,
    input  [31:0] dmem_rdata,
    // shift_result / cmp_* / alu_result come from the barrel shifter,
    // comparator and adder shared with r_type_block (in modular_ex).
    // alu_result = rs1_data + imm serves ADDI, the LOAD address and the JALR
    // target. Only XORI/ORI/ANDI and the LOAD byte/half mux are local here.
    input  [31:0] shift_result,
    input         cmp_lt_signed,
    input         cmp_lt_unsigned,
    input  [31:0] alu_result,
    output [31:0] next_pc,
    output reg [31:0] rdest_data,
    output [31:0] dmem_addr
    // dmem_read and rdest_addr are decoded once in modular_ex for all opcodes.
);
    wire [6:0]  opcode = insn[6:0];
    wire [2:0]  funct3 = insn[14:12];
    wire [31:0] imm    = {{20{insn[31]}}, insn[31:20]};

    // next_pc of this block is used by modular_ex only for JALR (JAL uses j_next_pc).
    assign next_pc   = alu_result & ~32'h1;
    assign dmem_addr = alu_result;

    always @(*) begin
        rdest_data = 32'b0;

        case (opcode)
            7'b0010011: begin // ALU Immediate
                case (funct3)
                    3'b000: rdest_data = alu_result;                 // ADDI (adder dùng chung)
                    3'b010: rdest_data = cmp_lt_signed   ? 32'd1 : 32'd0; // SLTI  (comparator dùng chung)
                    3'b011: rdest_data = cmp_lt_unsigned ? 32'd1 : 32'd0; // SLTIU (comparator dùng chung)
                    3'b100: rdest_data = rs1_data ^ imm;            // XORI
                    3'b110: rdest_data = rs1_data | imm;            // ORI
                    3'b111: rdest_data = rs1_data & imm;            // ANDI
                    3'b001: rdest_data = shift_result;               // SLLI (barrel_shifter dùng chung)
                    3'b101: rdest_data = shift_result;               // SRLI/SRAI (barrel_shifter dùng chung)
                endcase
            end
            7'b0000011: begin // LOAD
                case (funct3)
                    3'b000: begin // LB
                        case(alu_result[1:0])
                            2'b00: rdest_data = {{24{dmem_rdata[7]}},  dmem_rdata[7:0]};
                            2'b01: rdest_data = {{24{dmem_rdata[15]}}, dmem_rdata[15:8]};
                            2'b10: rdest_data = {{24{dmem_rdata[23]}}, dmem_rdata[23:16]};
                            2'b11: rdest_data = {{24{dmem_rdata[31]}}, dmem_rdata[31:24]};
                        endcase
                    end
                    3'b100: begin // LBU
                        case(alu_result[1:0])
                            2'b00: rdest_data = {24'b0, dmem_rdata[7:0]};
                            2'b01: rdest_data = {24'b0, dmem_rdata[15:8]};
                            2'b10: rdest_data = {24'b0, dmem_rdata[23:16]};
                            2'b11: rdest_data = {24'b0, dmem_rdata[31:24]};
                        endcase
                    end
                    3'b010: rdest_data = dmem_rdata; // LW
                    default: rdest_data = 32'b0;
                endcase
            end
            // JALR: rdest_data = pc+4 is produced in modular_ex (shared with JAL).
        endcase
    end
endmodule