module ResetController (
	input clk,
	output reg rst_o,
	output reg rst_2,
	output rst_n_o,
	output rst_n_2
);

	parameter ms = 54000;

	logic [31:0] count;
	logic [31:0] count2;
	
	assign rst_n_o = !rst_o;
	assign rst_n_2 = !rst_2;
	
	enum int unsigned {
		reset,
		do_reset,
		do_reset2,
		hold
	} sCurr, sNext;
	
	always_ff@(posedge clk) begin
		sCurr <= sNext;
	end
	
	always_comb begin
		case(sCurr)
			reset: begin
				sNext = do_reset;
			end
			
			do_reset: begin
				if(count < ms * 50)
					sNext = do_reset;
				else
					sNext = do_reset2;
			end
			
			do_reset2: begin
				if(count2 < ms * 10)
					sNext = do_reset2;
				else
					sNext = hold;
			end
			
			hold: begin
				sNext = hold;
			end
		endcase
	end
	
	always_ff@(posedge clk) begin
		case(sCurr)
			reset: begin
				rst_o <= 1;
				rst_2 <= 1;
				count <= 0;
				count2 <= 0;
			end
			
			do_reset: begin
				rst_o <= 1;
				rst_2 <= 1;
				count <= count + 1;
				count2 <= 0;
			end
			
			do_reset2: begin
				rst_o <= 0;
				rst_2 <= 1;
				count <= 0;
				count2 <= count2 + 1;
			end
			
			hold: begin
				rst_o <= 0;
				rst_2 <= 0;
				count <= 0;
				count2 <= 0;
			end
		endcase
	end
	
endmodule
