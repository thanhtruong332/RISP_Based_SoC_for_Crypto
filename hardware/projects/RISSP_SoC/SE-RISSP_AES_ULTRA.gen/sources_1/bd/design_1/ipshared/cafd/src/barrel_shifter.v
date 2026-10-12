`timescale 1ns / 1ps
// Barrel shifter DÙNG CHUNG giữa r_type_block (SLL/SRL/SRA) và i_type_block
// (SLLI/SRLI/SRAI) -- đây là THOẢ HIỆP DUY NHẤT phá tính "mỗi block hoàn
// toàn độc lập" của kiến trúc RISSP, đã xác nhận với người dùng trước khi
// làm (xem CLAUDE.md, mục "ghép barrel shifter"). Lý do: đo thực tế bằng
// synth_standalone cho thấy 2 shifter riêng (trong r_type_block/i_type_block)
// tốn tổng ~524 LUT (252+272) -- gộp lại còn 1 shifter tiết kiệm được phần
// lớn con số đó, trong khi adder/comparator/bitwise của 2 block vẫn tách
// biệt hoàn toàn như cũ.
//
// R-type (SLL/SRL/SRA) và I-type (SLLI/SRLI/SRAI) dùng CHUNG 1 bit điều
// khiển ngay trong mã lệnh gốc: funct3 (bit dịch trái/phải) và insn[30]
// (logic/arith cho dịch phải) nằm ở đúng cùng vị trí bit cho cả 2 dạng lệnh
// theo chuẩn RV32I -- modular_ex chỉ cần mux đúng 1 chỗ duy nhất: nguồn
// shamt (thanh ghi rs2 cho R-type, hằng số insn[24:20] cho I-type).
module barrel_shifter (
    input  [31:0] data,
    input  [4:0]  shamt,
    input         left,   // 1 = dịch trái (SLL/SLLI), 0 = dịch phải (SRL/SRA/SRLI/SRAI)
    input         arith,  // 1 = dịch phải có dấu (SRA/SRAI); bỏ qua khi left=1
    output reg [31:0] result
);
    // KHÔNG dùng ternary trộn nhánh $signed()/unsigned: Verilog sẽ ép cả
    // biểu thức về unsigned, làm mất tác dụng >>> (SRA/SRAI tính sai thành
    // dịch logic) -- cùng cạm bẫy đã sửa trong i_type_block.v trước đây.
    always @(*) begin
        if (left)       result = data << shamt;
        else if (arith) result = $signed(data) >>> shamt;
        else            result = data >> shamt;
    end
endmodule
