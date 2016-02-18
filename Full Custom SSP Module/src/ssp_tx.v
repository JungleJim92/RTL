`timescale 1ns/1ps

// Transmit Interface
module ssp_tx(
	input clk_i,
	input rst_i,
	input do_write,
	input [7:0] tx_d,
	output tx_full,
// Serial Interface
	input sspclkout,
	output sspfssout,
	output ssptxd,
	output sspoe
);
	
	wire transmit_ready;

//	FIFO Signals
	wire write;
	wire read;
	wire [7:0] write_d;
	wire [7:0] read_d;
	wire empty;
	wire full;
	
//	Transmitter Signals
	wire data_valid;
	wire tx_busy;
	wire [7:0] sr_in;
	
//	Assignments
	assign transmit_ready = (!empty) && (!tx_busy);

	assign write = do_write && (!full);
	assign write_d = tx_d;
	assign tx_full = full;
	
	assign sr_in = read_d;
	
//	Pulse Latches
	pulse_latch ps1 ( .clk_i(clk_i), .rst_i(read), .sig_i(transmit_ready), .sig_o(read) );
	pulse_latch ps2 ( .clk_i(sspclkout), .rst_i(data_valid | rst_i), .sig_i(read), .sig_o(data_valid) );
	
	fifo_4 tx_fifo (	.clk_i(clk_i),
						.rst_i(rst_i),
						.write(write),
						.read(read),
						.write_d(write_d),
						.read_d(read_d),
						.empty(empty),
						.full(full)
						);
	
	serial_transmitter ser_tx (	.sspclkout(sspclkout),
								.sspfssout(sspfssout),
								.ssptxd(ssptxd),
								.sspoe(sspoe),
								.rst_i(rst_i),
								.data_valid(data_valid),
								.busy(tx_busy),
								.ssptxout(sr_in)
								);
	
endmodule

module serial_transmitter (
	input sspclkout,
	output sspfssout,
	output ssptxd,
	output reg sspoe,
	input rst_i,
	input data_valid,
	output busy,
	input [7:0] ssptxout
);

	wire ld;
	wire shift;
	reg [2:0] t_count;
	reg busy_d;

	assign busy = t_count > 1;
	assign ld = data_valid && (!busy);
	assign shift = busy || ld || (busy_d && (t_count == 1));
	
	assign sspfssout = ld;
	
	shift_reg_tx tx_sr (	.clk_i(sspclkout),
							.rst_i(rst_i),
							.d_in(ssptxout),
							.ld(ld),
							.shift(shift),
							.q(ssptxd)
						);
						
	always @(posedge sspclkout) begin
		busy_d <= busy;
		if(rst_i) begin
			t_count <= 0;
			sspoe <= 1;
		end
		else if(t_count > 0)
			t_count <= t_count - 1;
		else if(ld)
			t_count <= 7;
	end
	
	always @(negedge sspclkout) begin
		if(!rst_i) begin
			if(ld && sspoe)
				sspoe <= 0;
			else if(!sspoe && (t_count == 0) && !ld)
				sspoe <= 1;
		end
	end

endmodule

module shift_reg_tx (
	input clk_i,
	input rst_i,
	input [7:0] d_in,
	input ld,
	input shift,
	output reg q
);
	reg [7:0] d;

	always @(posedge clk_i) begin
		if(rst_i) begin
			d <= 0;
			q <= 0;
		end
		else begin
			if(shift && ld) begin
				d <= {d_in[6:0],1'b0};
				q <= d_in[7];
			end
			else if(shift) begin
				d <= {d[6:0],1'b0};
				q <= d[7];
			end
			else if(ld)
				d <= d_in;
		end
	end

endmodule
