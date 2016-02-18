module WaveformGen (
	input				clk_i,		// Expecting 36 MHz
	input 			rst_i,
	input				output_en,
	output[11:0]	sin_out,
	output reg		dac_cs
);

	parameter pin_inc = 107374182;

	logic rst_n;
	assign rst_n = ~rst_i;

	logic gen_out_valid;
	logic [3:0] count;

	SinWaveGenerator u0 (
		.clk       (clk_i),       // clk.clk
		.reset_n   (rst_n),   // rst.reset_n
		.clken     (output_en),     //  in.clken
		.phi_inc_i (pin_inc), //    .phi_inc_i
		.fsin_o    (sin_out),    // out.fsin_o
		.out_valid (gen_out_valid)  //    .out_valid
	);
	
	initial begin
		count <= 0;
		dac_cs <= 1;
	end
	
	always_ff@(clk_i) begin
		if(count == 9) begin
			count <= 0;
			dac_cs <= 1;
		end
		else begin
			count <= count+1;
			dac_cs <= 0;
		end
	end
	
endmodule
