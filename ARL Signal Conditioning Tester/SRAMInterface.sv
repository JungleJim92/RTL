module SRAMInterface (
// System
	input clk_i,					// System clock
	input rst_i,					// Synchronous reset
	input ping_i,					// New ping requested
	output [31:0] sram_input_dbg,
	output [31:0] sram_output_dbg,
	output [31:0] sram_output_with_scans_dbg,
//	Receive data interface
	input [31:0] num_scans,			// Number of scans to capture
	input	packet_formed_a_i,		// A full packet has been received on the first uplink channel
	input	packet_formed_b_i,		// A full packet has been received on the second uplink channel
// Scan RAM Interface
	output reg rd_clk,				// Clock for reading from 2-port RAM
	output reg [6:0] rd_addr,		// Address to read scan data from RAM
	input [15:0] rd_data_a,			// Data read from rd_address in RAM (A)
	input [15:0] rd_data_b,			// Data read from rd_address in RAM (B)
// SRAM Interface
	output reg [15:0] sram_d,
	output reg [19:0] sram_addr,
	output reg sram_forming_packet,
	output reg sram_packet_formed,
	output reg sram_we_n,
	output reg sram_ld_addr_n
);

// Constants
	parameter data_start = 6'h08;
	parameter data_size = 26;

// Internal registers	
	logic packet_formed_a_d;
	logic packet_formed_b_d;
	
	logic clr_regs;
	
	logic ping_d;
	
	logic [5:0] packet_count;
	logic [31:0] scan_count;
	
	logic [15:0]sram_d_1;

// DFF_Regs
	input_register in_reg_1(.clk_i(clk_i),.data_i(packet_formed_a_i),.clr_i(clr_regs),.data_o(packet_formed_a_d));
	input_register in_reg_2(.clk_i(clk_i),.data_i(packet_formed_b_i),.clr_i(clr_regs),.data_o(packet_formed_b_d));
	input_register in_reg_3(.clk_i(clk_i),.data_i(ping_i),.clr_i(clr_regs),.data_o(ping_d));
	
// Debug output
	logic [31:0] sram_input_dbg_temp;
	assign sram_input_dbg_temp = {	clk_i,					// 1
												rst_i,					// 2
												ping_i,					// 3
												ping_d,					// 4
												packet_formed_a_i,	// 5
												packet_formed_b_i,	// 6
												packet_formed_a_d,	// 7
												packet_formed_b_d,	// 8
												clr_regs,				// 9
												rd_addr,					// 16
												rd_data_a,				// 32
												};
												
	logic [31:0] sram_output_dbg_temp;
	assign sram_output_dbg_temp = {	clk_i,					// 1
												rst_i,					// 2
												ping_d,					// 3
												packet_formed_a_d,	// 4
												packet_formed_b_d,	// 5
												clr_regs,				// 6
												sram_forming_packet,	// 7
												sram_packet_formed,	// 8
												sram_we_n,				// 9
												sram_addr[6:0],		// 16
												sram_d,					// 32
												};
												
	logic [31:0] sram_output_with_scans_dbg_temp;
	assign sram_output_with_scans_dbg_temp = {	clk_i,					// 1
																rst_i,					// 2
																ping_d,					// 3
																packet_formed_a_d,	// 4
																packet_formed_b_d,	// 5
																clr_regs,				// 6
																sram_forming_packet,	// 7
																sram_packet_formed,	// 8
																sram_we_n,				// 9
																scan_count[22:0]		// 32
																};
												
	genvar i;
	generate
		for( i=0; i<32; i=i+1 ) begin : reverse
			assign sram_input_dbg[i] = sram_input_dbg_temp[31-i];
			assign sram_output_dbg[i] = sram_output_dbg_temp[31-i];
			assign sram_output_with_scans_dbg[i] = sram_output_with_scans_dbg_temp[31-i];
		end
	endgenerate

// Initialization
	initial begin
	// Internals		
		clr_regs <= 0;
		
		packet_count <= 0;
		scan_count <= 0;
		
	// Outputs
		rd_addr <= 0;
		
		sram_addr <= 0;
		sram_d <= 0;
		sram_d_1 <= 0;
		
		sram_forming_packet <= 0;
		sram_packet_formed <= 0;
		sram_we_n <= 1;
		sram_ld_addr_n <= 1;
	end
	
// State declarations
	enum int unsigned {
		reset,
		
		wait_for_ping,
		ping_found,
		
		skip_packet,
		
		wait_for_packet,
		packet_found,
		
		copy_to_sram_a,
		copy_to_sram_b,
		
		finish_packet
		
	} s_current, s_next;
	
// Clock initialization
	assign rd_clk = clk_i;
	
// State transitions
	always_ff @(posedge clk_i) begin
		if(rst_i)
			s_current <= reset;
		else
			s_current <= s_next;
	end

