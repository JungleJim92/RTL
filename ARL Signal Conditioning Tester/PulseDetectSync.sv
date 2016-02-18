module PulseDetectSync (
	input					in_clk,
	input					in,
	input 				sync_clk,
	output				out
);
	
	// Constants
	// edge detection (control sigs may stay asserted more than one cycle)
	logic x[11:0];
	logic y;
	always_ff@(posedge in_clk) begin
		x[0] <= in;
		x[1] <= x[0];
		x[2] <= x[1];
		x[3] <= x[2];
		x[4] <= x[3];
		x[5] <= x[4];
		x[6] <= x[5];
		x[7] <= x[6];
		x[8] <= x[7];
		x[9] <= x[8];
		x[10] <= x[9];
		x[11] <= x[10];
	end
	assign y = (x[0] | x[1] | x[2] | x[3] | x[4] | x[5] | x[6] | x[7] | x[8] | x[9] | x[10]) & ~x[11];
	
	// edge detection (control sigs may stay asserted more than one cycle)
	logic z[1:0];
	always_ff@(posedge sync_clk) begin
		z[0] <= y;
		z[1] <= z[0];
	end
	assign out = z[0] & ~z[1];
	
	
endmodule
