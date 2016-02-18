`timescale 1 ns / 1 ps

module PingController (
	input clk_i,
	input rst_i,
	input ping_i,
	input [31:0] scans_i,
	
	output [31:0] ping_dbg,
	output reg ping_o,
	output reg convert_o
);

	parameter ms1 = 108000; //108000 counts = 1ms on 108m clock

	logic[31:0] ping_count;
	logic[31:0] convert_count;
	logic[4:0] do_convert_count;
	logic [31:0] scans;

	logic [31:0] ping_dbg_temp;
	assign ping_dbg_temp = 	{ 	clk_i,					// 1
										rst_i,					// 2
										ping_i,					// 3
										ping_o,					// 4
										convert_o,				// 5
										do_convert_count,		// 10
										scans_i[15:0],			// 26
										6'b000000				// 32
										};
									
	genvar i;
	generate
		for( i=0; i<32; i=i+1 ) begin : reverse
			assign ping_dbg[i] = ping_dbg_temp[31-i];
		end
	endgenerate
	
	logic ping_d;
	logic clr_regs;
	input_register in_reg_3(.clk_i(clk_i),.data_i(ping_i),.clr_i(clr_regs),.data_o(ping_d));

	enum int unsigned {
		reset,
		hold,
		transition1,
		ping,
		transition2,
		ping_wait,
		transition3,
		convert,
		transition4
	} s_current, s_next;

	initial begin
		ping_count <= 0;
		convert_count <= 0;
		do_convert_count <= 0;
		clr_regs <= 0;
		
		ping_o <= 0;
		convert_o <= 0;
	end

	// Transition to next state
	always_ff @(posedge clk_i) begin
		if(rst_i)
			s_current <= reset;
		else
			s_current <= s_next;
	end

	// Next state combo logic
	always_comb begin
		case(s_current)
			reset:
				s_next = hold;
			hold:
				if(ping_d)
					s_next = transition1;
				else
					s_next = hold;
			transition1:
				s_next = ping;
			ping:
				if(ping_count >= ms1 * 50) // 50ms
					s_next = transition2;
				else
					s_next = ping;
			transition2:
				s_next = ping_wait;
			ping_wait:
				if(ping_count >= 5 * 30) // 5 3.6Mhz cycles
					s_next = transition3;
				else
					s_next = ping_wait;
			transition3:
				s_next = convert;
			convert:
				if(convert_count >= (scans * 40))
					s_next = transition4;
				else
					s_next = convert;
			transition4:
				s_next = hold;
		endcase
	end

	// Outputs and counters adjusted for each state
	always_ff @(posedge clk_i) begin
		if (rst_i) begin
			ping_count <= 0;
			convert_count <= 0;
			do_convert_count <= 0;
			scans <= 0;
			clr_regs <= 0;
			
			ping_o <= 0;
			convert_o <= 0;
		end
		else begin
			ping_count <= ping_count;
			convert_count <= convert_count;
			do_convert_count <= do_convert_count;
			scans <= scans;
			clr_regs <= clr_regs;
			
			ping_o <= ping_o;
			convert_o <= convert_o;
			case(s_current)
				reset: begin
					ping_count <= 0;
					convert_count <= 0;
					do_convert_count <= 0;
					scans <= 0;
					clr_regs <= 1;
					
					ping_o <= 0;
					convert_o <= 0;
				end
				
				hold: begin
					clr_regs <= 0;
					
					ping_o <= 0;
					convert_o <= 0;
				end
				
				transition1: begin
					ping_count <= 0;
					ping_o <= 0;
					convert_o <= 0;
					scans <= scans_i + 1;
					clr_regs <= 1;
				end
				
				ping: begin
					ping_count <= ping_count + 1;
					ping_o <= 1;
					convert_o <= 0;
				end
				
				transition2: begin
					ping_count <= 0;
					ping_o <= 0;
					convert_o <= 0;
				end
				
				ping_wait: begin
					ping_count <= ping_count + 1;
					ping_o <= 0;
					convert_o <= 0;
				end
				
				transition3: begin
					convert_count <= 0;
					do_convert_count <= 0;
					ping_o <= 0;
					convert_o <= 0;
				end
				
				convert: begin
					if(do_convert_count < 3) begin
						do_convert_count <= do_convert_count + 1;
						convert_o <= 1;
					end
					else if(do_convert_count < 29) begin
						do_convert_count <= do_convert_count + 1;
						convert_o <= 0;
					end
					else begin
						do_convert_count <= 0;
						convert_count <= convert_count + 1;
						convert_o <= 0;
					end
				end
				
				transition4: begin
					clr_regs <= 1;
					
					ping_o <= 0;
					convert_o <= 0;
				end
			endcase
		end
	end

endmodule
