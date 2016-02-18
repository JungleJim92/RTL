module EthernetPhyInterface (
	// Control Interface
	input clk_i,
	input clk_125,
	input rst_i,
	input packet_formed,
	input [31:0] num_scans,
	output reg eth_forming_packet,
	output [31:0] eth_dbg,
	// SRAM Interface
	output reg [19:0] sram_addr,
	input [15:0] sram_data,
	// Transmit Interface
	output [7:0] tx_data,
	output tx_en,
	output reg tx_er,
	// Receive Interface
	input rx_clk,
	input [7:0] rx_data,
	input rx_dv,
	input rx_er,
	// Status Signals
	input crs,
	input col,
	input int_n,
	// Reference Clocks
	input tx_clk,
	input clk_125_ndo
);

	// Sending to IP Address 172.30.20.20
	// Source IP 172.30.20.10
	// Port 7755 both ways

	parameter scan_size = 52;	// A packet size is 104 bytes
	parameter header_size = 25;
	parameter eth_crc = 32'h00000000;
	
	logic [31:0] fifo_count;
	logic [31:0] num_scans_d;
	
	logic packet_ready;
	logic sending_packet;
	
	// Modules
	logic [15:0] fifo_d;
	logic [15:0] fifo_d_i;
	logic [7:0] fifo_q;
	logic rdempty;
	logic wrreq;
	logic wrfull;
	logic rdreq;
	
	assign fifo_d_i = {fifo_d[7:0], fifo_d[15:8]};
	
	EthernetFIFO eth_fifo(
		.data(fifo_d_i),
		.rdclk(tx_clk),
		.rdreq(rdreq),
		.wrclk(clk_i),
		.wrreq(wrreq),
		.q(fifo_q),
		.rdempty(rdempty),
		.wrfull(wrfull)
	);
	
	EthernetBlaster eth_blaster(
		.clk_i(tx_clk),
		.rst_i(rst_i),
		.send_packet(packet_ready),
		.sending_packet(sending_packet),
		.rd_data(fifo_q),
		.rdreq(rdreq),
		.rd_empty(rdempty),
		.tx_data(tx_data),
		.tx_en(tx_en)
	);
	
	logic [5:0] rom_addr;
	logic [15:0] rom_data;
	EthernetHeaderROM eth_rom(
		.address(rom_addr),
		.clock(clk_i),
		.q(rom_data)
	);
		
	logic clr_regs;
	logic packet_formed_d;
	input_register in_reg_1(.clk_i(clk_i),.data_i(packet_formed),.clr_i(clr_regs),.data_o(packet_formed_d));
	
	logic clr_crc;
	logic [15:0] crc_in;
	logic do_crc;
	logic [31:0] crc_out;
	crc32_d16 crc_builder(
		.clk(clk_i),
		.rst(clr_crc),
		.data_in(crc_in),
		.crc_en(do_crc),
		.crc_out(crc_out)
	);
	
// Debug
	logic [31:0] eth_dbg_temp;
	assign eth_dbg_temp = {	clk_i,						// 1
									packet_formed,				// 2
									eth_forming_packet,		// 3
									tx_clk,						// 4
									tx_data,						// 12
									tx_en,						// 13
									fifo_q,						// 21
									rdreq,						// 22
									packet_ready,				// 23
									sending_packet,			// 24
									8'b00000000					// 32
									};
									
	genvar i2;
	generate
		for( i2=0; i2<32; i2=i2+1 ) begin : reverse2
			assign eth_dbg[i2] = eth_dbg_temp[31-i2];
		end
	endgenerate
									
