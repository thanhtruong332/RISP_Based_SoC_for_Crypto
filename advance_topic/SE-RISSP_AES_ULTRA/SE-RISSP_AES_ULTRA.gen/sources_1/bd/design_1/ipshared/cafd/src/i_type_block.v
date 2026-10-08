`timescale 1ns / 1ps

module i_type_block (
    input  [31:0] pc,
    input  [31:0] insn,
    input  [31:0] rs1_data,
    input  [31:0] dmem_rdata,
    // shift_result/cmp_*/alu_result: kết quả từ barrel_shifter, comparator,
    // adder DÙNG CHUNG với r_type_block (đặt/điều khiển ở modular_ex) -- 3
    // nhượng bộ kiến trúc duy nhất giữa 2 block. alu_result = rs1_data+imm,
    // dùng cho CẢ 3 việc của block này (ADDI, địa chỉ LOAD, target JALR) --
    // vẫn đúng 1 lần tính, chỉ khác là adder đó nay nằm ở modular_ex thay vì
    // ở đây. Chỉ còn bitwise (XORI/ORI/ANDI) và mux byte/half LOAD là riêng
    // của block này.
    input  [31:0] shift_result,
    input         cmp_lt_signed,
    input         cmp_lt_unsigned,
    input  [31:0] alu_result,
    output [31:0] next_pc,
    output reg [31:0] rdest_data,
    output [31:0] dmem_addr
    // Không có port dmem_read/rdest_addr: modular_ex tự set dmem_read=1 cho
    // case LOAD, và tự decode rdest_addr 1 lần dùng chung mọi opcode -- 2 port
    // này trước kia luôn unconnected (dead).
);
    wire [6:0]  opcode = insn[6:0];
    wire [2:0]  funct3 = insn[14:12];
    wire [31:0] imm    = {{20{insn[31]}}, insn[31:20]};

    // next_pc của block này chỉ được modular_ex dùng khi opcode==JALR
    // (nhánh JAL dùng j_next_pc riêng), nên nhánh "pc+4" ở đây luôn chết -> bỏ.
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
            // Không có case JALR ở đây: modular_ex tự tính rdest_data=pc+4 dùng
            // chung cho cả JAL/JALR ở tầng trên, nên i_rdest chưa từng được đọc
            // khi opcode==JALR -- bộ cộng "pc+4" ở đây trước kia là dead logic
            // (verify chéo: xem case JAL/JALR trong modular_ex.v), đã bỏ để
            // không tốn thêm 1 adder 32-bit vô ích.
        endcase
    end
endmodule