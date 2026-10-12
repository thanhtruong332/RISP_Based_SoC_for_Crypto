`timescale 1 ns / 1 ps
//============================================================================
//  SHA3-256 AXI4-Lite slave  --  BAN FINAL (da verify bang mo hinh rissp_top)
//
//  KHAC BIET then chot so voi cac ban truoc:
//    RDATA duoc CHOT VAO THANH GHI ngay khi ar_received (dia chi da latch),
//    va GIU on dinh suot thoi gian RVALID cao.
//
//    Ban cu: rdata to hop theo (read_pulse ? araddr : 0). Cua so hop le chi
//    dung 1 nhip read_pulse. Khi qua AXI Interconnect (them nhip tre), data
//    truot khoi cua so -> master chot nham -> BRAM lech / toan 0.
//
//    Ban nay: rdata la thanh ghi, on dinh suot RVALID -> giong het cach AES
//    doc tu data_out_reg (thanh ghi giu on dinh). Firmware SACH chay dung
//    tren CA RISSP lan RV32IMB, khong can NOP hay exploit dia chi.
//============================================================================
module SHA3_hardware_new_slave_lite_v1_0_S01_AXI #
(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 8
)
(
    input  wire                                S_AXI_ACLK,
    input  wire                                S_AXI_ARESETN,
    input  wire [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_AWADDR,
    input  wire [2 : 0]                        S_AXI_AWPROT,
    input  wire                                S_AXI_AWVALID,
    output wire                                S_AXI_AWREADY,
    input  wire [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_WDATA,
    input  wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    input  wire                                S_AXI_WVALID,
    output wire                                S_AXI_WREADY,
    output wire [1 : 0]                        S_AXI_BRESP,
    output reg                                 S_AXI_BVALID,
    input  wire                                S_AXI_BREADY,
    input  wire [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_ARADDR,
    input  wire [2 : 0]                        S_AXI_ARPROT,
    input  wire                                S_AXI_ARVALID,
    output wire                                S_AXI_ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_RDATA,
    output wire [1 : 0]                        S_AXI_RRESP,
    output reg                                 S_AXI_RVALID,
    input  wire                                S_AXI_RREADY
);
    reg aw_received, w_received, ar_received;
    reg [C_S_AXI_ADDR_WIDTH-1:0] awaddr_reg, araddr_reg;
    reg [C_S_AXI_DATA_WIDTH-1:0] wdata_reg;

    assign S_AXI_AWREADY = ~aw_received;
    assign S_AXI_WREADY  = ~w_received;
    assign S_AXI_ARREADY = ~ar_received;
    assign S_AXI_BRESP   = 2'b00;
    assign S_AXI_RRESP   = 2'b00;

    // --- Tram thu dia chi ghi ---
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) aw_received <= 1'b0;
        else if (S_AXI_AWVALID && S_AXI_AWREADY) begin aw_received<=1'b1; awaddr_reg<=S_AXI_AWADDR; end
        else if (S_AXI_BVALID && S_AXI_BREADY)   aw_received<=1'b0;
    end
    // --- Tram thu du lieu ghi ---
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) w_received <= 1'b0;
        else if (S_AXI_WVALID && S_AXI_WREADY) begin w_received<=1'b1; wdata_reg<=S_AXI_WDATA; end
        else if (S_AXI_BVALID && S_AXI_BREADY) w_received<=1'b0;
    end
    // --- Ghep cap + write_pulse ---
    reg write_pulse;
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin S_AXI_BVALID<=1'b0; write_pulse<=1'b0; end
        else if (aw_received && w_received && !S_AXI_BVALID) begin S_AXI_BVALID<=1'b1; write_pulse<=1'b1; end
        else begin write_pulse<=1'b0; if (S_AXI_BVALID && S_AXI_BREADY) S_AXI_BVALID<=1'b0; end
    end
    // --- Kenh doc: latch dia chi ---
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) ar_received <= 1'b0;
        else if (S_AXI_ARVALID && S_AXI_ARREADY) begin ar_received<=1'b1; araddr_reg<=S_AXI_ARADDR; end
        else if (S_AXI_RVALID && S_AXI_RREADY)   ar_received<=1'b0;
    end
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) S_AXI_RVALID <= 1'b0;
        else if (ar_received && !S_AXI_RVALID) S_AXI_RVALID<=1'b1;
        else if (S_AXI_RVALID && S_AXI_RREADY)  S_AXI_RVALID<=1'b0;
    end

    // --- CTRL -> loi Keccak (write_pulse la xung 1 chu ky) ---
    reg [31:0] data_hi, data_lo;
    reg core_iready, core_ilast; reg [2:0] core_ibyte;
    wire [63:0] sha3_iData = {data_hi, data_lo};
    wire [255:0] sha3_oData; wire sha3_oReady, sha3_buffer_full, sha3_ack;

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            data_hi<=0; data_lo<=0; core_iready<=0; core_ilast<=0; core_ibyte<=0;
        end else begin
            core_iready<=1'b0; core_ilast<=1'b0;
            if (write_pulse) begin
                case (awaddr_reg[7:0])
                    8'h00: data_hi <= wdata_reg;
                    8'h04: data_lo <= wdata_reg;
                    8'h08: begin core_iready<=wdata_reg[0]; core_ilast<=wdata_reg[1]; core_ibyte<=wdata_reg[4:2]; end
                endcase
            end
        end
    end

    Keccak #(.b(1600),.nr(24),.Length(4),.lbits(3)) my_sha3_core (
        .iClk(S_AXI_ACLK), .iRst(~S_AXI_ARESETN), .iData(sha3_iData),
        .iReady(core_iready), .iLast(core_ilast), .iByte_num(core_ibyte),
        .oBuffer_full(sha3_buffer_full), .f_oAck(sha3_ack),
        .oData(sha3_oData), .oReady(sha3_oReady));

    // --- FIX then chot: RDATA CHOT VAO THANH GHI khi ar_received ---
    reg [31:0] axi_rdata;
    assign S_AXI_RDATA = axi_rdata;
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) axi_rdata <= 32'h0;
        else if (ar_received) begin
            case (araddr_reg[7:0])
                8'h0C: axi_rdata <= {29'b0, sha3_ack, sha3_buffer_full, sha3_oReady};
                8'h10: axi_rdata <= sha3_oData[255:224];
                8'h14: axi_rdata <= sha3_oData[223:192];
                8'h18: axi_rdata <= sha3_oData[191:160];
                8'h1C: axi_rdata <= sha3_oData[159:128];
                8'h20: axi_rdata <= sha3_oData[127:96];
                8'h24: axi_rdata <= sha3_oData[95:64];
                8'h28: axi_rdata <= sha3_oData[63:32];
                8'h2C: axi_rdata <= sha3_oData[31:0];
                default: axi_rdata <= 32'h0;
            endcase
        end
    end
endmodule