module EthPacketBuilder (
// System Interface
	input 			clk_i,
	input 			rst_i,
	input 			ping_i,
	input 			sram_ready,
	input [31:0]	num_scans,
	output reg 		eth_packet_forming,
	output reg		start_stream,
	output reg [15:0]		udp_length,
	output [31:0]	eth_stream_dbg,
// Payload Inserter Interface
	output reg			src_valid,
	input					src_ready,
	output reg [31:0]	src_data,
	output reg [1:0]	src_empty,
	output reg			src_sop,
	output reg			src_eop,
// SRAM Interface
	output reg [19:0]	sram_addr,
	input [15:0] 		sram_data
);

// Constants
	parameter scan_size = 52;	// A packet size is 104 bytes, or 52 words

// Internal Registers
	logic [31:0] num_scans_d;
	logic [4:0] scan_size_d;
	logic new_packet;

// Clock Crossing Registers
	logic clr_regs;
	logic sram_ready_d;
	input_register in_reg1(.clk_i(clk_i),.data_i(sram_ready),.clr_i(clr_regs),.data_o(sram_ready_d));
	
	logic ping_d;
	input_register in_reg2(.clk_i(clk_i),.data_i(ping_i),.clr_i(clr_regs),.data_o(ping_d));
	
// Debug
	logic [31:0] eth_stream_dbg_temp;
	assign eth_stream_dbg_temp = {	clk_i,						// 1
												rst_i,						// 2
												ping_d,						// 3
												sram_ready_d,				// 4
												eth_packet_forming,		// 5
												start_stream,				// 6
												src_valid,					// 7
												src_ready,					// 8
												src_sop,						// 9
												src_eop,						// 10
												src_data[15:0],			// 26
												sram_addr[5:0]				// 32
											};
											
	genvar i;
	generate
		for( i=0; i<32; i=i+1 ) begin : reverse
			assign eth_stream_dbg[i] = eth_stream_dbg_temp[31-i];
		end
	endgenerate

// States
	enum int unsigned {
		reset,
		wait_for_ping,
		wait_for_packet,
		trans1,
		stream_scan
	} s_curr, s_next;
	
// Initialization
	initial begin
		scan_size_d <= 0;
		num_scans_d <= 0;
		new_packet <= 0;
		clr_regs <= 0;
		
		eth_packet_forming <= 0;
		start_stream <= 0;
		udp_length <= 0;
		
		src_valid <= 0;
		src_data <= 0;
		src_empty <= 0;
		src_sop <= 0;
		src_eop <= 0;
		
		sram_addr <= 0;
	end
	
// State Transition
	always @(posedge clk_i) begin
		if(rst_i)
			s_curr <= reset;
		else
			s_curr <= s_next;
	end

// Next State Logic
	always_comb begin
		case(s_curr)
			reset:
				s_next = wait_for_ping;
			wait_for_ping:
				if(ping_d)
					s_next = wait_for_packet;
				else
					s_next = wait_for_ping;
			wait_for_packet:
				if(sram_ready_d)
					s_next = trans1;
				else
					s_next = wait_for_packet;
			trans1:
				s_next = stream_scan;
			stream_scan:
				if(scan_size_d == 0)
					if(num_scans_d == 0)
						s_next = wait_for_ping;
					else
						s_next = trans1;
				else
					s_next = stream_scan;
		endcase
	end
	
// Synchronous Logic
	always_ff @(posedge clk_i) begin
		if(rst_i) begin
			scan_size_d <= 0;
			num_scans_d <= 0;
			new_packet <= 0;
			clr_regs <= 0;
			
			eth_packet_forming <= 0;
			start_stream <= 0;
			udp_length <= 0;
				
			src_valid <= 0;
			src_data <= 0;
			src_empty <= 0;
			src_sop <= 0;
			src_eop <= 0;
			
			sram_addr <= 0;
		end
		else begin
			scan_size_d <= scan_size_d;
			num_scans_d <= num_scans_d;
			new_packet <= new_packet;
			clr_regs <= clr_regs;
					
			eth_packet_forming <= eth_packet_forming;
			start_stream <= start_stream;
			udp_length <= udp_length;
			
			src_valid <= src_valid;
			src_data <= src_data;
			src_empty <= src_empty;
			src_sop <= src_sop;
			src_eop <= src_eop;
					
			sram_addr <= sram_addr;
			case(s_curr)
				reset: begin
					scan_size_d <= 0;
					num_scans_d <= 0;
					new_packet <= 0;
					clr_regs <= 0;
					
					eth_packet_forming <= 0;
					start_stream <= 0;
					udp_length <= 0;
					
					src_valid <= 0;
					src_data <= 0;
					src_empty <= 0;
					src_sop <= 0;
					src_eop <= 0;
					
					sram_addr <= 0;
				end
				
				wait_for_ping: begin
					eth_packet_forming <= 0;
					
					src_sop <= 0;
					src_eop <= 0;
					src_valid <= 0;
					if(ping_d)
						num_scans_d <= num_scans;
				end
				
				wait_for_packet: begin
					if(sram_ready_d) begin
						eth_packet_forming <= 1;
						clr_regs <= 1;
						sram_addr <= 0;
					end
				end
				
				trans1: begin
					clr_regs <= 0;
					new_packet <= 1;
					
					start_stream <= 1;
					udp_length <= scan_size/2;
					
					num_scans_d <= num_scans_d-1;
					scan_size_d <= scan_size-1;
					
					src_sop <= 0;
					src_eop <= 0;
					src_valid <= 0;
				end
				
				stream_scan: begin
					start_stream <= 0;
					if(src_ready) begin
						sram_addr <= sram_addr+1;
						scan_size_d <= scan_size_d-1;
						if(scan_size_d[0] == 1) begin
							src_valid <= 0;
							src_sop <= 0;
							src_eop <= 0;
							src_data[31:16] <= sram_data;
						end
						else begin
							src_valid <= 1;
							src_data[15:0] <= sram_data;
							
							if(new_packet) begin
								src_sop <= 1;
								src_eop <= 0;
								new_packet <= 0;
							end
							else if(scan_size_d == 0) begin
								src_sop <= 0;
								src_eop <= 1;
							end
							else begin
								src_sop <= 0;
								src_eop <= 0;
							end
						end
					end
					else begin
						src_valid <= 0;
						src_sop <= 0;
						src_eop <= 0;
					end
				end
			endcase
		end
	end

endmodule
