`timescale 1ns/1ps

module fifo_4_tb;
	reg clk_i;
	reg rst_i;
	reg write;
	reg read;
	reg [7:0] write_d;
	wire [7:0] read_d;
	wire empty;
	wire full;
	
	fifo_4 the_instantiation ( 	.clk_i(clk_i),
								.rst_i(rst_i),
								.write(write),
								.read(read),
								.write_d(write_d),
								.read_d(read_d),
								.empty(empty),
								.full(full)
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
		write <= 0;
		write_d <= 8'hA5;
					
		wait(rst_i == 0);
		
		#10;
		write <= 1;
		write_d <= 8'h11;
		#20;
		write <= 0;
		#20;
		write <= 1;
		write_d <= 8'h22;
		#20;
		write <= 0;
		#20;
		write <= 1;
		write_d <= 8'h33;
		#20;
		write <= 0;
		#20;
		write <= 1;
		write_d <= 8'h44;
		#20;
		write <= 0;
		#20;
		write <= 1;
		write_d <= 8'h55;
		#20;
		write <= 0;
		
		#20;
		read <= 1;
		#20;
		read <= 0;
		#20;
		read <= 1;
		#20;
		read <= 0;
		#20;
		read <= 1;
		#20;
		read <= 0;
		#20;
		read <= 1;
		#20;
		read <= 0;
		#20;
		read <= 1;
	end
	
endmodule
