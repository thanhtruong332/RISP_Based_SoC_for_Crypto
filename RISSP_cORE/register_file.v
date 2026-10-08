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
    // REGISTER STORAGE (32 thanh ghi 32-bit)
    // ram_style="distributed": ép Vivado suy ra LUTRAM thay vì FF+mux 32:1.
    // QUAN TRỌNG: LUTRAM không có chân reset hàng loạt -- vòng lặp "reset toàn bộ
    // về 0" (bản trước) khiến Vivado bỏ qua ram_style và dựng lại bằng FF, tốn
    // ~3000 cell (đã đo thực tế qua synth_design). Do đó KHÔNG reset mảng regs;
    // x0 được đảm bảo đọc ra 0 bằng mux ở đường đọc (không dựa vào reset).
    (* ram_style = "distributed" *) reg [31:0] regs [0:31];

    // --- READ PORT (Combinational) ---
    // [FIX]: Đọc trực tiếp từ thanh ghi, KHÔNG Forwarding!
    // Forwarding chỉ cần thiết trong Pipelined CPU và phải xử lý ở tầng ngoài.
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