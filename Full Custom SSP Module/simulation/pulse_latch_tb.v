`timescale 1ns/1ps 

module pulse_latch_tb;
	reg clk_i;
	reg rst_i;
	reg sig_i;
	wire sig_o;
	
	pulse_latch the_instantiation ( .clk_i(clk_i), .rst_i(rst_i), .sig_i(sig_i), .sig_o(sig_o) );
	
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
		sig_i <= 0;
					
		wait(rst_i == 0);
		
		#20;
		sig_i <= 1;
		#5
		sig_i <= 0;
		#100
		rst_i <= 1;
		#20
		rst_i <= 0;
		#45
		sig_i <= 1;
		#5
		sig_i <= 0;
		#20
		rst_i <= 1;
		#20
		rst_i <= 0;
		#45
		sig_i <= 1;
		#5
		sig_i <= 0;
	end
	
endmodule
