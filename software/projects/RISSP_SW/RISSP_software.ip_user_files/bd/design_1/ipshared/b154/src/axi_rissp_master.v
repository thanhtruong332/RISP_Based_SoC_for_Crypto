`timescale 1ns / 1ps
// ================================================================
//  axi_rissp_master - CPU data-memory port to AXI4-Lite master
//
//  stall_cpu is asserted from the cycle the CPU issues a LOAD/STORE
//  and released in DONE, so the CPU advances (and writes rd back)
//  exactly once, after the read data / write response has arrived.
//
//  A write completes on the B handshake and a read on the R handshake:
//  per AXI, a slave may only assert BVALID after both AW and W have
//  been accepted, and RVALID only after AR. With an always-ready slave
//  each transaction takes 4 cycles.
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
