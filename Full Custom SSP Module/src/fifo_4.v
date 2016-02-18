`timescale 1ns/1ps 

module fifo_4 (
	input clk_i,
	input rst_i,
	input write,
	input read,
	input [7:0] write_d,
	output reg [7:0] read_d,
	output empty,
	output full
);

	reg [7:0] d [3:0];
	reg [2:0] size;
	
	assign full = size >= 4;
	assign empty = size == 0;
	
	always @(posedge clk_i) begin
		if((size > 4) || (rst_i)) begin
			size <= 0;
			read_d <= 0;
		end
		else if(write & read) begin
			case(size)
				0: begin
					read_d <= write_d;
				end
				
				1: begin
					read_d <= d[0];
					d[0] <= write_d;
				end
				
				2: begin
					read_d <= d[0];
					d[0] <= d[1];
					d[1] <= write_d;
				end
				
				3: begin
					read_d <= d[0];
					d[0] <= d[1];
					d[1] <= d[2];
					d[2] <= write_d;
				end
				
				default: begin
					read_d <= d[0];
					d[0] <= d[1];
					d[1] <= d[2];
					d[2] <= d[3];
					d[3] <= write_d;
					size <= 4;
				end
			endcase
		end
		else if(write & !full) begin
			size <= size + 1;
			d[size[1:0]] <= write_d;
		end
		else if(read & !empty) begin
			size <= size - 1;
			read_d <= d[0];
			d[0] <= d[1];
			d[1] <= d[2];
			d[2] <= d[3];
			d[3] <= 0;
		end
	end
	
endmodule
