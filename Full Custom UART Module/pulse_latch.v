`timescale 1ns/1ps 

module pulse_latch (
	input clk_i,
	input rst_i,
	input sig_i,
	output sig_o
);

	wire d1;
	wire d2;
	
	assign sig_o = d2;
	
	dff_async dff1(.d(1'b1),.clk(sig_i),.rst(rst_i),.q(d1));
	dff dff2(.d(d1),.clk(clk_i),.rst(rst_i),.q(d2));
	
endmodule

module dff (
	input d,
	input clk,
	input rst,
	output reg q
);
	
	always @(posedge clk) begin
		if(rst)
			q <= 0;
		else
			q <= d;
	end
	
endmodule

module dff_async (
	input d,
	input clk,
	input rst,
	output reg q
);
	
	always @(posedge clk or posedge rst) begin
		if(rst)
			q <= 0;
		else
			q <= d;
	end
	
endmodule