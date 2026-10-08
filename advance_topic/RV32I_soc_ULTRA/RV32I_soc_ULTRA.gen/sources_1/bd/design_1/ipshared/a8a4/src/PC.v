module PC(
    input   wire            clk,
    input   wire            rst_n,
    input   wire            Stall,

    input   wire            Branch,
    input   wire            Pcsrc,
    input   wire            Jump,
    input   wire            Branch_taken,

    input   wire    [31:0]  offset,
    input   wire    [31:0]  rs1_data,
    
    // THÊM PORT NÀY MỚI CỨU ĐƯỢC PIPELINE!
    // Đây là PC của chính cái lệnh Jump/Branch đang được xử lý ở tầng dưới
    input   wire    [31:0]  pc_of_instruction,

    output  wire    [31:0]  pc,

    // ================================================================
    //  [FIX 2026-08-13] Dua next_pc RA NGOAI.
    //  Ly do: imem cua SoC la BRAM co do tre 1 chu ky. Muon du lieu ve
    //  DUNG NHIP voi pc_reg thi phai gui dia chi sang BRAM SOM 1 chu ky,
    //  tuc la gui next_pc chu khong phai pc. Truoc day next_pc chi la
    //  bien noi bo nen rv32i_top khong the lay duoc -> buoc phai gui pc
    //  -> lech 1 nhip. Xem ghi chu day du trong rv32i_top.v.
    //  Chi THEM DAY NOI, khong doi mot dong logic nao ben duoi.
    // ================================================================
    output  wire    [31:0]  next_pc_out
);

    wire    [31:0]  pc_plus4;
    wire    [31:0]  branch_target;
    wire    [31:0]  jalr_target;
    reg     [31:0]  next_pc, pc_reg;

    assign  pc_plus4        = pc_reg + 32'd4;
    
    // SỬA DÒNG NÀY: Dùng PC của chính lệnh đó thay vì pc_reg hiện tại của trạm Fetch
    assign  branch_target   = pc_of_instruction + offset; 
    
    assign  jalr_target     = (rs1_data + offset) & ~32'd1;

    always @(*) begin   
        if (Jump && Pcsrc)            
            next_pc = jalr_target;
        else if (Jump)                 
            next_pc = branch_target;
        else if (Branch && Branch_taken)
            next_pc = branch_target;
        else
            next_pc = pc_plus4;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            pc_reg <= 32'h0;
        else if(~Stall)
            pc_reg <= next_pc;
    end

    assign  pc  = pc_reg;

    // [FIX] dia chi cua lenh KE TIEP, de rv32i_top gui som cho BRAM
    assign  next_pc_out = next_pc;

endmodule