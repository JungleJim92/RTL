`timescale 1 ns / 1 ps

module UplinkInterface (
// System
	input rst_i,					// Synchronous reset
	input ping_i,
	output [31:0] uplink_dbg_a,
	output [31:0] uplink_dbg_b,
//	Receive data interface
	input	ul_clk,					// Serial data clock
	input	ul_data_a,				// Serial data stream A (contains ch1-ch12 from preamp)
	input	ul_data_b,				// Serial data stream B (contains ch13-ch24 from preamp)
// Scan RAM interface
	input ram_page,						// Current write page of RAM
	output reg [7:0] out_data_a,		// Data to write to Scan RAM A
	output reg [7:0] out_data_b,		// Data to write to Scan RAM B
	output [7:0] out_addr_a,			// Address of Scan RAM A to write to
	output [7:0] out_addr_b,			// Address of Scan RAM B to write to
	output reg	wren_a,					// Perform write to Scan RAM A
	output reg	wren_b,					// Perform write to Scan RAM B
// Packet merger interface
	output reg	packet_formed_a,		// A full packet has been received on the first uplink channel
	output reg	packet_formed_b		// A full packet has been received on the second uplink channel
);

// Constants
	parameter sync_w = 32'hB9AF2E5C;		// Common message sync word

// Internal registers
	logic [33:0] data_a;		// Serial data A
	logic [33:0] data_b;		// Serial data B
	
	logic [6:0] addr_a;	// Scan RAM A subaddress
	logic [6:0] addr_b;	// Scan RAM B subaddress
	
	logic [4:0] count_a;		// Counts bits when reading serial data
	logic [4:0] count_b;		// Counts bits when reading serial data
	
	logic [31:0] byte_count_a;	// Number of bytes to read in for each header field
	logic [31:0] byte_count_b;	// Number of bytes to read in for each header field
	
	logic sync_found_a;		// Sync word found in shiftreg A
	logic sync_found_b;		// Sync word found in shiftreg B

// Combinational outputs
	assign out_addr_a = {ram_page,addr_a};	// Output address for A data
	assign out_addr_b = {ram_page,addr_b};	// Output address for B data
	
	logic [31:0] dbg_temp_a;
	assign dbg_temp_a = {	ul_clk,					// 1
									rst_i,					// 2
									ul_data_a,				// 3
									sync_found_a,			// 4
									out_data_a,				// 12
									out_addr_a,				// 20
									wren_a,					// 21
									ram_page,				// 22
									packet_formed_a,		// 23
									packet_formed_b,		// 24
									count_a,					// 29
									3'b000 };				// 32
								
	logic [31:0] dbg_temp_b;
	assign dbg_temp_b = {	ul_clk,					// 1
									rst_i,					// 2
									ul_data_b,				// 3
									sync_found_b,			// 4
									out_data_b,				// 12
									out_addr_b,				// 20
									wren_b,					// 21
									ram_page,				// 22
									packet_formed_a,		// 23
									packet_formed_b,		// 24
									count_b,					// 29
									3'b000 };				// 32
								
								
									
	genvar i;
	generate
		for( i=0; i<32; i=i+1 ) begin : reverse
			assign uplink_dbg_a[i] = dbg_temp_a[31-i];
			assign uplink_dbg_b[i] = dbg_temp_b[31-i];
		end
	endgenerate
	
// Shift registers
	SyncShiftReg shift_reg_a(
		.sclr(rst_i),
		.clock(ul_clk),
		.shiftin(ul_data_a),
		.q(data_a)
	);
	
	SyncShiftReg shift_reg_b(
		.sclr(rst_i),
		.clock(ul_clk),
		.shiftin(ul_data_b),
		.q(data_b)
	);
	
// DFF Regs
	logic clr_reg_a;
	logic ping_d_a;
	input_register in_reg_a(.clk_i(ul_clk),.data_i(~ping_i),.clr_i(clr_reg_a),.data_o(ping_d_a));
	
	logic clr_reg_b;
	logic ping_d_b;
	input_register in_reg_b(.clk_i(ul_clk),.data_i(~ping_i),.clr_i(clr_reg_b),.data_o(ping_d_b));
	
// Initialization
	initial begin
	// Internals
		addr_a <= 0;
		addr_b <= 0;
		
		count_a <= 0;
		count_b <= 0;
		
		byte_count_a <=0;
		byte_count_b <=0;
		
		clr_reg_a <= 0;
		clr_reg_b <= 0;
		
	// Outputs
		out_data_a <= 0;
		out_data_b <= 0;
		
		wren_a <= 0;
		wren_b <= 0;
		
		packet_formed_a <= 0;
		packet_formed_b <= 0;
	end
	
// State declarations
	enum int unsigned {
		reset,
		
		wait_for_sync,
		sync_found,
		
		read_header,
		write_header,
		
		read_payload_size,
		write_payload_size,
		
		read_payload,
		write_payload,
		
		read_crc,
		write_crc,
		
		packet_formed
	} s_current_a, s_current_b, s_next_a, s_next_b;
	
// State transitions
	always_ff @(posedge ul_clk) begin
		sync_found_a <= ((data_a[31:0]) == sync_w);
		sync_found_b <= ((data_b[31:0]) == sync_w);
		if(rst_i) begin
			s_current_a <= reset;
			s_current_b <= reset;
		end
		else begin
			s_current_a <= s_next_a;
			s_current_b <= s_next_b;
		end
	end

// Next state combo logic (A)
	always_comb begin
		case(s_current_a)
			reset: begin
				s_next_a = wait_for_sync;
			end
			
			wait_for_sync: begin
				if(sync_found_a && ~ping_i)
					s_next_a = sync_found;
				else
					s_next_a = wait_for_sync;
			end
			
			sync_found: begin
				s_next_a = read_header;
			end
			
			read_header: begin
				if(count_a == 6)
					s_next_a = write_header;
				else
					s_next_a = read_header;
			end
			
			write_header: begin
				if(byte_count_a == 0)
					s_next_a = read_payload_size;
				else
					s_next_a = read_header;
			end
			
			read_payload_size: begin
				if(count_a == 6)
					s_next_a = write_payload_size;
				else
					s_next_a = read_payload_size;
			end
			
			write_payload_size: begin
				if(byte_count_a == 0)
					s_next_a = read_payload;
				else
					s_next_a = read_payload_size;
			end
			
			read_payload: begin
				if(count_a == 6)
					s_next_a = write_payload;
				else
					s_next_a = read_payload;
			end
			
			write_payload: begin
				if(byte_count_a == 0)
					s_next_a = read_crc;
				else
					s_next_a = read_payload;
			end
			
			read_crc: begin
				if(count_a == 6)
					s_next_a = write_crc;
				else
					s_next_a = read_crc;
			end
			
			write_crc: begin
				if(byte_count_a == 0)
					s_next_a = packet_formed;
				else
					s_next_a = read_crc;
			end
			
			packet_formed: begin
				if(packet_formed_a && packet_formed_b)
					s_next_a = wait_for_sync;
				else
					s_next_a = packet_formed;
			end
		endcase
	end

// Next state combo logic (B)
	always_comb begin
		case(s_current_b)
			reset: begin
				s_next_b = wait_for_sync;
			end
			
			wait_for_sync: begin
				if(sync_found_b && ~ping_i)
					s_next_b = sync_found;
				else
					s_next_b = wait_for_sync;
			end
			
			sync_found: begin
				s_next_b = read_header;
			end
			
			read_header: begin
				if(count_b == 6)
					s_next_b = write_header;
				else
					s_next_b = read_header;
			end
			
			write_header: begin
				if(byte_count_b == 0)
					s_next_b = read_payload_size;
				else
					s_next_b = read_header;
			end
			
			read_payload_size: begin
				if(count_b == 6)
					s_next_b = write_payload_size;
				else
					s_next_b = read_payload_size;
			end
			
			write_payload_size: begin
				if(byte_count_b == 0)
					s_next_b = read_payload;
				else
					s_next_b = read_payload_size;
			end
			
			read_payload: begin
				if(count_b == 6)
					s_next_b = write_payload;
				else
					s_next_b = read_payload;
			end
			
			write_payload: begin
				if(byte_count_b == 0)
					s_next_b = read_crc;
				else
					s_next_b = read_payload;
			end
			
			read_crc: begin
				if(count_b == 6)
					s_next_b = write_crc;
				else
					s_next_b = read_crc;
			end
			
			write_crc: begin
				if(byte_count_b == 0)
					s_next_b = packet_formed;
				else
					s_next_b = read_crc;
			end
			
			packet_formed: begin
				if(packet_formed_a && packet_formed_b)
					s_next_b = wait_for_sync;
				else
					s_next_b = packet_formed;
			end
		endcase
	end
	
// State outputs (A)
	always_ff @(posedge ul_clk) begin
		if(rst_i) begin
		// Internals
			addr_a <= 0;
			count_a <= 0;
			byte_count_a <= 0;
			clr_reg_a <= 0;
			
		// Outputs
			out_data_a <= 0;
			wren_a <= 0;
			packet_formed_a <= 0;
		end
		else begin
		// Internals
			addr_a <= addr_a;
			count_a <= count_a;
			byte_count_a <= byte_count_a;
			clr_reg_a <= clr_reg_a;
			
		// Outputs
			out_data_a <= out_data_a;
			wren_a <= wren_a;
			packet_formed_a <= packet_formed_a;
			
			case(s_current_a)
				reset: begin
				// Internals
					addr_a <= 0;
					count_a <= 0;
					byte_count_a <= 0;
					clr_reg_a <= 0;
					
				// Outputs
					wren_a <= 0;
					packet_formed_a <= 0;
				end
				
				wait_for_sync: begin
				// Outputs
					wren_a <= 0;
					packet_formed_a <= 0;
					clr_reg_a <= 0;
				end
				
				sync_found: begin
				// Internals
					addr_a <= 7'b1111111;
					count_a <= 0;
					byte_count_a <= 7;
					clr_reg_a <= 1;
					
				// Outputs
					wren_a <= 0;
					packet_formed_a <= 0;
				end
				
				read_header: begin
				// Internals
					count_a <= count_a + 1;
					clr_reg_a <= 0;
					
				// Outputs
					if(count_a == 6) begin
						addr_a <= addr_a + 1;
						out_data_a <= data_a[8:1];
					end
					wren_a <= 0;
					packet_formed_a <= 0;
				end
				
				write_header: begin
				// Internals
					count_a <= 0;
					if(byte_count_a == 0)
						byte_count_a <= 3;
					else
						byte_count_a <= byte_count_a - 1;
						
				// Outputs
					wren_a <= 1;
					packet_formed_a <= 0;
				end
				
				read_payload_size: begin
				// Internals
					count_a <= count_a + 1;
					
				// Outputs
					if(count_a == 6) begin
						addr_a <= addr_a + 1;
						out_data_a <= data_a[8:1];
					end
					wren_a <= 0;
					packet_formed_a <= 0;
				end
				
				write_payload_size: begin
				// Internals
					count_a <= 0;
					if(byte_count_a == 0)
						byte_count_a <= data_a[33:2] - 1;
					else
						byte_count_a <= byte_count_a - 1;
						
				// Outputs
					wren_a <= 1;
					packet_formed_a <= 0;
				end
				
				read_payload: begin
				// Internals
					count_a <= count_a + 1;
					
				// Outputs
					if(count_a == 6) begin
						addr_a <= addr_a + 1;
						out_data_a <= data_a[8:1];
					end
					wren_a <= 0;
					packet_formed_a <= 0;
				end
				
				write_payload: begin
				// Internals
					count_a <= 0;
					if(byte_count_a == 0)
						byte_count_a <= 3;
					else
						byte_count_a <= byte_count_a - 1;
					
				// Outputs
					wren_a <= 1;
					packet_formed_a <= 0;
				end
				
				read_crc: begin
				// Internals
					count_a <= count_a + 1;
					
				// Outputs
					if(count_a == 6) begin
						addr_a <= addr_a + 1;
						out_data_a <= data_a[8:1];
					end
					wren_a <= 0;
					packet_formed_a <= 0;
				end
				
				write_crc: begin
				// Internals
					count_a <= 0;
					if(byte_count_a != 0)
						byte_count_a <= byte_count_a - 1;
					
				// Outputs
					wren_a <= 1;
					packet_formed_a <= 0;
				end
				
				packet_formed: begin
				// Internals
					addr_a <= 0;
					
				// Outputs
					wren_a <= 0;
					packet_formed_a <= 1;
				end
			endcase
		end
	end
	
// State outputs (B)
	always_ff @(posedge ul_clk) begin
		if(rst_i) begin
		// Internals
			addr_b <= 0;
			count_b <= 0;
			byte_count_b <= 0;
			clr_reg_b <= 0;
			
		// Outputs
			out_data_b <= 0;
			wren_b <= 0;
			packet_formed_b <= 0;
		end
		else begin
		// Internals
			addr_b <= addr_b;
			count_b <= count_b;
			byte_count_b <= byte_count_b;
			clr_reg_b <= clr_reg_b;
			
		// Outputs
			out_data_b <= out_data_b;
			wren_b <= wren_b;
			packet_formed_b <= packet_formed_b;
			
			case(s_current_b)
				reset: begin
				// Internals
					addr_b <= 0;
					count_b <= 0;
					byte_count_b <= 0;
					clr_reg_b <= 0;
					
				// Outputs
					wren_b <= 0;
					packet_formed_b <= 0;
				end
				
				wait_for_sync: begin
				// Outputs
					wren_b <= 0;
					packet_formed_b <= 0;
					clr_reg_b <= 0;
				end
				
				sync_found: begin
				// Internals
					addr_b <= 255;
					count_b <= 0;
					byte_count_b <= 7;
					clr_reg_b <= 1;
					
				// Outputs
					wren_b <= 0;
					packet_formed_b <= 0;
				end
				
				read_header: begin
				// Internals
					count_b <= count_b + 1;
					clr_reg_b <= 0;
					
				// Outputs
					if(count_b == 6) begin
						addr_b <= addr_b + 1;
						out_data_b <= data_b[8:1];
					end
					wren_b <= 0;
					packet_formed_b <= 0;
				end
				
				write_header: begin
				// Internals
					count_b <= 0;
					if(byte_count_b == 0)
						byte_count_b <= 3;
					else
						byte_count_b <= byte_count_b - 1;
						
				// Outputs
					wren_b <= 1;
					packet_formed_b <= 0;
				end
				
				read_payload_size: begin
				// Internals
					count_b <= count_b + 1;
					
				// Outputs
					if(count_b == 6) begin
						addr_b <= addr_b + 1;
						out_data_b <= data_b[8:1];
					end
					wren_b <= 0;
					packet_formed_b <= 0;
				end
				
				write_payload_size: begin
				// Internals
					count_b <= 0;
					if(byte_count_b == 0)
						byte_count_b <= data_b[33:2] - 1;
					else
						byte_count_b <= byte_count_b - 1;
						
				// Outputs
					wren_b <= 1;
					packet_formed_b <= 0;
				end
				
				read_payload: begin
				// Internals
					count_b <= count_b + 1;
					
				// Outputs
					if(count_b == 6) begin
						addr_b <= addr_b + 1;
						out_data_b <= data_b[8:1];
					end
					wren_b <= 0;
					packet_formed_b <= 0;
				end
				
				write_payload: begin
				// Internals
					count_b <= 0;
					if(byte_count_b == 0)
						byte_count_b <= 3;
					else
						byte_count_b <= byte_count_b - 1;
					
				// Outputs
					wren_b <= 1;
					packet_formed_b <= 0;
				end
				
				read_crc: begin
				// Internals
					count_b <= count_b + 1;
					
				// Outputs
					if(count_b == 6) begin
						addr_b <= addr_b + 1;
						out_data_b <= data_b[8:1];
					end
					wren_b <= 0;
					packet_formed_b <= 0;
				end
				
				write_crc: begin
				// Internals
					count_b <= 0;
					if(byte_count_b != 0)
						byte_count_b <= byte_count_b - 1;
					
				// Outputs
					wren_b <= 1;
					packet_formed_b <= 0;
				end
				
				packet_formed: begin
				// Internals
					addr_b <= 0;
					
				// Outputs
					wren_b <= 0;
					packet_formed_b <= 1;
				end
			endcase
		end
	end
	
endmodule
