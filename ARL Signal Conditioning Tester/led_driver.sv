`timescale 1 ns / 1 ps

module led_driver (
	input clk_i,
	input reset_i,
	input signal_i,
	
	output reg led_output_blink_o,
	output reg led_output_o
);

logic signal_s;
logic led_output_s;
logic led_output_blink_s;
logic [31:0] counter;
logic go_signal;

edge_detect_sync edge_detect_sync_inst
	(
		.in(signal_s),
		.sync_clk(clk_i),
		.rise1_fall0(1'b1),
		.out(go_signal)
	);
	
always_ff @(posedge clk_i)
begin
	signal_s <= signal_i;
	led_output_blink_o <= led_output_blink_s;
	led_output_o <= ~signal_i; // simply register and invert the signal (assuming positive logic in - leds require negative logic to turn on)
end

enum int unsigned {
	reset_state,
	wait_for_rising_edge,
	make_led_on
	} led_sm, led_sm_next;
	
// State machine clock transitions	
always_ff @(posedge clk_i)
	if (reset_i) 
		led_sm <= reset_state;
	else
		led_sm <= led_sm_next;	

always_comb begin
	case (led_sm)
		reset_state:
			led_sm_next = wait_for_rising_edge;		
		wait_for_rising_edge:
			if(go_signal)
				led_sm_next = make_led_on;
			else
				led_sm_next = wait_for_rising_edge;
		make_led_on:
			if (counter >= 21600000) // 200 ms at 108 MHz
				led_sm_next = reset_state;
			else
				led_sm_next = make_led_on;
	endcase
end	
		
// Do outputs based on state		
always_ff @(posedge clk_i) begin
	if (reset_i) begin
		led_output_blink_s <= 1'b1;
		counter <= 0;
	end
	else begin
		led_output_blink_s <= 1'b1;
		counter <= 0;	
		case (led_sm_next)
			reset_state: 
				begin	
					counter <= 0;
				end
			wait_for_rising_edge: 
				begin
					counter <= 0;
				end
			make_led_on:
				begin
					led_output_blink_s <= 1'b0;
					counter <= counter + 1;
				end
		endcase
	end
end			
		
endmodule
		

	