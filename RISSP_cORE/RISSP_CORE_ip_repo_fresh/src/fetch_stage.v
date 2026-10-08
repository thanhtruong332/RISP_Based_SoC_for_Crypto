`timescale 1ns / 1ps
module fetch_stage (
    input clk, rst_n, stall,
    input [31:0] next_pc,
    output [31:0] imem_addr,
    input [31:0] imem_rdata,
    output [31:0] pc,
    output [31:0] insn
);
    reg [31:0] pc_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)      pc_reg <= 32'h0;
        else if (!stall) pc_reg <= next_pc; // pc_reg sẽ nhận 0 ở chu kỳ đầu tiên sau reset
    end

    // imem_addr gửi sang BRAM sớm 1 chu kỳ để dữ liệu về đúng nhịp pc_reg
    assign imem_addr = next_pc;
    assign pc        = pc_reg;
    
    // Khi đang reset, ép instruction về NOP để CPU không chạy bậy
    assign insn      = (!rst_n) ? 32'h00000013 : imem_rdata;

endmodule