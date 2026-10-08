`timescale 1ns / 1ps

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

module Padder #(
	//default KECCAK-p[1600, 24], SHA3 - 512
	parameter b  = 1600,
    parameter Length = 8,
	parameter Block  = b/64 - 2*Length,
    parameter lbits = 3
)
(
    input				        iClk,
	input				        iRst,
    input		[63:0]	        iData,
    input				        iReady,
	input				        iLast,
    input		[lbits-1:0]     iByte_num,
    output				        oBuffer_full,	/* to "user" module */
    output		[1087:0]        oData,		    /* to "f_permutation" module */
    output				        oReady,			/* to "f_permutation" module */
    input				        iF_ack		  	/* from "f_permutation" module */
);

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
 reg [1087:0]  oData_reg;
 assign oData = oData_reg;
 
 reg			state;		/* state == 0: user will send more input data
							 * state == 1: user will not send any data */
 reg			done;		/* == 1: oReady should be 0 */
 reg	[16:0]	i;			/* length of "oData" buffer */
 wire	[63:0]	v0;			/* output of module "padder1" */
 wire	[63:0]	v1;			/* to be shifted into register "oData" */
 //wire			accept;		/* accept user input? */
 wire			update;

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
 
 assign oBuffer_full = i[16];
 assign oReady = oBuffer_full;
 
 // if state == 1, do not eat input
 //assign accept = ~state & iReady & ~oBuffer_full;
 // don't fill buffer if done
 assign update = (iReady|state) & ~(oBuffer_full|done);
 
// assign v1 = (state) ? {56'b0, i[7], 7'b0} :
//			 (~iLast) ? iData : {v0[63:8], v0[7]|i[7], v0[6:0]};
 assign v1[63:8] = {(56){~state}} & ((~iLast) ? iData[63:8] : v0[63:8]);
 assign v1[7] = (state) ? 
                i[15]: 
                ((~iLast) ? iData[7] : (v0[7]| i[15])); //0x80 (1)000_0000 khi iLast hoặc khi đủ Block_pad
                
 assign v1[6:0] = {(7){~state}} & ((~iLast) ? iData[6:0] : v0[6:0]);
			 
/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
 
 always@(posedge iClk) begin
	if(update)	oData_reg <= {oData_reg[16*64-1:0], v1};
	else		oData_reg <= oData_reg;
 end
 
 // if (iF_ack)  i <= 0;
 // if (update) i <= {i[7:0], 1'b1};	/* increase length */
 always@(posedge iClk) begin
	if(iRst)				i <= 0;
	else if(iF_ack|update)	i <= {i[15:0], 1'b1} & {17{~iF_ack}};
	else					i <= i;
 end
 
 always@(posedge iClk) begin
	if(iRst)		state <= 1'b0;
	else if(iLast)	state <= 1'b1;
	else			state <= state;
 end
 
 always@(posedge iClk) begin
	if(iRst)				done <= 1'b0;
	else if(state&oReady)	done <= 1'b1;
	else					done <= done;
 end
 
/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
 
 InEnd p0 (
	.in			(iData[63:8]),
	.byte_num	(iByte_num),
	.out		(v0)
 );
 
endmodule
