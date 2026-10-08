/*
 * Copyright 2013, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* "iLast" == 0 means byte number is 8, no matter what value "iByte_num" is. */
/* if "iReady" == 0, then "iLast" should be 0. */
/* the user switch to next "iData" only if "ack" == 1. */

module Keccak #(
	/* Standard KECCAK-p[b, nr] 
	b : Bits of permutation 
	nr: Number of round in permutation 
	using KECCAK-p[1600, 24] */
	parameter b  = 1600,
	parameter nr  = 24,
    parameter Length = 4, 	// SHA3 - 128, 256, 512 (2, 4, 8 * 64 bit)
	parameter Block  = b/64 - 2*Length,
    parameter lbits = 3 	// KECCAK-p[1600, 24] => l = 6 Lenght of iData Bytes
)
(
	input				   	iClk,
	input				   	iRst,
	input	[63:0]	      	iData,
	input				   	iReady,
	input				   	iLast,
	input	[lbits-1:0]		iByte_num,
	output				   	oBuffer_full, /* to "user" module */
	output				   	f_oAck, /* to "user" module */
	output	[Length*64-1:0]	oData,
//	output	[1*64-1:0]	oData_2,
	output	reg				oReady
);
	
/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// wire [Length*64-1:0]	oData;
// assign oData_2 = oData[63:0];
 reg						state;	/* state == 0: user will send more input data
									 * state == 1: user will not send any data */
 reg	[22:0]				i; 		/* gen "oReady" */
 
 wire	[Block*64-1:0]	    padder_oData, padder_oData_pre; /* before reorder byte */
 wire						padder_oReady;
 
// wire						f_oAck, Padder_full;
// assign Padder_full = oBuffer_full & f_oAck;
 wire	[Length*64-1:0]		f_oData;
 wire			f_oReady;
 
 wire	[Length*64-1:0]		Data_out_pre; /* before reorder byte */
 wire	[63:0]				Data_out_pre_ 	  [0:Length-1];
 wire	[63:0]				Data_out_		  [0:Length-1];

// wire	[63:0]				padder_oData_pre_ [0:Block-1];
// wire	[63:0]				padder_oData_	  [0:Block-1];
 
/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
 
 /* reorder byte ~ ~ */
 assign Data_out_pre = f_oData;
 
 genvar ibyte, jbit;
// generate
// 	for (ibyte = 0; ibyte < Length; ibyte = ibyte + 1) begin : unpack_Data_out_pre
// 		assign Data_out_pre_[ibyte] = Data_out_pre[ibyte*64 +: 64];
// 	end
// endgenerate

// generate
// 	for (ibyte = 0; ibyte < Length; ibyte = ibyte + 1) begin : pack_Data_out_
//		for (jbit = 0; jbit < 8; jbit = jbit + 1) begin : reverse_Data_out_pre_
//			assign Data_out_[ibyte][(jbit+1)*8-1 : jbit*8] = Data_out_pre_[ibyte][(8-jbit)*8-1 : (7-jbit)*8];
//		end
//		assign oData[ibyte*64 +: 64] = Data_out_[ibyte];
// 	end
// endgenerate
 generate
  for (ibyte = 0; ibyte < Length; ibyte = ibyte + 1) begin : reverse_bytes
    assign oData[ibyte*64 +: 64] = {
        Data_out_pre[ibyte*64 +: 8],          // byte 0 -> th nh byte 7
        Data_out_pre[ibyte*64+8 +: 8],
        Data_out_pre[ibyte*64+16 +: 8],
        Data_out_pre[ibyte*64+24 +: 8],
        Data_out_pre[ibyte*64+32 +: 8],
        Data_out_pre[ibyte*64+40 +: 8],
        Data_out_pre[ibyte*64+48 +: 8],
        Data_out_pre[ibyte*64+56 +: 8]        // byte 7 -> th nh byte 0
    };
  end
endgenerate
//genvar ibyte;
generate
  for (ibyte = 0; ibyte < Block; ibyte = ibyte + 1) begin : reverse_bytes_per
    assign padder_oData[ibyte*64 +: 64] = {
        padder_oData_pre[ibyte*64 +: 8],          // byte 0 -> th nh byte 7
        padder_oData_pre[ibyte*64+8 +: 8],
        padder_oData_pre[ibyte*64+16 +: 8],
        padder_oData_pre[ibyte*64+24 +: 8],
        padder_oData_pre[ibyte*64+32 +: 8],
        padder_oData_pre[ibyte*64+40 +: 8],
        padder_oData_pre[ibyte*64+48 +: 8],
        padder_oData_pre[ibyte*64+56 +: 8]        // byte 7 -> th nh byte 0
    };
  end
endgenerate


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
 
 always@(posedge iClk) begin
	if(iRst)	i <= 23'b0;
	else		i <= {i[21:0], state & f_oAck};
 end

 always@(posedge iClk) begin
	if(iRst)		state <= 1'b0;
	else if(iLast)	state <= 1'b1;
	else			state <= state;
 end

 always@(posedge iClk) begin
	if(iRst)		oReady <= 1'b0;
	else if(i[22])	oReady <= 1'b1;
	else			oReady <= oReady;
 end
 
/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
 
 Padder #(
	.b(b),
	.Length(Length),
	.Block(Block),
	.lbits(lbits)
 ) padder_ (
	.iClk			(iClk),
	.iRst			(iRst),
	.iData			(iData),
	.iReady			(iReady),
	.iLast			(iLast),
	.iByte_num		(iByte_num),
	.oBuffer_full	(oBuffer_full),
	.oData			(padder_oData_pre),
	.oReady			(padder_oReady),
	.iF_ack			(f_oAck)
 );

 F_permutation #(
	.b(b),
	.nr(nr),
	.Length(Length),
	.Block(Block)
 ) f_permutation_ (
	.iClk		(iClk),
	.iRst		(iRst),
	.iData		(padder_oData),
	.iReady		(padder_oReady),
	.oAck		(f_oAck),
	.oData		(f_oData),
	.oReady	    (f_oReady)
 );

endmodule
