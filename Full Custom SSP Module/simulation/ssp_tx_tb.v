`timescale 1ns/1ps

module ssp_tx_tb;
	reg clk_i;
	reg rst_i;
	reg do_write;
	reg [7:0] tx_d;
	wire tx_full;
	reg sspclkout;
	wire sspfssout;
	wire ssptxd;
	
	ssp_tx the_instantiation( 	.clk_i(clk_i),
								.rst_i(rst_i),
								.do_write(do_write),
								.tx_d(tx_d),
								.tx_full(tx_full),
								.sspclkout(sspclkout),
								.sspfssout(sspfssout),
								.ssptxd(ssptxd)
								);
	
// Clock Initialization
	initial begin
		clk_i = 0;
		#10;
		forever begin
			clk_i <= !clk_i;
			#10;
		end
	end
	
// SSP Clock Initialization
	initial begin
		sspclkout = 0;
		#20;
		forever begin
			sspclkout <= !sspclkout;
			#20;
		end
	end
	
// Reset Initialization
	initial begin
		rst_i <= 1;
		#50;
		rst_i <= 0;
	end
	
// Test Setup
	initial begin
		do_write <= 0;
		tx_d <= 8'h55;
		
		wait(rst_i == 0);
			
		#30
		do_write <= 1;
		#20
		do_write <= 0;
		
		//forever begin
			//#100
			//wait(tx_full == 0);
			
			//#20
			//do_write <= 1;
			//#20
			//do_write <= 0;
		//end
	end
	
endmodule
