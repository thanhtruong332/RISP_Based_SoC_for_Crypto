`timescale 1ns / 1ps
// ================================================================
//  axi_rissp_master - BAN SUA
//
//  Bug goc: stall_cpu = (state != IDLE)
//    → tai cycle CPU phat request, state con IDLE nen stall=0
//    → CPU advance PC + write-back NGAY khi transaction moi bat dau
//    → LOAD lay RDATA chua ve (sai); STORE lech 1 transaction
//
//  Fix: them state DONE.
//    - stall_cpu len NGAY tu cycle co cpu_req
//    - giu stall suot transaction
//    - DONE: 1 cycle cho CPU advance, luc nay dmem_rdata da san sang
//    - khong re-trigger (DONE tach biet IDLE)
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

    // 4 trang thai (them DONE so voi ban goc)
    localparam IDLE       = 3'd0;
    localparam WRITE_DATA = 3'd1;
    localparam READ_DATA  = 3'd2;
    localparam DONE       = 3'd3;

    reg [2:0] state;
    reg aw_done, w_done, b_done, ar_done, r_done;

    wire cpu_req = (|dmem_wstrb) || dmem_read;

    // ── FIX then chot ──
    // Stall NGAY khi co request (state==IDLE && cpu_req),
    // giu suot WRITE/READ. Chi tha o DONE de CPU advance dung 1 cycle.
    assign stall_cpu = (state == IDLE && cpu_req) ||
                       (state == WRITE_DATA)      ||
                       (state == READ_DATA);

    wire write_done_all = aw_done && w_done && b_done;
    wire read_done_all  = ar_done && r_done;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= IDLE;
            m_axi_awaddr  <= 32'h0; m_axi_awvalid <= 0;
            m_axi_wdata   <= 32'h0; m_axi_wstrb   <= 4'h0; m_axi_wvalid <= 0;
            m_axi_bready  <= 0;
            m_axi_araddr  <= 32'h0; m_axi_arvalid <= 0; m_axi_rready <= 0;
            dmem_rdata    <= 32'h0;
            aw_done<=0; w_done<=0; b_done<=0; ar_done<=0; r_done<=0;
        end else begin
            case (state)
                IDLE: begin
                    aw_done<=0; w_done<=0; b_done<=0; ar_done<=0; r_done<=0;
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
                    if (m_axi_awvalid && m_axi_awready) begin m_axi_awvalid<=0; aw_done<=1; end
                    if (m_axi_wvalid  && m_axi_wready ) begin m_axi_wvalid <=0; w_done <=1; end
                    if (m_axi_bvalid  && m_axi_bready ) begin m_axi_bready <=0; b_done <=1; end
                    if (write_done_all) state <= DONE;
                end

                READ_DATA: begin
                    if (m_axi_arvalid && m_axi_arready) begin m_axi_arvalid<=0; ar_done<=1; end
                    if (m_axi_rvalid  && m_axi_rready ) begin
                        dmem_rdata   <= m_axi_rdata;   // latch data that
                        m_axi_rready <= 0; r_done <= 1;
                    end
                    if (read_done_all) state <= DONE;
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