`timescale 1 ns / 1 ps

module LEDController (
	input clk_i,
	
	output reg led_o
);

parameter qs_count = 9000000; //quarter second clock on 36 MHz

logic [31:0] count;

initial begin
	count <= 0;
	led_o <= 0;
end

// Transition to next state
always_ff @(posedge clk_i) begin
	if(count < qs_count) begin
		count <= count + 1;
	end
	else begin
		count <= 0;
		led_o <= !led_o;
	end
end

endmodule
