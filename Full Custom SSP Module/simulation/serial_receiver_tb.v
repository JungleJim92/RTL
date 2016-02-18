`timescale 1ns/1ps

module serial_receiver_tb;
	reg sspclkin;
	reg sspfssin;
	reg ssprxd;
	reg rst_i;
	reg rd_ack;
	wire [7:0] ssprxout;
	wire valid_data;
	
	serial_receiver the_instantiation ( 	.sspclkin(sspclkin),
											.sspfssin(sspfssin),
											.ssprxd(ssprxd),
											.rst_i(rst_i),
											.rd_ack(rd_ack),
											.ssprxout(ssprxout),
											.valid_data(valid_data)
											);
	
// Clock Initialization
	initial begin
		sspclkin = 0;
		#10;
		forever begin
			sspclkin <= !sspclkin;
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
		sspfssin <= 0;
		ssprxd <= 0;
		rd_ack <= 0;
		
		wait(rst_i == 0);
		
		#40
		sspfssin <= 1;
		#20
		sspfssin <= 0;
		ssprxd <= 1;
		#40
		ssprxd <= 0;
		#40
		ssprxd <= 1;
		#40
		ssprxd <= 1;
		
		#100
		rd_ack <= 1;
		#20
		rd_ack <= 0;
	end
	
endmodule
