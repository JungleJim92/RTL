`timescale 1ns/1ps

module shift_reg_rx_tb;
	reg clk_i;
	reg rst_i;
	reg sig_i;
	reg en;
	wire [7:0] q;
	
	shift_reg_rx the_instantiation ( 	.clk_i(clk_i),
										.rst_i(rst_i),
										.sig_i(sig_i),
										.en(en),
										.q(q)
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
	
// Reset Initialization
	initial begin
		rst_i <= 1;
		#50;
		rst_i <= 0;
	end
	
// Test Setup
	initial begin
		en <= 0;
		sig_i <= 1;
					
		wait(rst_i == 0);
		
		#10;
		en <= 1;
		#100;
		en <= 0;
		sig_i <= 0;
		#60;
		en <= 1;
		#60;
		en <= 0;
	end
	
endmodule
