// top.v
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

module uart (
	input			clk_i,			// System clk (assumed to be 50 MHz)
	input			rst_i,			// Asynchronous reset
	input [2:0]		baud_rate_i,	// Baud rate selection
	input			ld_tx_data,		// Load next byte into TX FIFO (tx_data must be valid during same clk period)
	input [7:0]		tx_data,		// TX data in from processor
	output			tx_d,			// TX data signal
	output			tx_full,		// TX FIFO full
	input			ld_rx_data,		// Read next byte from RX FIFO (rx_data will be valid during next clk period)
	output [7:0]	rx_data,		// RX data out to processor
	input			rx_d,			// RX data signal
	output			rx_empty		// RX FIFO empty
);

	wire tx_clk;
	wire rx_clk;

//	Baud Module
	baud b1 (	.clk_in(clk_i),
				.rst(rst_i),
				.baud_sel(baud_rate_i),
				.tx_clk(tx_clk),
				.rx_clk(rx_clk)
				);

//	TX Module
	wire [7:0]	t_fifo_d;
	wire		t_fifo_valid;
	wire		t_busy;
	
	txfifo tf (	.clk(clk_i),
				.rst(rst_i),
				.data_in(tx_data),
				.ld_tx_fifo(ld_tx_data),
				.transmitting(t_busy),
				.data_out(t_fifo_d),
				.data_valid(t_fifo_valid),
				.full(tx_full)
				);
				
	txlogic t1 (	.clk(tx_clk),
					.rst(rst_i),
					.data_in(t_fifo_d),
					.data_valid(t_fifo_valid),
					.tx(tx_d),
					.transmitting(t_busy)
					);

//	RX Module
	rx r1 (	.rst(rst_i),
			.sys_clk(clk_i),
			.rx_clk(rx_clk),
			.rx_data_in(rx_d),
			.rx_data_out(rx_data),
			.rx_en(1'b1),
			.rx_empty(rx_empty),
			.rx_req(ld_rx_data)
			);

endmodule