// Next state combo logic
	always_comb begin
		case(s_current)
			reset: begin
				s_next = wait_for_ping;
			end
			
			wait_for_ping: begin
				if(ping_d && ~ping_i)
					s_next = ping_found;
				else
					s_next = wait_for_ping;
			end
			
			ping_found: begin
				s_next = skip_packet;
			end
			
			skip_packet: begin
				if(packet_formed_a_d && packet_formed_b_d)
					s_next = wait_for_packet;
				else
					s_next = skip_packet;
			end
			
			wait_for_packet: begin
				if(packet_formed_a_d && packet_formed_b_d)
					s_next = packet_found;
				else
					s_next = wait_for_packet;
			end
			
			packet_found: begin
				s_next = copy_to_sram_a;
			end
			
			copy_to_sram_a: begin
				if(packet_count == 0)
					s_next = copy_to_sram_b;
				else
					s_next = copy_to_sram_a;
			end
			
			copy_to_sram_b: begin
				if(packet_count == 0)
					s_next = finish_packet;
				else
					s_next = copy_to_sram_b;
			end
			
			finish_packet: begin
				if(scan_count == 0)
					s_next = wait_for_ping;
				else
					s_next = wait_for_packet;
			end
		endcase
	end

// State outputs (A)
	always_ff @(posedge clk_i) begin
		if(rst_i) begin
		// Internals
			clr_regs <= 0;
			
			packet_count <= 0;
			scan_count <= 0;
			
		// Outputs
			rd_addr <= 0;
			
			sram_addr <= 0;
			sram_d <= 0;
			sram_d_1 <= 0;
			
			
			sram_forming_packet <= 0;
			sram_packet_formed <= 0;
			sram_we_n <= 1;
			sram_ld_addr_n <= 1;
		end
		else begin
		// Internals		
			clr_regs <= 0;
			
			packet_count <= packet_count;
			scan_count <= scan_count;
			
		// Outputs
			rd_addr <= rd_addr;
					
			sram_addr <= sram_addr;
			sram_d <= sram_d;
			sram_d_1 <= sram_d_1;
					
					
			sram_forming_packet <= sram_forming_packet;
			sram_packet_formed <= sram_packet_formed;
			sram_we_n <= sram_we_n;
			sram_ld_addr_n <= sram_ld_addr_n;
			
			case(s_current)
				reset: begin
				// Internals		
					clr_regs <= 0;
					
					packet_count <= 0;
					scan_count <= 0;
					
				// Outputs
					rd_addr <= 0;
					
					sram_addr <= 0;
					sram_d <= 0;
					sram_d_1 <= 0;
					
					
					sram_forming_packet <= 0;
					sram_packet_formed <= 0;
					sram_we_n <= 1;
					sram_ld_addr_n <= 1;
				end
				
				wait_for_ping: begin
					clr_regs <= 0;
				end
				
				ping_found: begin
				// Internals
					clr_regs <= 1;
					
					scan_count <= num_scans;
					
				// Outputs
					sram_forming_packet <= 1;
					sram_packet_formed <= 0;
					sram_addr <= 0;
					sram_d <= 0;
				end
				
				skip_packet: begin
				//Internals
					if(packet_formed_a_d && packet_formed_b_d)
						clr_regs <= 1;
					else
						clr_regs <= 0;
				end
				
				wait_for_packet: begin
					clr_regs <= 0;
				end
				
				packet_found: begin
				// Internals		
					clr_regs <= 1;
					
					packet_count <= data_size;
					scan_count <= scan_count - 1;
					
				// Outputs
					rd_addr <= {~rd_addr[6],6'b000110};
					
					sram_we_n <= 1;
					sram_ld_addr_n <= 1;
				end
				
				copy_to_sram_a: begin					
					if(packet_count == 0) begin
						packet_count <= data_size;
						rd_addr <= {rd_addr[6],6'b000110};
						
						sram_we_n <= 1;
						sram_ld_addr_n <= 1;
						
						sram_d <= {rd_data_a[7:0],rd_data_a[15:8]};
						sram_addr <= sram_addr + 1;
					end
					else if(packet_count == data_size) begin
						packet_count <= packet_count - 1;
						rd_addr <= rd_addr + 1;
						
						sram_we_n <= 0;
						sram_ld_addr_n <= 0;
					end
					else begin
						packet_count <= packet_count - 1;
						rd_addr <= rd_addr + 1;
						
						sram_we_n <= 0;
						sram_ld_addr_n <= 0;
						
						sram_d <= {rd_data_a[7:0],rd_data_a[15:8]};
						sram_addr <= sram_addr + 1;
					end
 				end
				
				copy_to_sram_b: begin
				// Internals
					packet_count <= packet_count - 1;
					
				// Outputs
					rd_addr <= rd_addr + 1;
					
					if(packet_count == 0) begin
						sram_we_n <= 1;
						sram_ld_addr_n <= 1;
						
						sram_d <= {rd_data_b[7:0],rd_data_b[15:8]};
						sram_addr <= sram_addr + 1;
					end
					else if(packet_count == data_size) begin
						sram_we_n <= 0;
						sram_ld_addr_n <= 0;
					end
					else begin
						sram_we_n <= 0;
						sram_ld_addr_n <= 0;
						
						sram_d <= {rd_data_b[7:0],rd_data_b[15:8]};
						sram_addr <= sram_addr + 1;
					end
 				end
				
				finish_packet: begin
				// Internals
					clr_regs <= 1;
					
				// Outputs
					if(scan_count == 0) begin
						sram_forming_packet <= 0;
						sram_packet_formed <= 1;
					end
						
					sram_we_n <= 1;
					sram_ld_addr_n <= 1;
				end
			
			endcase
		end
	end

endmodule
