`timescale 1ns/1ps

module ssp_rx_tb;
	reg clk_i;
	reg rst_i;
	reg do_read;
	wire [7:0] rx_d;
	wire rx_full;
	reg sspclkin;
	reg sspfssin;
	reg ssprxd;
	
	ssp_rx the_instantiation ( 	.clk_i(clk_i),
								.rst_i(rst_i),
								.do_read(do_read),
								.rx_d(rx_d),
								.rx_full(rx_full),
								.sspclkin(sspclkin),
								.sspfssin(sspfssin),
								.ssprxd(ssprxd)
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
		sspclkin = 0;
		#20;
		forever begin
			sspclkin <= !sspclkin;
			#20;
		end
	end
	
// Reset Initialization
	initial begin
		rst_i <= 1;
		#50;
		rst_i <= 0;
	end
	
// Serial Stream Setup
	reg [3:0] t_count;
	initial begin
		sspfssin <= 0;
		ssprxd <= 0;
		t_count <= 0;
		
		wait(rst_i == 0);
		
		forever begin
			#40
			t_count <= t_count + 1;
			sspfssin <= t_count == 0;
			ssprxd <= t_count[2];
		end
	end
	
// Test Setup
	initial begin
		do_read <= 0;
		
		wait(rst_i == 0);
		
		forever begin
			#400
			do_read <= 1;
			#20
			do_read <= 0;
		end
	end
	
endmodule
