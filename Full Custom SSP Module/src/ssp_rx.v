`timescale 1ns/1ps

// Receive Interface
module ssp_rx(
	input clk_i,
	input rst_i,
	input do_read,
	output [7:0] rx_d,
	output rx_full,
// Serial Interface
	input sspclkin,
	input sspfssin,
	input ssprxd
);
	
	wire rx_empty;
	wire [7:0] sr_out;
	wire valid_data;
	wire valid_data_d;
	wire rd_ack;
							
	assign rd_ack = valid_data_d & !rst_i;
	
	fifo_4 rx_fifo (	.clk_i(clk_i),
						.rst_i(rst_i),
						.write(valid_data_d & !rx_full),
						.read(do_read),
						.write_d(sr_out),
						.read_d(rx_d),
						.empty(rx_empty),
						.full(rx_full)
					);
					
	serial_receiver ser_rx (	.sspclkin(sspclkin),
								.sspfssin(sspfssin),
								.rd_ack(rd_ack),
								.rst_i(rst_i),
								.ssprxd(ssprxd),
								.ssprxout(sr_out),
								.valid_data(valid_data)
							);
							
	pulse_latch ps1 ( .clk_i(clk_i), .rst_i(valid_data_d | rst_i), .sig_i(valid_data), .sig_o(valid_data_d) );
	
endmodule

module serial_receiver (
	input sspclkin,
	input sspfssin,
	input ssprxd,
	input rst_i,
	input rd_ack,
	output [7:0] ssprxout,
	output reg valid_data
);
	
	reg [2:0] t_count;

	reg sr_enable;
	shift_reg_rx rx_sr (	.clk_i(sspclkin),
							.rst_i(rst_i),
							.sig_i(ssprxd),
							.en(sr_enable),
							.q(ssprxout)
						);
					
	wire rd_ack_d;
	pulse_latch rd_ack_latch ( .clk_i(sspclkin), .rst_i(rd_ack_d | rst_i), .sig_i(rd_ack), .sig_o(rd_ack_d) );
	
	always @(posedge sspclkin) begin
		if(rst_i) begin
			t_count <= 0;
			sr_enable <= 0;
		end
		else begin
			if(t_count > 0) begin
				t_count <= t_count - 1;
			end
			else if(sspfssin) begin
				if(sr_enable) begin
					
				end
				else begin
					t_count <= 7;
					sr_enable <= 1;
				end
			end
			else begin
				sr_enable <= 0;
			end
			
			if(t_count == 0 && sr_enable)
				valid_data <= 1;
			else if(rd_ack_d)
				valid_data <= 0;
		end
	end

endmodule

module shift_reg_rx (
	input clk_i,
	input rst_i,
	input sig_i,
	input en,
	output reg [7:0] q
);

	always @(posedge clk_i) begin
		if(rst_i) begin
			q <= 0;
		end
		else if(en)
			q <= {q[6:0],sig_i};
	end

endmodule
