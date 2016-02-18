`timescale 1 ns / 1 ps

module DownlinkInterface (
// System
	input dl_clk_i,				// Clock input for downlink communications
	input rst_i,					// Synchronous reset
// Downlink interface
	output dl_clk,					// Serial data clock
	output reg dl_data,        // Serial data stream
	output [31:0] downlink_dbg,
// State information
	input [31:0] num_scans,
	input [31:0] power_save_mode,
	input [31:0] range_scale,
	input [31:0] power_level,
	input [31:0] is_steer_true,
	input [31:0] steer_angle,
	input [31:0] pulse_type,
	input [31:0] tvg_select,
	input [31:0] gain_attn,
	input [31:0] power_level_attn,
	input [31:0] scan_start,
// Control information
	input [31:0] test_data,
	input [31:0] do_fl,
// Request/Ack
	input ping						// Synchronous downlink packet request
);

// Constants
	parameter sync_w = 			32'hB9AF2E5C;	// Common message sync word
	parameter sync_w_2 = 		32'h86F2B9AF;	// Sync word part 2
	parameter packet_type_w = 	32'h00000000;	// Packet type for Downlink Control
	parameter dest_w =			32'h00ff00ff;	// Preamp and module destination for common message
	parameter num_bytes_w =		32'h00000054;	// Number of bytes in a downlink payload
	parameter time_w =			50000;			// Number of ticks in 5 ms for 10 MHz clock

// Internal registers
	logic [4:0] bit_count;		// Current bit to output
	logic [4:0] bit_count_d;
	logic [3:0] state_count;	// Select lines for MUX
	logic [3:0] state_count_d;	// Select lines for MUX
	logic [3:0] t_count;			// Counter for outputting time_of_day and ping_info
	logic [3:0] t_count_d;		// Counter for outputting time_of_day and ping_info
	logic [3:0] sync_count;		// Counter for outputting sync word in downlink message packet
	logic [3:0] sync_count_d;	// Counter for outputting sync word in downlink message packet
	logic [31:0] curr_out;		// Current output from MUX
	
	logic [31:0] time_count;
	
	// Holding registers
	logic [31:0] num_scans_d;
	logic [31:0] power_save_mode_d;
	logic [31:0] range_scale_d;
	logic [31:0] power_level_d;
	logic [31:0] is_steer_true_d;
	logic [31:0] steer_angle_d;
	logic [31:0] pulse_type_d;
	logic [31:0] tvg_select_d;
	logic [31:0] gain_attn_d;
	logic [31:0] power_level_attn_d;
	logic [31:0] scan_start_d;
	logic [31:0] test_data_d;
	logic [31:0] do_fl_d;
	
	logic dl_data_d;
	logic ping_d;
	logic clr_regs;
	
	logic [31:0] downlink_dbg_temp;

// Combinational outputs
	assign dl_clk = dl_clk_i;		// Run the downlink communications with the system dl_clk
	assign downlink_dbg_temp = {	dl_clk_i,			// 1 bit			1
											dl_clk,				// 1 bit			2
											rst_i,				// 1 bit			3
											ping,					// 1 bit			4
											ping_d,				// 1 bit			5
											dl_data_d,			// 1 bit			6
											dl_data,				// 1 bit			7
											bit_count,			// 5 bits		12
											bit_count_d,		// 5 bits		17
											state_count,		// 4 bits		21
											state_count_d,		// 4 bits		25
											7'b0000000 };		// 7 bits		32
									
	genvar i;
	generate
		for( i=0; i<32; i=i+1 ) begin : reverse
			assign downlink_dbg[i] = downlink_dbg_temp[31-i];
		end
	endgenerate
	
// DFF Regs
	input_register in_reg(.clk_i(dl_clk_i),.data_i(ping),.clr_i(clr_regs),.data_o(ping_d));
	
// State info MUX
	DownlinkControlMux dl_mux(
		.data0x(packet_type_w),
		.data1x(dest_w),
		.data2x(num_bytes_w),
		.data3x(num_scans_d),
		.data4x(power_save_mode_d),
		.data5x(range_scale_d),
		.data6x(power_level_d),
		.data7x(is_steer_true_d),
		.data8x(steer_angle_d),
		.data9x(pulse_type_d),
		.data10x(tvg_select_d),
		.data11x(gain_attn_d),
		.data12x(power_level_attn_d),
		.data13x(scan_start_d),
		.data14x(test_data_d),
		.data15x(do_fl_d),
		.sel(state_count),
		.result(curr_out)
	);

// CRC Blocks
	logic clr_crc;
	logic [4:0] crc_count;
	
	logic [31:0] crc_i_1;
	logic [31:0] crc_o_1;
	logic crc_compute_1;
	CRC32_D32 crc1(.clk(dl_clk_i),.rst(clr_crc),.data_in(crc_i_1),.crc_en(crc_compute_1),.crc_out(crc_o_1));
	
	logic [31:0] crc_i_2;
	logic [31:0] crc_o_2;
	logic crc_compute_2;
	CRC32_D32 crc2(.clk(dl_clk_i),.rst(clr_crc),.data_in(crc_i_2),.crc_en(crc_compute_2),.crc_out(crc_o_2));
	
// Initialization
	initial begin
	// Internals
		state_count <= 0;
		state_count_d <= 0;
		t_count <= 0;
		t_count_d <= 0;
		bit_count <= 0;
		bit_count_d <= 0;
		sync_count <= 0;
		sync_count_d <= 0;
		
		dl_data_d <= 0;
		clr_regs <= 0;
		
		num_scans_d <= 0;
		power_save_mode_d <= 0;
		range_scale_d <= 0;
		power_level_d <= 0;
		is_steer_true_d <= 0;
		steer_angle_d <= 0;
		pulse_type_d <= 0;
		tvg_select_d <= 0;
		gain_attn_d <= 0;
		power_level_attn_d <= 0;
		scan_start_d <= 0;
		test_data_d <= 0;
		do_fl_d <= 0;
		
	// Outputs
		dl_data <= 0;
	end
	
// State declarations
	enum int unsigned {
		reset,
		
		wait_for_request,
		acknowledge_request,
		
		output_sync_1,
		output_common_header,
		output_sync_2,
		output_time,
		output_header,
		output_crc_1,
		output_crc_2
		
	} s_current, s_next;
	
// State transitions
	always_ff @(negedge dl_clk_i) begin
		if(rst_i) begin
			s_current <= reset;
		end
		else begin
			s_current <= s_next;
		end
	end
	
// Next state combo logic
	always_comb begin
		case(s_current)
			reset: begin
				s_next = wait_for_request;
			end
			
			wait_for_request: begin
				if(ping_d)
					s_next = acknowledge_request;
				else
					s_next = wait_for_request;
			end
			
			acknowledge_request: begin
				if(time_count >= time_w)
					s_next = output_sync_1;
				else
					s_next = acknowledge_request;
			end
			
			output_sync_1: begin
				if(bit_count_d == 0)
					s_next = output_common_header;
				else
					s_next = output_sync_1;
			end
			
			output_common_header: begin
				if(state_count == 2 && bit_count_d == 0)
					s_next = output_sync_2;
				else
					s_next = output_common_header;
			end
			
			output_sync_2: begin
				if(sync_count == 1 && bit_count_d == 0)
					s_next = output_time;
				else
					s_next = output_sync_2;
			end
			
			output_time: begin
				if(t_count == 4 && bit_count_d == 0)
					s_next = output_header;
				else
					s_next = output_time;
			end
			
			output_header: begin
				if(state_count == 15 && bit_count_d == 0)
					s_next = output_crc_1;
				else
					s_next = output_header;
			end
			
			output_crc_1: begin
				if(bit_count_d == 0)
					s_next = output_crc_2;
				else
					s_next = output_crc_1;
			end
			
			output_crc_2: begin
				if(bit_count_d == 0)
					s_next = wait_for_request;
				else
					s_next = output_crc_2;
			end
		endcase
	end
	
// State outputs
	
// Positive edge logic
	always_ff @(posedge dl_clk_i) begin
		if(rst_i) begin
		// Internals
			state_count_d <= 0;
			t_count_d <= 0;
			sync_count_d <= 0;
			bit_count <= 0;
			time_count <= 0;
			clr_regs <= 0;
			
			dl_data_d <= 0;
		end
		else begin
		// Internals
			state_count_d <= state_count_d;
			t_count_d <= t_count_d;
			sync_count_d <= sync_count_d;
			bit_count <= bit_count;
			time_count <= time_count;
			
			dl_data_d <= dl_data_d;
			clr_regs <= clr_regs;
			
			case(s_current)
				reset: begin
					state_count_d <= 0;
					t_count_d <= 0;
					sync_count_d <= 0;
					bit_count <= 0;
					time_count <= 0;
					
					dl_data_d <= 0;
					clr_regs <= 1;
				end
				
				wait_for_request: begin
					bit_count <= 0;
					time_count <= 0;
					clr_regs <= 0;
				end
				
				acknowledge_request: begin
					state_count_d <= 0;
					t_count_d <= 0;
					sync_count_d <= 0;
					bit_count <= 31;
					clr_regs <= 1;
					time_count <= time_count + 1;
				end
				
				output_sync_1: begin
					dl_data_d <= sync_w[bit_count_d];
					bit_count <= bit_count - 1;
					clr_regs <= 0;
				end
				
				output_common_header: begin
					dl_data_d <= curr_out[bit_count_d];
					bit_count <= bit_count - 1;
					if(bit_count_d == 0)
						state_count_d <= state_count_d + 1;
					else
						state_count_d <= state_count_d;
				end
				
				output_sync_2: begin
					if(sync_count == 0)
						dl_data_d <= sync_w[bit_count_d];
					else
						dl_data_d <= sync_w_2[bit_count_d];
					bit_count <= bit_count - 1;
					if(bit_count_d == 0)
						sync_count_d <= sync_count_d + 1;
					else
						sync_count_d <= sync_count_d;
				end
				
				output_time: begin
					dl_data_d <= 0;
					bit_count <= bit_count - 1;
					if(bit_count_d == 0)
						t_count_d <= t_count_d + 1;
					else
						t_count_d <= t_count_d;
				end
				
				output_header: begin
					dl_data_d <= curr_out[bit_count_d];
					bit_count <= bit_count - 1;
					if(bit_count_d == 0)
						state_count_d <= state_count_d + 1;
					else
						state_count_d <= state_count_d;
				end
				
				output_crc_1: begin
					dl_data_d <= crc_o_2[bit_count_d];
					bit_count <= bit_count - 1;
				end
				
				output_crc_2: begin
					dl_data_d <= crc_o_1[bit_count_d];
					bit_count <= bit_count - 1;
				end
			endcase
		end
	end
	
//Negative edge logic
	always_ff @(negedge dl_clk_i) begin
		if(rst_i) begin
		// Internals
			state_count <= 0;
			t_count <= 0;
			sync_count <= 0;
			bit_count_d <= 0;
			
			num_scans_d <= 0;
			power_save_mode_d <= 0;
			range_scale_d <= 0;
			power_level_d <= 0;
			is_steer_true_d <= 0;
			steer_angle_d <= 0;
			pulse_type_d <= 0;
			tvg_select_d <= 0;
			gain_attn_d <= 0;
			power_level_attn_d <= 0;
			scan_start_d <= 0;
			test_data_d <= 0;
			do_fl_d <= 0;
			
		// Outputs
			dl_data <= 0;
		end
		else begin
		// Internals
			state_count <= state_count;
			t_count <= t_count;
			sync_count <= sync_count;
			bit_count_d <= bit_count_d;
			
			num_scans_d <= num_scans_d;
			power_save_mode_d <= power_save_mode_d;
			range_scale_d <= range_scale_d;
			power_level_d <= power_level_d;
			is_steer_true_d <= is_steer_true_d;
			steer_angle_d <= steer_angle_d;
			pulse_type_d <= pulse_type_d;
			tvg_select_d <= tvg_select_d;
			gain_attn_d <= gain_attn_d;
			power_level_attn_d <= power_level_attn_d;
			scan_start_d <= scan_start_d;
			test_data_d <= test_data_d;
			do_fl_d <= do_fl_d;
			
		// Outputs
			dl_data <= dl_data;
			
			case(s_current)
				reset: begin
				// Internals
					state_count <= 0;
					t_count <= 0;
					sync_count <= 0;
					bit_count_d <= 0;
					
					num_scans_d <= 0;
					power_save_mode_d <= 0;
					range_scale_d <= 0;
					power_level_d <= 0;
					is_steer_true_d <= 0;
					steer_angle_d <= 0;
					pulse_type_d <= 0;
					tvg_select_d <= 0;
					gain_attn_d <= 0;
					power_level_attn_d <= 0;
					scan_start_d <= 0;
					test_data_d <= 0;
					do_fl_d <= 0;
					
				// Outputs
					dl_data <= 0;
				end
				
				wait_for_request: begin
				// Internals
					state_count <= 0;
					
				// Outputs
					dl_data <= 0;
				end
				
				acknowledge_request: begin
				// Internals
					state_count <= 0;
					t_count <= 0;
					sync_count <= 0;
					bit_count_d <= 31;
					
					if(time_count == 1) begin
						num_scans_d <= num_scans;
						power_save_mode_d <= power_save_mode;
						range_scale_d <= range_scale;
						power_level_d <= power_level;
						is_steer_true_d <= is_steer_true;
						steer_angle_d <= steer_angle;
						pulse_type_d <= pulse_type;
						tvg_select_d <= tvg_select;
						gain_attn_d <= gain_attn;
						power_level_attn_d <= power_level_attn;
						scan_start_d <= scan_start;
						test_data_d <= test_data;
						do_fl_d <= do_fl;
					end
					
				// Outputs
					dl_data <= 0;
				end
				
				output_sync_1: begin
				// Internals
					bit_count_d <= bit_count;
					state_count <= state_count_d;
					
				// Outputs
					dl_data <= dl_data_d;
				end
				
				output_common_header: begin
				// Internals
					bit_count_d <= bit_count;
					state_count <= state_count_d;
					
				// Outputs
					dl_data <= dl_data_d;
				end
				
				output_sync_2: begin
				// Internals
					bit_count_d <= bit_count;
					state_count <= state_count_d;
					sync_count <= sync_count_d;
					
				// Outputs
					dl_data <= dl_data_d;
				end
				
				output_time: begin
				// Internals
					bit_count_d <= bit_count;
					t_count <= t_count_d;
					
				// Outputs
					dl_data <= dl_data_d;
				end
				
				output_header: begin
				// Internals
					bit_count_d <= bit_count;
					state_count <= state_count_d;
					
				// Outputs
					dl_data <= dl_data_d;
				end
				
				output_crc_1: begin
				// Internals
					bit_count_d <= bit_count;
					state_count <= state_count_d;
					
				// Outputs
					dl_data <= dl_data_d;
				end
				
				output_crc_2: begin
				// Internals
					bit_count_d <= bit_count;
					state_count <= state_count_d;
					
				// Outputs
					dl_data <= dl_data_d;
				end
			endcase
		end
	end
	
/********** CRC ***********/

	initial begin
		clr_crc <= 0;
		crc_count <= 0;
		
		crc_i_1 <= 0;
		crc_compute_1 <= 0;
		
		crc_i_2 <= 0;
		crc_compute_2 <= 0;
	end
	
// CRC States
	enum int unsigned {
	
		crc_reset,
		crc_wait_for_request,
		crc_clear,
		build_crc
		
	} s_crc_curr, s_crc_next;
	
// State transitions
	always_ff @(posedge dl_clk_i) begin
		if(rst_i) begin
			s_crc_curr <= crc_reset;
		end
		else begin
			s_crc_curr <= s_crc_next;
		end
	end
	
// Next state combo logic
	always_comb begin
		case(s_crc_curr)
			crc_reset: begin
				s_crc_next = crc_wait_for_request;
			end
			
			crc_wait_for_request: begin
				if(ping_d)
					s_crc_next = crc_clear;
				else
					s_crc_next = crc_wait_for_request;
			end
			
			crc_clear: begin
				s_crc_next = build_crc;
			end
			
			build_crc: begin
				if(crc_count >= 27)
					s_crc_next = crc_wait_for_request;
				else
					s_crc_next = build_crc;
			end
		endcase
	end
	
// CRC Logic
	always_ff @(posedge dl_clk_i) begin
		if(rst_i) begin
			clr_crc <= 1;
			crc_count <= 0;
			
			crc_i_1 <= 0;
			crc_compute_1 <= 0;
			
			crc_i_2 <= 0;
			crc_compute_2 <= 0;
		end
		else begin
			clr_crc <= clr_crc;
			crc_count <= crc_count;
			
			crc_i_1 <= crc_i_1;
			crc_compute_1 <= crc_compute_1;
			
			crc_i_2 <= crc_i_2;
			crc_compute_2 <= crc_compute_2;
			
			case(s_crc_curr)
				crc_reset: begin
					clr_crc <= 1;
					crc_count <= 0;
					
					crc_i_1 <= 0;
					crc_compute_1 <= 0;
					
					crc_i_2 <= 0;
					crc_compute_2 <= 0;
				end
				
				crc_wait_for_request: begin
					clr_crc <= 0;
					crc_count <= 0;
					
					crc_i_1 <= 0;
					crc_compute_1 <= 0;
					
					crc_i_2 <= 0;
					crc_compute_2 <= 0;
				end
				
				crc_clear: begin
					clr_crc <= 1;
					crc_count <= 0;
					
					crc_i_1 <= 0;
					crc_compute_1 <= 0;
					
					crc_i_2 <= 0;
					crc_compute_2 <= 0;
				end
				
				build_crc: begin
					clr_crc <= 0;
					crc_count <= crc_count + 1;
					if(crc_count >= 24 && crc_count <= 26)
						crc_compute_1 <= 0;
					else
						crc_compute_1 <= 1;
					if(crc_count >= 4 && crc_count <= 23)
						crc_compute_2 <= 1;
					else
						crc_compute_2 <= 0;
					case(crc_count)
					// Scan Sync
						0: begin
							crc_i_1 <= sync_w;
						end
					// Packet Type
						1: begin
							crc_i_1 <= packet_type_w;
						end
					// Preamp and Module Destinations
						2: begin
							crc_i_1 <= dest_w;
						end
					// Num Data Bytes
						3: begin
							crc_i_1 <= num_bytes_w;
						end
					// Sync w 1
						4: begin
							crc_i_1 <= sync_w;
							crc_i_2 <= sync_w;
						end
					// Sync w 2
						5: begin
							crc_i_1 <= sync_w_2;
							crc_i_2 <= sync_w_2;
						end
					// sec_value
						6: begin
							crc_i_1 <= 0;
							crc_i_2 <= 0;
						end
					// nsec_value
						7: begin
							crc_i_1 <= 0;
							crc_i_2 <= 0;
						end
					// interval_msec
						8: begin
							crc_i_1 <= 0;
							crc_i_2 <= 0;
						end
					// ping_time 1
						9: begin
							crc_i_1 <= 0;
							crc_i_2 <= 0;
						end
					// ping_time 2
						10: begin
							crc_i_1 <= 0;
							crc_i_2 <= 0;
						end
					// num_scans
						11: begin
							crc_i_1 <= num_scans_d;
							crc_i_2 <= num_scans_d;
						end
					// power_save_mode
						12: begin
							crc_i_1 <= power_save_mode_d;
							crc_i_2 <= power_save_mode_d;
						end
					// range_scale
						13: begin
							crc_i_1 <= range_scale_d;
							crc_i_2 <= range_scale_d;
						end
					// power_level
						14: begin
							crc_i_1 <= power_level_d;
							crc_i_2 <= power_level_d;
						end
					// is_steer_true
						15: begin
							crc_i_1 <= is_steer_true_d;
							crc_i_2 <= is_steer_true_d;
						end
					// steer_angle
						16: begin
							crc_i_1 <= steer_angle_d;
							crc_i_2 <= steer_angle_d;
						end
					// pulse_type
						17: begin
							crc_i_1 <= pulse_type;
							crc_i_2 <= pulse_type;
						end
					// tvg_select
						18: begin
							crc_i_1 <= tvg_select_d;
							crc_i_2 <= tvg_select_d;
						end
					// gain_attn
						19: begin
							crc_i_1 <= gain_attn_d;
							crc_i_2 <= gain_attn_d;
						end
					// power_level_attn
						20: begin
							crc_i_1 <= power_level_attn_d;
							crc_i_2 <= power_level_attn_d;
						end
					// scan_start
						21: begin
							crc_i_1 <= scan_start_d;
							crc_i_2 <= scan_start_d;
						end
					// test_data
						22: begin
							crc_i_1 <= test_data_d;
							crc_i_2 <= test_data_d;
						end
					// do_fl
						23: begin
							crc_i_1 <= do_fl_d;
							crc_i_2 <= do_fl_d;
						end
					// wait a couple cylces for crc_2 to get computed
						24: ;
						25: ;
						26: ;
					// crc1
						27: begin
							crc_i_1 <= crc_o_2;
						end
					endcase
				end
			endcase
		end
	end
	
endmodule
