`timescale 1ns / 1ps
module s_type_block (
    input  [31:0] pc,           // Không dùng: STORE không đổi PC (pc+4 mặc định ở modular_ex)
    input  [31:0] insn,
    input  [31:0] rs1_data,
    input  [31:0] rs2_data,
    output [31:0] dmem_addr,
    output reg [31:0] dmem_wdata,
    output reg [3:0]  dmem_wstrb
);
    wire [2:0]  funct3 = insn[14:12];
    wire [31:0] imm = {{20{insn[31]}}, insn[31:25], insn[11:7]};
    wire [31:0] addr = rs1_data + imm;

    assign dmem_addr = addr;

    always @(*) begin
        dmem_wdata = 32'b0;
        dmem_wstrb = 4'b0000;
        case (funct3)
            3'b000: begin // SB (Store Byte)
                case (addr[1:0])
                    2'b00: begin dmem_wdata[7:0]   = rs2_data[7:0]; dmem_wstrb = 4'b0001; end
                    2'b01: begin dmem_wdata[15:8]  = rs2_data[7:0]; dmem_wstrb = 4'b0010; end
                    2'b10: begin dmem_wdata[23:16] = rs2_data[7:0]; dmem_wstrb = 4'b0100; end
                    2'b11: begin dmem_wdata[31:24] = rs2_data[7:0]; dmem_wstrb = 4'b1000; end
                endcase
            end
            3'b001: begin // SH (Store Halfword)
                if (addr[1]) begin dmem_wdata[31:16] = rs2_data[15:0]; dmem_wstrb = 4'b1100; end
                else         begin dmem_wdata[15:0]  = rs2_data[15:0]; dmem_wstrb = 4'b0011; end
            end
            3'b010: begin // SW (Store Word)
                dmem_wdata = rs2_data;
                dmem_wstrb = 4'b1111;
            end
        endcase
    end
endmodule