Author       : Thanh Truong
`timescale 1ns / 1ps
module axi_rissp_master (
   // Global Signals
    input  wire        clk,
    input  wire        rst_n,

    // CPU Data Memory Interface
    input  wire [31:0] dmem_addr,
    input  wire [31:0] dmem_wdata,
    input  wire [ 3:0] dmem_wstrb,
    input  wire        dmem_read,
    output reg  [31:0] dmem_rdata,
    output wire        stall_cpu,

    // AXI4-Lite Master Interface
    
    // Write Address Channel (AW)
    output reg  [31:0] m_axi_awaddr,
    output wire [ 2:0] m_axi_awprot,
    output reg         m_axi_awvalid,
    input  wire        m_axi_awready,

    // Write Data Channel (W)
    output reg  [31:0] m_axi_wdata,
    output reg  [ 3:0] m_axi_wstrb,
    output reg         m_axi_wvalid,
    input  wire        m_axi_wready,

    // Write Response Channel (B)
    input  wire [ 1:0] m_axi_bresp,
    input  wire        m_axi_bvalid,
    output reg         m_axi_bready,

    // Read Address Channel (AR)
    output reg  [31:0] m_axi_araddr,
    output wire [ 2:0] m_axi_arprot,
    output reg         m_axi_arvalid,
    input  wire        m_axi_arready,

    // Read Data Channel (R)
    input  wire [31:0] m_axi_rdata,
    input  wire [ 1:0] m_axi_rresp,
    input  wire        m_axi_rvalid,
    output reg         m_axi_rready
);
    assign m_axi_awprot = 3'b000;
    assign m_axi_arprot = 3'b000;

    localparam IDLE       = 3'd0;
    localparam WRITE_DATA = 3'd1;
    localparam READ_DATA  = 3'd2;
    localparam DONE       = 3'd3;

    reg [2:0] state;

    wire cpu_req = (|dmem_wstrb) || dmem_read;

    assign stall_cpu = (state == IDLE && cpu_req) ||
                       (state == WRITE_DATA)      ||
                       (state == READ_DATA);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
          // State & Internal Data
            state         <= IDLE;
            dmem_rdata    <= 32'h0;

            // AXI Write Channels (AW, W, B)
            m_axi_awaddr  <= 32'h0;
            m_axi_awvalid <= 1'b0;
            m_axi_wdata   <= 32'h0;
            m_axi_wstrb   <= 4'h0;
            m_axi_wvalid  <= 1'b0;
            m_axi_bready  <= 1'b0;

            // AXI Read Channels (AR, R)
            m_axi_araddr  <= 32'h0;
            m_axi_arvalid <= 1'b0;
            m_axi_rready  <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (cpu_req) begin
                        if (|dmem_wstrb) begin
                           state         <= WRITE_DATA;
                            // AXI Write Address & Data
                            m_axi_awaddr  <= dmem_addr;
                            m_axi_awvalid <= 1'b1;
                            m_axi_wdata   <= dmem_wdata;
                            m_axi_wstrb   <= dmem_wstrb;
                            m_axi_wvalid  <= 1'b1;
                            m_axi_bready  <= 1'b1;
                    
                            end else begin // dmem_read
                                state         <= READ_DATA;
                                // AXI Read Address
                                m_axi_araddr  <= dmem_addr;
                                m_axi_arvalid <= 1'b1;
                                m_axi_rready  <= 1'b1;
                        end
                    end
                end

                WRITE_DATA: begin
                    if (m_axi_awvalid && m_axi_awready) m_axi_awvalid <= 0;
                    if (m_axi_wvalid  && m_axi_wready ) m_axi_wvalid  <= 0;
                    if (m_axi_bvalid  && m_axi_bready ) begin
                        m_axi_bready <= 0;
                        state        <= DONE;
                    end
                end

                READ_DATA: begin
                    if (m_axi_arvalid && m_axi_arready) m_axi_arvalid <= 0;
                    if (m_axi_rvalid  && m_axi_rready ) begin
                        dmem_rdata   <= m_axi_rdata;   
                        m_axi_rready <= 0;
                        state        <= DONE;
                    end
                end

                DONE: begin
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
