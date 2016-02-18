`timescale 1ns/1ps

module SSP (
//	Processor Interface
	input PCLK,
	input PSEL,
	input PWRITE,
	input CLEAR_B,
	input [7:0] PWDATA,
	output [7:0] PRDATA,
	output SSPTXINTR,
	output SSPRXINTR,
//	SSP Interface
	output SSPOE_B,
	output SSPTXD,
	output SSPFSSOUT,
	output reg SSPCLKOUT,
	input SSPCLKIN,
	input SSPFSSIN,
	input SSPRXD
);

	always @(negedge CLEAR_B) begin
		SSPCLKOUT <= 1;
	end

	always @(posedge PCLK) begin
		if(CLEAR_B)
			SSPCLKOUT <= !SSPCLKOUT;
	end
		
	wire do_write;
	wire do_read;
	
	assign do_write = PSEL && PWRITE;
	assign do_read = PSEL && (!PWRITE);

	ssp_tx tx_module (	.clk_i(PCLK),
						.rst_i(!CLEAR_B),
						.do_write(do_write),
						.tx_d(PWDATA),
						.tx_full(SSPTXINTR),
						.sspclkout(SSPCLKOUT),
						.sspfssout(SSPFSSOUT),
						.ssptxd(SSPTXD),
						.sspoe(SSPOE_B)
						);
						
	ssp_rx rx_module (	.clk_i(PCLK),
						.rst_i(!CLEAR_B),
						.do_read(do_read),
						.rx_d(PRDATA),
						.rx_full(SSPRXINTR),
						.sspclkin(SSPCLKIN),
						.sspfssin(SSPFSSIN),
						.ssprxd(SSPRXD)
						);

endmodule
