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
  reg clk;	        // System clk (assumed to be 50 MHz)
  reg rst;	        // Synchronous reset
  reg tx_en;
  reg [7:0]tx_data_in;	// TX data in from processor
  
  wire tx;	        // TX data signal

initial begin
  clk = 0;
  rst = 0;
  tx_en = 0;
  @(posedge clk);
  @(posedge clk);
  rst = 1;
  tx_en = 1;
  tx_data_in = 8'b01010101; // 8'h55
  @(posedge clk);
  tx_data_in = 8'b11110000; // 8'hF0
	
  
end

always #10 clk <= !clk;

//	TX Module
txlogic TXLOGIC1(clk, rst, tx_en, tx_data_in, tx);


endmodule
