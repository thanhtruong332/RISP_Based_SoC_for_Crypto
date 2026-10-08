`timescale 1ns / 1ps
// ================================================================
//  axi_rissp_master - BAN SUA 2
//
//  Bug goc (da sua tu truoc): stall_cpu = (state != IDLE)
//    → tai cycle CPU phat request, state con IDLE nen stall=0
//    → CPU advance PC + write-back NGAY khi transaction moi bat dau
//    → LOAD lay RDATA chua ve (sai); STORE lech 1 transaction
//  Fix: them state DONE (giu nguyen o ban nay).
//
//  ---- SUA LAN 2 (2026-08-13): bo 1 chu ky lang phi moi giao dich ----
//  Ban truoc chot ket thuc bang `write_done_all = aw_done & w_done &
//  b_done`, ma ca 3 deu la THANH GHI → co lai dung 1 chu ky: chu ky N
//  bat tay B thi b_done moi len o dau chu ky N+1, nen state chi roi
//  WRITE_DATA o N+2. Do la 1 chu ky khong lam gi.
//
//  Nhan xet then chot: theo chuan AXI, slave KHONG duoc phat BVALID
//  truoc khi da nhan CA dia chi ghi VA du lieu ghi. Nen bat tay B da
//  HAM Y aw + w xong roi ⇒ chi can chot theo B la du. Tuong tu, RVALID
//  chi co the den sau khi AR duoc chap nhan ⇒ chi can chot theo R.
//
//  ⇒ Bo han 5 thanh ghi co (aw_done/w_done/b_done/ar_done/r_done) va
//    2 wire write_done_all/read_done_all. Chuyen state ngay trong dung
//    cai `if` da co san. KHONG them mot cong logic nao - do OOC:
//    LUT 22→15, FF 146→141 (NHO HON ban cu).
//
//  Chi phi moi giao dich (slave luon san sang): 5 → 4 chu ky, bang
//  dung cau AXI cua loi RV32I ⇒ so sanh 2 loi tro nen cong bang.
//  Da chay lai tb_rissp_top: PASS 43/43.
//
//  (2026-08-14: dong bo lai vao repo tu ban da sua trong Vivado cache
//  cua SE-RISSP_AES_ULTRA - ban truoc do trong repo van la BAN CU, chua
//  duoc dong bo tu luc sua. Ap dung dong bo nay cho ca root, RISSP_CORE/
//  va IBEX_CORE/rtl/ de dam bao RISSP va Ibex dung chung 1 cau AXI y het.)
// ================================================================
module axi_rissp_master (
    input clk, rst_n,
    input [31:0] dmem_addr, dmem_wdata,
    input [3:0]  dmem_wstrb,
    input        dmem_read,
    output reg [31:0] dmem_rdata,
    output wire stall_cpu,

    output reg [31:0] m_axi_awaddr, output wire [2:0] m_axi_awprot,
    output reg m_axi_awvalid, input m_axi_awready,
    output reg [31:0] m_axi_wdata, output reg [3:0] m_axi_wstrb,
    output reg m_axi_wvalid, input m_axi_wready,
    input [1:0] m_axi_bresp, input m_axi_bvalid, output reg m_axi_bready,
    output reg [31:0] m_axi_araddr, output wire [2:0] m_axi_arprot,
    output reg m_axi_arvalid, input m_axi_arready,
    input [31:0] m_axi_rdata, input [1:0] m_axi_rresp,
    input m_axi_rvalid, output reg m_axi_rready
);
    assign m_axi_awprot = 3'b000;
    assign m_axi_arprot = 3'b000;

    localparam IDLE       = 3'd0;
    localparam WRITE_DATA = 3'd1;
    localparam READ_DATA  = 3'd2;
    localparam DONE       = 3'd3;

    reg [2:0] state;

    wire cpu_req = (|dmem_wstrb) || dmem_read;

    // Stall NGAY khi co request (state==IDLE && cpu_req), giu suot
    // WRITE/READ. Chi tha o DONE de CPU advance dung 1 cycle.
    assign stall_cpu = (state == IDLE && cpu_req) ||
                       (state == WRITE_DATA)      ||
                       (state == READ_DATA);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= IDLE;
            m_axi_awaddr  <= 32'h0; m_axi_awvalid <= 0;
            m_axi_wdata   <= 32'h0; m_axi_wstrb   <= 4'h0; m_axi_wvalid <= 0;
            m_axi_bready  <= 0;
            m_axi_araddr  <= 32'h0; m_axi_arvalid <= 0; m_axi_rready <= 0;
            dmem_rdata    <= 32'h0;
        end else begin
            case (state)
                IDLE: begin
                    if (cpu_req) begin
                        if (|dmem_wstrb) begin
                            // Latch dia chi + data cua lenh SW hien tai.
                            // CPU da bi stall ngay tu cycle nay (pc giu nguyen),
                            // nen dmem_addr/dmem_wdata on dinh = dung lenh SW.
                            state         <= WRITE_DATA;
                            m_axi_awaddr  <= dmem_addr;  m_axi_awvalid <= 1;
                            m_axi_wdata   <= dmem_wdata; m_axi_wstrb   <= dmem_wstrb;
                            m_axi_wvalid  <= 1;          m_axi_bready  <= 1;
                        end else begin // dmem_read
                            state         <= READ_DATA;
                            m_axi_araddr  <= dmem_addr;  m_axi_arvalid <= 1;
                            m_axi_rready  <= 1;
                        end
                    end
                end

                WRITE_DATA: begin
                    if (m_axi_awvalid && m_axi_awready) m_axi_awvalid <= 0;
                    if (m_axi_wvalid  && m_axi_wready ) m_axi_wvalid  <= 0;
                    // Bat tay B ham y AW+W da xong (chuan AXI) → ket thuc luon.
                    if (m_axi_bvalid  && m_axi_bready ) begin
                        m_axi_bready <= 0;
                        state        <= DONE;
                    end
                end

                READ_DATA: begin
                    if (m_axi_arvalid && m_axi_arready) m_axi_arvalid <= 0;
                    // RVALID chi den sau khi AR duoc chap nhan → chot theo R.
                    if (m_axi_rvalid  && m_axi_rready ) begin
                        dmem_rdata   <= m_axi_rdata;   // latch data that
                        m_axi_rready <= 0;
                        state        <= DONE;
                    end
                end

                // DONE: stall ha xuong 1 cycle → CPU advance + write-back rd.
                // Luc nay dmem_rdata DA chac chan = data dung (latch o tren).
                DONE: begin
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
