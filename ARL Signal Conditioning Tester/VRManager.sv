module VRManager(
	input clk_i,		// Assumed to be 10 MHz
	input rst_i,
	input chip_en,
	input [7:0] r1_i,
	input [7:0] r2_i,
	output reg shdn_n,
	output reg cs_n,
	output reg sdi,
	output clk
);
	
	logic [3:0] count;
	
	logic [9:0] r1;
	logic [9:0] r2;
	
	assign clk = clk_i;
	
	assign r1 = {2'b00,r1_i};
	assign r2 = {2'b01,r2_i};

	initial begin
		shdn_n <= 1;
		cs_n <= 1;
		sdi <= 0;
		
		count <= 0;
	end
	
	enum int unsigned {
		reset,
		transition_1,
		init_1,
		transition_2,
		init_2,
		hold,
		disable_device
	} sCurr, sNext;
	
	always_ff @(negedge clk_i) begin
		if(rst_i)
			sCurr <= reset;
		else if(chip_en == 0)
			sCurr <= disable_device;
		else
			sCurr <= sNext;
	end
	
	always_ff @(negedge clk_i) begin
		if(rst_i) begin
			shdn_n <= 1;
			cs_n <= 1;
			sdi <= 0;
			
			count <= 0;
		end
		else begin
			shdn_n <= shdn_n;
			cs_n <= cs_n;
			sdi <= sdi;
			
			count <= count;
			case(sCurr)
				reset:
					begin
						shdn_n <= 1;
						cs_n <= 1;
						sdi <= 0;
						
						count <= 0;
					end
				transition_1:
					begin
						shdn_n <= 1;
						cs_n <= 1;
						
						count <= 9;
					end
				init_1:
					begin
						shdn_n <= 1;
						cs_n <= 0;
						sdi <= r1[count];
						
						count <= count - 1;
					end
				transition_2:
					begin
						shdn_n <= 1;
						cs_n <= 1;
						
						count <= 9;
					end
				init_2:
					begin
						shdn_n <= 1;
						cs_n <= 0;
						sdi <= r2[count];
						
						count <= count - 1;
					end
				hold:
					begin
						cs_n <= 1;
						shdn_n <= 1;
					end
				disable_device:
					begin
						shdn_n <= 0;
						cs_n <= 1;
					end
			endcase
		end
	end
	
	always_comb begin
		case(sCurr)
				reset:
					sNext = transition_1;
					
				transition_1:
					sNext = init_1;
					
				init_1:
					if(count == 0)
						sNext = transition_2;
					else
						sNext = init_1;
					
				transition_2:
					sNext = init_2;
					
				init_2:
					if(count == 0)
						sNext = hold;
					else
						sNext = init_2;
					
				hold:
					sNext = hold;
				
				disable_device:
					sNext = transition_1;
			endcase
	end

endmodule
