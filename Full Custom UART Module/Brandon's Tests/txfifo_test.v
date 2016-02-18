// txtest.v
// Brandon Boesch
// Josh Randall
// James Schulman

// EE 382M.7 - VLSI1
// Nov 28th, 2015

//-----------------------------------------------------
// Top Level UART Module
//-----------------------------------------------------
// Functionality:
// This module will make the interconnects between TX,
// RX, and baud modules. It will also control the
// interface to external processor to read/transmit
// bytes and control the reset interconnects.

module txtest;
  reg sys_clk;	        // System clk (assumed to be 50 MHz)
  reg tx_clk;
  reg rst;	        // Synchronous reset
  reg ld_tx_fifo;
  reg [7:0]fifo_data_in; // TX data in from processor
  
  wire tx;	        // TX data signal
  wire [7:0]fifo_data_out;
  wire full;
  wire data_valid;
  wire transmitting;

initial begin
  sys_clk = 0;
  tx_clk = 0;
  rst = 0;
  ld_tx_fifo = 0;
  @(posedge sys_clk);
  @(posedge sys_clk);
  rst = 1;
  ld_tx_fifo = 1;
  fifo_data_in = 8'b01010101; // 8'h55
  @(posedge sys_clk);
  fifo_data_in = 8'b11110000; // 8'hF0
  @(posedge sys_clk);
  fifo_data_in = 8'b00001111; // 8'h0F
  @(posedge sys_clk);
  fifo_data_in = 8'b10101010; // 8'hAA
  @(posedge sys_clk);
  fifo_data_in = 8'b01010101; // 8'h55
  @(posedge sys_clk);
  ld_tx_fifo = 0;



end

always #10 sys_clk <= !sys_clk;
always #100 tx_clk <= !tx_clk;

//	TX Module
txlogic TXLOGIC1(tx_clk, rst, fifo_data_out, data_valid, transmitting, tx);
txfifo TXFIFO1(sys_clk, rst, fifo_data_in, ld_tx_fifo, transmitting, fifo_data_out, data_valid, full); 

endmodule
