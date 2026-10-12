`timescale 1ns / 1ps

module register_file (
    input         clk,
    input         rst_n,
    input         wen,
    input  [4:0]  rs1_addr,
    input  [4:0]  rs2_addr,
    input  [4:0]  rdest_addr,
    input  [31:0] rdest_data,
    output [31:0] rs1_data,
    output [31:0] rs2_data
);
    // REGISTER STORAGE (32 x 32-bit), ram_style="distributed" -> LUTRAM.
    // The array is not reset (LUTRAM has no bulk reset, a reset loop would
    // turn it into flip-flops); x0 reads as 0 through the read-port mux.
    (* ram_style = "distributed" *) reg [31:0] regs [0:31];

    // --- READ PORT (combinational, no forwarding) ---
    assign rs1_data = (rs1_addr == 5'b0) ? 32'b0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'b0) ? 32'b0 : regs[rs2_addr];

    // --- WRITE PORT (Sequential, không reset mảng) ---
    always @(posedge clk) begin
        if (wen && (rdest_addr != 5'b0)) begin
            // Chỉ ghi khi có tín hiệu wen và không ghi vào x0
            regs[rdest_addr] <= rdest_data;
        end
    end

endmodule