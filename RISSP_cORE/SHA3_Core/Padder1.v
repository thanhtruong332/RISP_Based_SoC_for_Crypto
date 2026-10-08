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

module InEnd(
	input	[55:0]	in,
	input	[2:0]	byte_num,
	output	[63:0]	out
);
/*
 case (byte_num)
	0: out =             64'h0600000000000000;
	1: out = {in[63:56], 56'h06000000000000};
	2: out = {in[63:48], 48'h060000000000};
	3: out = {in[63:40], 40'h0600000000};
	4: out = {in[63:32], 32'h06000000};
	5: out = {in[63:24], 24'h060000};
	6: out = {in[63:16], 16'h0600};
	7: out = {in[63:8],   8'h06};
 endcase
*/

 assign out[63:56] = (byte_num == 3'd0) ? 8'h06 : in[55:48];
 assign out[55:48] = (byte_num < 3'd1)  ? 8'h00 :
					 (byte_num == 3'd1) ? 8'h06 : in[47:40];
 assign out[47:40] = (byte_num < 3'd2)  ? 8'h00 :
					 (byte_num == 3'd2) ? 8'h06 : in[39:32];
 assign out[39:32] = (byte_num < 3'd3)  ? 8'h00 :
					 (byte_num == 3'd3) ? 8'h06 : in[31:24];
 assign out[31:24] = (byte_num < 3'd4)  ? 8'h00 :
					 (byte_num == 3'd4) ? 8'h06 : in[23:16];
 assign out[23:16] = (byte_num < 3'd5)  ? 8'h00 :
					 (byte_num == 3'd5) ? 8'h06 : in[15:8];
 assign out[15:8]  = (byte_num < 3'd6)  ? 8'h00 :
					 (byte_num == 3'd6) ? 8'h06 : in[7:0];
 assign out[7:0]   = (byte_num < 3'd7)  ? 8'h00 : 8'h06;


endmodule
