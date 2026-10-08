`timescale 1ns / 1ps

module KeyExpansionRound (
    input [3:0]    round_count,
    input [127:0]  key_in,
    output [127:0] key_out
);
    genvar i;
    wire [31:0] words [3:0];
    
    // ORIGINAL CODE - Đúng cho Big-Endian
    generate
        for (i = 0; i < 4; i = i + 1) begin: KeySplitLoop
            assign words[i] = key_in[127 - i * 32 -: 32];
        end
    endgenerate
    
    // words[0] = key_in[127:96] = W0 (MSB)
    // words[1] = key_in[95:64]  = W1
    // words[2] = key_in[63:32]  = W2
    // words[3] = key_in[31:0]   = W3 (LSB)
    
    wire [31:0] w3_rot = {words[3][23:0], words[3][31:24]};
    
    wire [31:0] w3_sub;
    generate 
        for (i = 0; i < 4; i = i + 1) begin: SubWordLoop
            SubTable subtable_inst (
                .data_in(w3_rot[8 * i +: 8]),
                .data_out(w3_sub[8 * i +: 8])
            );
        end
    endgenerate
    
    wire [7:0] rcon_byte = round_count == 1  ? 8'h01 :
                           round_count == 2  ? 8'h02 :
                           round_count == 3  ? 8'h04 :
                           round_count == 4  ? 8'h08 :
                           round_count == 5  ? 8'h10 :
                           round_count == 6  ? 8'h20 :
                           round_count == 7  ? 8'h40 :
                           round_count == 8  ? 8'h80 :
                           round_count == 9  ? 8'h1b :
                           round_count == 10 ? 8'h36 : 8'h00;
    
    wire [31:0] rcon = {rcon_byte, 24'h000000};
    
    // ORIGINAL OUTPUT - Đúng cho Big-Endian
    assign key_out[127:96] = words[0] ^ w3_sub ^ rcon;
    assign key_out[95:64]  = words[1] ^ key_out[127:96];
    assign key_out[63:32]  = words[2] ^ key_out[95:64];
    assign key_out[31:0]   = words[3] ^ key_out[63:32];
    
endmodule

module KeyExpansion (
    input  wire          clk,
    input  wire          rst_n,
    input  wire [127:0]  key_in,
    output wire [1407:0] keys_out,
    output reg           keys_valid   // 1 khi ca 11 round key da on dinh
);

    localparam Nr = 10;

    // PIPELINE: moi round key la 1 thanh ghi rieng (round_key[0]=key goc,
    // round_key[1..10]=round key 1..10), giua 2 tang chi co DUNG 1
    // KeyExpansionRound to hop (thay vi ca chuoi 10 tang to hop lien tuc
    // nhu ban cu) -> cat critical path key_reg->expanded_keys tu 42 logic
    // level (~30ns) xuong con ~1 tang (~vai ns), doi lay 10 chu ky de
    // pipeline day (round_key[10] hop le tu chu ky thu 10 sau khi key_in
    // on dinh). keys_valid bao hieu thoi diem do de AESEncrypt cho dung
    // luc moi bat dau dung all_keys (xem start_req trong AESEncrypt.v).
    reg [127:0] round_key [0:Nr];

    reg [127:0] key_in_d;
    reg [3:0]   fill_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key_in_d   <= 128'd0;
            fill_cnt   <= 4'd0;
            keys_valid <= 1'b0;
        end else begin
            key_in_d <= key_in;
            if (key_in != key_in_d) begin
                fill_cnt   <= 4'd0;
                keys_valid <= 1'b0;
            end else if (fill_cnt < Nr[3:0]) begin
                fill_cnt <= fill_cnt + 4'd1;
                if (fill_cnt + 4'd1 == Nr[3:0]) keys_valid <= 1'b1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) round_key[0] <= 128'd0;
        else        round_key[0] <= key_in;
    end

    genvar i;
    generate
        for (i = 0; i < Nr; i = i + 1) begin: KeyExpansionRoundLoop
            wire [127:0] next_round_key;

            KeyExpansionRound keyexp_round (
                .round_count(i[3:0] + 4'b0001),
                .key_in(round_key[i]),
                .key_out(next_round_key)
            );

            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) round_key[i + 1] <= 128'd0;
                else        round_key[i + 1] <= next_round_key;
            end
        end
    endgenerate

    genvar k;
    generate
        for (k = 0; k <= Nr; k = k + 1) begin: PackLoop
            assign keys_out[k * 128 +: 128] = round_key[k];
        end
    endgenerate

endmodule