// State declarations
	enum int unsigned {
		reset,
		
		hold,
		new_ping,
		trans1,
		fill_header,
		trans2,
		fill_fifo,
		trans3,
		fill_crc,
		send_packet,
		eth_blaster_busy
		
	} s_current, s_next;
	
	initial begin
		fifo_count <= 0;
		num_scans_d <= 0;
		
		clr_crc <= 0;
		crc_in <= 0;
		do_crc <= 0;
		
		fifo_d <= 0;
		wrreq <= 0;
		clr_regs <= 0;
		packet_ready <= 0;
		rom_addr <= 0;
		
		eth_forming_packet <= 0;
		sram_addr <= 0;
		tx_er <= 0;
	end
	
	always_ff @(posedge clk_i) begin
		if(rst_i)
			s_current <= reset;
		else
			s_current <= s_next;
	end
	
	always_comb begin
		case(s_current)
			reset: begin
				s_next = hold;
			end
			
			hold: begin
				if(packet_formed_d)
					s_next = new_ping;
				else
					s_next = hold;
			end
			
			new_ping: begin
				s_next = trans1;
			end
			
			trans1: begin
				s_next = fill_header;
			end
			
			fill_header: begin
				if(fifo_count < header_size)
					s_next = fill_header;
				else
					s_next = trans2;
			end
			
			trans2: begin
				s_next = fill_fifo;
			end
			
			fill_fifo: begin
				if(fifo_count < scan_size * 1)
					s_next = fill_fifo;
				else
					s_next = trans3;
			end
			
			trans3: begin
				s_next = fill_crc;
			end
			
			fill_crc: begin
				if(fifo_count < 2)
					s_next = fill_crc;
				else
					s_next = send_packet;
			end
			
			send_packet: begin
				if(sending_packet)
					s_next = eth_blaster_busy;
				else
					s_next = send_packet;
			end
			
			eth_blaster_busy: begin
				if(!sending_packet) begin
					if(num_scans_d == 0)
						s_next = hold;
					else
						s_next = trans1;
				end
				else
					s_next = eth_blaster_busy;
			end
		endcase
	end
	
	always_ff @(posedge clk_i) begin
		if(rst_i) begin
			fifo_count <= 0;
			num_scans_d <= 0;
		
			clr_crc <= 0;
			crc_in <= 0;
			do_crc <= 0;
			
			fifo_d <= 0;
			wrreq <= 0;
			clr_regs <= 0;
			packet_ready <= 0;
			rom_addr <= 0;
			
			eth_forming_packet <= 0;
			sram_addr <= 0;
			tx_er <= 0;
		end
		else begin
			fifo_count <= fifo_count;
			num_scans_d <= num_scans_d;
		
			clr_crc <= clr_crc;
			crc_in <= crc_in;
			do_crc <= do_crc;
			
			fifo_d <= fifo_d;
			wrreq <= wrreq;
			clr_regs <= clr_regs;
			packet_ready <= packet_ready;
			rom_addr <= rom_addr;
			
			eth_forming_packet <= eth_forming_packet;
			sram_addr <= sram_addr;
			tx_er <= tx_er;
			case(s_current)
				reset: begin
					fifo_count <= 0;
					num_scans_d <= 0;
		
					clr_crc <= 1;
					crc_in <= 0;
					do_crc <= 0;
					
					fifo_d <= 0;
					wrreq <= 0;
					clr_regs <= 0;
					packet_ready <= 0;
					rom_addr <= 0;
					
					eth_forming_packet <= 0;
					sram_addr <= 0;
					tx_er <= 0;
				end
				
				hold: begin
					fifo_count <= 0;
		
					clr_crc <= 0;
					crc_in <= 0;
					do_crc <= 0;
					
					fifo_d <= 0;
					wrreq <= 0;
					clr_regs <= 0;
					
					eth_forming_packet <= 0;
					sram_addr <= 0;
					tx_er <= 0;
				end
				
				new_ping: begin
					clr_regs <= 1;
					sram_addr <= 0;
					num_scans_d <= num_scans;
					rom_addr <= 0;
					
					eth_forming_packet <= 1;
					wrreq <= 0;
				end
				
				trans1: begin
					num_scans_d <= num_scans_d - 1;
					clr_regs <= 0;
					fifo_count <= 0;
					rom_addr <= 1;
					
					clr_crc <= 1;
					do_crc <= 0;
					
					wrreq <= 0;
				end
				
				fill_header: begin
					fifo_count <= fifo_count + 1;
					rom_addr <= rom_addr + 1;
					fifo_d <= rom_data;
					
					crc_in <= rom_data;
					do_crc <= 1;
					
					clr_crc <= 0;
					
					wrreq <= 1;
				end
				
				trans2: begin
					clr_regs <= 0;
					fifo_count <= 0;
					
					do_crc <= 0;
					
					wrreq <= 0;
				end
				
				fill_fifo: begin
					fifo_count <= fifo_count + 1;
					fifo_d <= sram_data;
					sram_addr <= sram_addr + 1;
					
					crc_in <= sram_data;
					do_crc <= 1;
					
					wrreq <= 1;
				end
				
				trans3: begin
					clr_regs <= 0;
					fifo_count <= 0;
					
					do_crc <= 0;
					
					wrreq <= 0;
				end
				
				fill_crc: begin
					fifo_count <= fifo_count + 1;
					if(fifo_count == 0)
						fifo_d <= crc_out[31:16];
					else
						fifo_d <= crc_out[15:0];
					
					wrreq <= 1;
				end
				
				send_packet: begin
					packet_ready <= 1;
					
					wrreq <= 0;
				end
				
				eth_blaster_busy: begin
					packet_ready <= 0;
				end
			endcase
		end
	end
	
