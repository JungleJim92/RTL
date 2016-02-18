`timescale 1ns/1ps

module serial_transmitter_tb;
	reg sspclkout;
	wire sspfssin;
	wire ssptxd;
	reg rst_i;
	reg data_valid;
	wire busy;
	reg [7:0] ssptxout;
	
	serial_transmitter the_instantiation ( 	.sspclkout(sspclkout),
											.sspfssin(sspfssin),
											.ssptxd(ssptxd),
											.rst_i(rst_i),
											.data_valid(data_valid),
											.busy(busy),
											.ssptxout(ssptxout)
											);
	
// Clock Initialization
	initial begin
		sspclkout = 0;
		#10;
		forever begin
			sspclkout <= !sspclkout;
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
		data_valid <= 0;
		ssptxout <= 8'h88;
		
		wait(rst_i == 0);
		
		#30
		data_valid <= 1;
		#20
		data_valid <= 0;
	end
	
endmodule
