//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
//Date        : Mon Aug 17 12:23:36 2026
//Host        : thanhtruong running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (UART_0_rxd,
    UART_0_txd,
    clk_in1_0,
    reset_0);
  input UART_0_rxd;
  output UART_0_txd;
  input clk_in1_0;
  input reset_0;

  wire UART_0_rxd;
  wire UART_0_txd;
  wire clk_in1_0;
  wire reset_0;

  design_1 design_1_i
       (.UART_0_rxd(UART_0_rxd),
        .UART_0_txd(UART_0_txd),
        .clk_in1_0(clk_in1_0),
        .reset_0(reset_0));
endmodule
