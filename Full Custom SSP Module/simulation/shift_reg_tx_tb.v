`timescale 1ns/1ps

module shift_reg_tx_tb;
	reg clk_i;
	reg rst_i;
	reg [7:0] d_in;
	reg ld;
	reg shift;
	wire q;
	
	shift_reg_tx the_instantiation ( 	.clk_i(clk_i),
										.rst_i(rst_i),
										.d_in(d_in),
										.ld(ld),
										.shift(shift),
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
		d_in <= 0;
		ld <= 0;
		shift <= 0;
					
		wait(rst_i == 0);
		
		#20
		d_in <= 8'h5A;
		ld <= 1;
		#20
		ld <= 0;
		#100
		shift <= 1;
		#60
		shift <= 0;
		#100
		shift <= 1;
		#100
		shift <= 0;
		#100
		ld <= 1;
		#20
		ld <= 0;
		#20
		shift <= 1;
	end
	
endmodule