endmodule

module EthernetBlaster(
	// Control Interface
	input clk_i,
	input rst_i,
	input send_packet,
	output reg sending_packet,
	// FIFO Interface
	input [7:0] rd_data,
	output reg rdreq,
	input rd_empty,
	// PHY Interface
	output reg [7:0] tx_data,
	output reg tx_en
);

	logic [1:0] skip_count;
	
	logic [7:0] tx_data_d;
		
	logic clr_regs;
	logic send_packet_d;
	logic rd_empty_d;
	input_register in_reg_1(.clk_i(clk_i),.data_i(send_packet),.clr_i(clr_regs),.data_o(send_packet_d));
	input_register in_reg_2(.clk_i(clk_i),.data_i(rd_empty),.clr_i(clr_regs),.data_o(rd_empty_d));

	initial begin
		clr_regs <= 0;
		skip_count <= 0;
		
		sending_packet <= 0;
		rdreq <= 0;
		tx_data_d <= 0;
		tx_en <= 0;
	end
	
// State declarations
	enum int unsigned {
		reset,
		
		clear,
		hold,
		trans1,
		transmit
		
	} s_current, s_next;
	
	
	always_ff @(posedge clk_i) begin
		tx_data <= tx_data_d;
	end
	
	always_ff @(posedge clk_i) begin
		if(rst_i)
			s_current <= reset;
		else
			s_current <= s_next;
	end
	
	always_comb begin
		case(s_current)
			reset:
				s_next = clear;
				
			clear:
				s_next = hold;
				
			hold: begin
				if(send_packet_d)
					s_next = trans1;
				else
					s_next = hold;
			end
			
			trans1:
				s_next = transmit;
				
			transmit: begin
				if(rd_empty_d)
					s_next = hold;
				else
					s_next = transmit;
			end
		endcase
	end
	
	always_ff @(posedge clk_i) begin
		if(rst_i) begin
			clr_regs <= 0;
			skip_count <= 0;
			
			sending_packet <= 0;
			rdreq <= 0;
			tx_data_d <= 0;
			tx_en <= 0;
		end
		else begin
			clr_regs <= clr_regs;
			skip_count <= skip_count;
			
			sending_packet <= sending_packet;
			rdreq <= rdreq;
			tx_data_d <= tx_data_d;
			tx_en <= tx_en;
			
			case(s_current)
				reset: begin
					clr_regs <= 0;
					skip_count <= 0;
					
					sending_packet <= 0;
					rdreq <= 0;
					tx_data_d <= 0;
					tx_en <= 0;
				end
				
				clear: begin
					clr_regs <= 1;
				end
				
				hold: begin
					clr_regs <= 0;
					skip_count <= 0;
					
					sending_packet <= 0;
					rdreq <= 0;
					tx_data_d <= 0;
					tx_en <= 0;
				end
				
				trans1: begin
					sending_packet <= 1;
					clr_regs <= 1;
					rdreq <= 1;
					skip_count <= 0;
				end
				
				transmit: begin
					if(!rd_empty_d) begin
						clr_regs <= 0;
						tx_data_d <= rd_data;
						if(skip_count < 2) begin
							tx_en <= 0;
							skip_count <= skip_count + 1;
						end
						else begin
							if(rd_empty)
								tx_en <= 0;
							else
								tx_en <= 1;
						end
						rdreq <= 1;
					end
					else begin
						clr_regs <= 1;
						tx_data_d <= 0;
						tx_en <= 0;
						rdreq <= 0;
					end
				end
			endcase
		end
	end

endmodule
