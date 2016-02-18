//
//  udp_payload_inserter
//
//  This component inserts a predefined raw packet payload into a fully framed
//  UDP packet for transport via Ethernet.  This means that the MAC header, IP
//  header and UDP header are all manufactured and prepended to the raw payload
//  data of the incoming packet.  The input and output for the packet data
//  streamed thru this component are provided by an Avalon ST sink and source
//  interface.  Configuration of this component is provided by an Avalon MM
//  slave interface.
//
//  The standard format of each of the header layers is illustrated below, you
//  can think of each layer being wrapped in the payload section of the layer
//  above it, with the Ethernet packet layout being the outer most wrapper.
//  
//  Standard Ethernet Packet Layout
//  |-------------------------------------------------------|
//  |                Destination MAC Address                |
//  |                           ----------------------------|
//  |                           |                           |
//  |----------------------------                           |
//  |                  Source MAC Address                   |
//  |-------------------------------------------------------|
//  |         EtherType         |                           |
//  |----------------------------                           |
//  |                                                       |
//  |                   Ethernet Payload                    |
//  |                                                       |
//  |-------------------------------------------------------|
//
//  Standard IP Packet Layout
//  |-------------------------------------------------------|
//  | VER  | HLEN |     TOS     |       Total Length        |
//  |-------------------------------------------------------|
//  |       Identification      | FLGS |    FRAG OFFSET     |
//  |-------------------------------------------------------|
//  |     TTL     |    PROTO    |      Header Checksum      |
//  |-------------------------------------------------------|
//  |                   Source IP Address                   |
//  |-------------------------------------------------------|
//  |                Destination IP Address                 |
//  |-------------------------------------------------------|
//  |                                                       |
//  |                      IP Payload                       |
//  |                                                       |
//  |-------------------------------------------------------|
//
//  Standard UDP Packet Layout
//  |-------------------------------------------------------|
//  |      Source UDP Port      |   Destination UDP Port    |
//  |-------------------------------------------------------|
//  |    UDP Message Length     |       UDP Checksum        |
//  |-------------------------------------------------------|
//  |                                                       |
//  |                      UDP Payload                      |
//  |                                                       |
//  |-------------------------------------------------------|
//
//  Proprietary RAW Input Packet Layout
//  |-------------------------------------------------------|
//  |       Packet Length       |                           |
//  |----------------------------                           |
//  |                                                       |
//  |                    Packet Payload                     |
//  |                                                       |
//  |-------------------------------------------------------|
//
//  The general packet assembly flows like this:
//  
//  This component begins by receiving the RAW input packet on its Avalon ST
//  interface, extracting and discarding the Packet Length field after
//  providing the length value to the UDP header layer such that the UDP
//  Message Length is now known.  The UDP Checksum field is zero'ed as this
//  component does not compute the UDP Checksum.  The Source UDP Port and
//  Destination UDP Port are known from user programmable registers within the
//  component.  Once the UDP Message Length is known, this is communicated
//  to the IP header so that the Total Length value is known.  Once the Total
//  Length value is known, the IP Header Checksum is computed.  The Source IP
//  Address and Destination IP Address are known from user programmable
//  registers within the component.  The Protocol field is set to UDP, the TTL
//  field is set to 255, the Fragment Offset field is set to ZERO, the Flags
//  are set to "do not fragment", the Identification field is set to ZERO, the
//  TOS field is set to ZERO, the Header Length field is set to 5, and the
//  Version field is set to 4.  At the MAC layer, the Destination MAC Address
//  and Source MAC Address are known from user programmable registers within
//  the component, and the EtherType field is set to 0x0800 for IPV4.
//  
//  The Ethernet Frame is transmitted out the Avalon ST source interface with
//  the Ethernet MAC header followed by the IP header, followed by the UDP
//  header and finally the RAW input packet payload.  The minimum size of an
//  Ethernet packet is 46 payload bytes, the IP header and UDP header consume
//  28 bytes, so if there are not at least 18 bytes of RAW packet payload, the
//  output packet is padded with up to 18 bytes of UDP Payload such that a
//  valid minimum sized Ethernet packet is transmitted.  The maximum size of
//  the Ethernet payload is 1500 bytes, so the largest valid size for the RAW
//  input packet payload is 1472 bytes, anything larger would result in an
//  invalid Ethernet packet length.  There are no checks built into the
//  hardware of this component that ensure the input packet length is within
//  proper limits, so the user should take care not to exceed packet lengths of
//  1472 bytes for input packet payload.  The minimum valid packet length is
//  ZERO, for the RAW input packet payload.
//
//  ---------------------------------------------------------------------------
//  Register Map
//  ---------------------------------------------------------------------------
//  
//  The slave interface for the udp_payload_inserter is broken up into eight
//  32-bit registers with the following layout:
//  
//  Register 0 - Status Register
//      Bit 0 - R/W - GO control and status bit.  Set this bit to 1 to enable
//                  the payload inserter, and clear it to disable it.
//      Bit 1 - RO  - Running status bit.  This bit indicates whether the
//                  peripheral is currently running or not.  After clearing the
//                  GO bit, you can monitor this status bit to tell when the
//                  inserter is actually stopped.
//      Bit 2 - RO  - Error status bit.  This bit indicates that an error
//                  occurred in the component.  There is only one error
//                  detected by this component, an Avalon ST protocol violation.
//                  When this component is enabled, it expect the first Avalon
//                  ST word that it receives on its sink interface to be the
//                  startofpacket, and when it receives an endofpacket word, it
//                  expects the next word to be the startofpacket for the next
//                  packet.  If this sequencing is not observed, then the Error
//                  status is asserted and the component's GO bit must be
//                  cleared to reset the error condition.
//      
//  Register 1 - Destination MAC HI Register
//      Bits [31:0] - R/W - these are the 32 most significant bits of the
//                  destination MAC address.  MAC bits [47:16].
//                  
//  Register 2 - Destination MAC LO Register
//      Bits [15:0] - R/W - these are the 16 least significant bits of the
//                  destination MAC address.  MAC bits [15:0].
//                  
//  Register 3 - Source MAC HI Register
//      Bits [31:0] - R/W - these are the 32 most significant bits of the
//                  source MAC address.  MAC bits [47:16].
//                  
//  Register 4 - Source MAC LO Register
//      Bits [15:0] - R/W - these are the 16 least significant bits of the
//                  source MAC address.  MAC bits [15:0].
//                  
//  Register 5 - Source IP Address Register
//      Bits [31:0] - R/W - this is the source IP adddress for the IP header
//                  
//  Register 6 - Destination IP Address Register
//      Bits [31:0] - R/W - this is the destination IP adddress for the IP header
//                  
//  Register 7 - UDP Ports Register
//      Bits [15:0]  - R/W - this is the destination UDP port for the UDP header
//      Bits [31:16] - R/W - this is the source UDP port for the UDP header
//                  
//  Register 8 - Packet Count Register
//      Bits [31:0] - R/WC - this is the number of packets that have been
//                  processed since the last reset or clearing of this register.
//                  
//  R - Readable
//  W - Writeable
//  RO - Read Only
//  WC - Clear on Write
//

module udp_payload_inserter (
// clock interface
	input          clk_i,
	input          rst_i,
	input				start_stream,
	input	[15:0]	udp_length,
	input [47:0]	mac_dst_i,
	output[31:0]	udp_stream_dbg,
// source interface
	output			out_valid,
	input				out_ready,
	output[31:0]	out_data,
	output[1:0]		out_empty,
	output			out_sop,
	output			out_eop,
// sink interface
	input				in_valid,
	output			in_ready,
	input [31:0]	in_data,
	input [1:0]		in_empty,
	input				in_sop,
	input				in_eop
);

// States
	localparam [1:0] IDLE           	= 2'd0;
	localparam [1:0] STATE_PW_HEADER	= 2'd1;
	localparam [1:0] STATE_PW_SOP		= 2'd2;
	localparam [1:0] STATE_PW_DATA	= 2'd3;

	localparam [15:0]	MAC_TYPE = 16'h0800;

	localparam [3:0]	IP_VERSION         = 4;
	localparam [3:0]	IP_HEADER_LENGTH   = 5;
	localparam [7:0]	IP_TOS             = 0;
	localparam [15:0]	IP_IDENT           = 0;
	localparam [2:0]	IP_FLAGS           = 2;
	localparam [12:0]	IP_FRAGMENT_OFFSET = 0;
	localparam [7:0]	IP_TTL             = 255;
	localparam [7:0]	IP_PROTOCOL        = 17;

	localparam [15:0]	UDP_CHECKSUM  = 0;
	localparam [15:0]	UDP_SYNC_WORD = 16'h46af;

//	localparam [47:0]	mac_dst = 48'h000ACD1A7C7C;
	localparam [47:0]	mac_dst = 48'hFFFFFFFFFFFF;
	localparam [47:0]	mac_src = 48'h112233445566;

	localparam [31:0]	ip_src_addr = 32'hAC1E1414;
	localparam [31:0]	ip_dst_addr = 32'hAC1E140A;

	localparam [15:0]	udp_src_port = 16'h1122;
	localparam [15:0]	udp_dst_port = 16'h1122;

	wire[31:0]	ip_word_0;
	wire[31:0]	ip_word_1;
	wire[31:0]	ip_word_2;
	wire[31:0]	ip_word_3;
	wire[31:0]	ip_word_4;
	
	wire[15:0]	ip_total_length;
	wire[15:0]	ip_header_checksum;
	
	wire[31:0]	udp_word_0;
	wire[31:0]	udp_word_1;

	wire			running_bit;
	wire[15:0]	first_two_bytes;
	reg [3:0]	header_count;
	reg [15:0]	udp_length_d;
	
	reg [16:0]	ip_header_sum_0;
	reg [16:0]	ip_header_sum_1;
	reg [16:0]	ip_header_sum_2;
	reg [16:0]	ip_header_sum_3;
	reg [16:0]	ip_header_sum_4;
	reg [17:0]	ip_header_sum_a;
	reg [17:0]	ip_header_sum_b;
	reg [18:0]	ip_header_sum_c;
	reg [19:0]	ip_header_sum_d;
	wire[15:0]	ip_header_carry_sum;
	
	wire[31:0]	header_word;
	wire[31:0]	header_word_0;
	wire[31:0]	header_word_1;
	wire[31:0]	header_word_2;
	wire[31:0]	header_word_3;
	wire[31:0]	header_word_4;
	wire[31:0]	header_word_5;
	wire[31:0]	header_word_6;
	wire[31:0]	header_word_7;
	wire[31:0]	header_word_8;
	wire[31:0]	header_word_9;
	wire[31:0]	header_word_10;
	
//	State Declarations
	enum int unsigned {
		reset,
		idle,
		stream_header,
		wait_for_sop,
		stream_data
	} s_curr, s_next;

// misc computations
	assign first_two_bytes      = UDP_SYNC_WORD;
	assign ip_total_length      = udp_length_d + 20;
	assign ip_header_carry_sum  = (ip_header_sum_d[15:0]) + ({{12{1'b0}}, ip_header_sum_d[19:16]});
	assign ip_header_checksum   = ~ip_header_carry_sum;
	
// Debug
	assign running_bit = (s_curr == idle) ? (1'b0) : (1'b1);
	
	wire[31:0] udp_stream_dbg_temp;
	assign udp_stream_dbg_temp = {	clk_i,				// 1
												rst_i,				// 2
												in_valid,			// 3
												in_ready,			// 4
												in_sop,				// 5
												in_eop,				// 6
												in_data[31:16],	// 22
												header_count,		// 26
												running_bit,		// 27
												out_valid,			// 29
												out_ready,			// 30
												out_sop,				// 31
												out_eop				// 32
												};
												
	genvar i;
	generate
		for( i=0; i<32; i=i+1 ) begin : reverse
			assign udp_stream_dbg[i] = udp_stream_dbg_temp[31-i];
		end
	endgenerate

//	Checksum Pipeline
	always_ff @(posedge clk_i) begin
		 if(rst_i) begin
			  ip_header_sum_0 <= 0;
			  ip_header_sum_1 <= 0;
			  ip_header_sum_2 <= 0;
			  ip_header_sum_3 <= 0;
			  ip_header_sum_4 <= 0;

			  ip_header_sum_a <= 0;
			  ip_header_sum_b <= 0;

			  ip_header_sum_c <= 0;

			  ip_header_sum_d <= 0;
		 end
		 else begin
			  // stage 1 of header checksum pipeline
			  ip_header_sum_0 <= ip_word_0[31:16] + ip_word_0[15:0];
			  ip_header_sum_1 <= ip_word_1[31:16] + ip_word_1[15:0];
			  ip_header_sum_2 <= ip_word_2[31:16] + 0;
			  ip_header_sum_3 <= ip_word_3[31:16] + ip_word_3[15:0];
			  ip_header_sum_4 <= ip_word_4[31:16] + ip_word_4[15:0];

			  // stage 2 of header checksum pipeline
			  ip_header_sum_a <= ip_header_sum_0 + ip_header_sum_1;
			  ip_header_sum_b <= ip_header_sum_3 + ip_header_sum_4;

			  // stage 3 of header checksum pipeline
			  ip_header_sum_c <= ip_header_sum_a + ip_header_sum_b;

			  // stage 4 of header checksum pipeline
			  ip_header_sum_d <= ip_header_sum_2 + ip_header_sum_c;
		 end
	end

// IP and UDP header layout
	assign ip_word_0  = {IP_VERSION, IP_HEADER_LENGTH, IP_TOS, ip_total_length};
	assign ip_word_1  = {IP_IDENT, IP_FLAGS, IP_FRAGMENT_OFFSET};
	assign ip_word_2  = {IP_TTL, IP_PROTOCOL, ip_header_checksum};
	assign ip_word_3  = ip_src_addr;
	assign ip_word_4  = ip_dst_addr;
	assign udp_word_0 = {udp_src_port, udp_dst_port};
	assign udp_word_1 = {udp_length_d, UDP_CHECKSUM};

// packet word layout
	assign header_word_0  = mac_dst[47:16];
	assign header_word_1  = {mac_dst[15:0], mac_src[47:32]};
	assign header_word_2  = mac_src[31:0];
	assign header_word_3  = {MAC_TYPE, ip_word_0[31:16]};
	assign header_word_4  = {ip_word_0[15:0], ip_word_1[31:16]};
	assign header_word_5  = {ip_word_1[15:0], ip_word_2[31:16]};
	assign header_word_6  = {ip_word_2[15:0], ip_word_3[31:16]};
	assign header_word_7  = {ip_word_3[15:0], ip_word_4[31:16]};
	assign header_word_8  = {ip_word_4[15:0], udp_word_0[31:16]};
	assign header_word_9  = {udp_word_0[15:0], udp_word_1[31:16]};
	assign header_word_10 = {udp_word_1[15:0], first_two_bytes};
	
	/*assign header_word_0  = {16'h0000,mac_dst[47:32]};
	assign header_word_1  = mac_dst[31:0];
	assign header_word_2  = mac_src[47:16];
	assign header_word_3  = {mac_src[15:0], MAC_TYPE};
	assign header_word_4  = ip_word_0;
	assign header_word_5  = ip_word_1;
	assign header_word_6  = ip_word_2;
	assign header_word_7  = ip_word_3;
	assign header_word_8  = ip_word_4;
	assign header_word_9  = udp_word_0;
	assign header_word_10 = udp_word_1;*/
	
	assign header_word = (header_count == 0)	? (header_word_0) :
								(header_count == 1)	? (header_word_1) :
								(header_count == 2)	? (header_word_2) :
								(header_count == 3)	? (header_word_3) :
								(header_count == 4)	? (header_word_4) :
								(header_count == 5)	? (header_word_5) :
								(header_count == 6)	? (header_word_6) :
								(header_count == 7)	? (header_word_7) :
								(header_count == 8)	? (header_word_8) :
								(header_count == 9)	? (header_word_9) :
								(header_count == 10)	? (header_word_10) :
								(32'h00000000);
							
//	Input Assignments
	assign in_ready =	((s_curr == stream_data) || (s_curr == wait_for_sop) || ((s_curr == stream_header) && (header_count == 10))) && (out_ready) && (!in_eop);
	
//	Output Assignments
	assign out_data 	= (s_curr == stream_header)	? header_word : in_data;
	
	assign out_valid	= (s_curr == stream_header)	? 1'b1 :
							  (s_curr == wait_for_sop)		? (in_valid && in_sop) :
							  (s_curr == stream_data)		? in_valid : 1'b0;
							  
	assign out_sop 	= (s_curr == stream_header) && (header_count == 0);
	
	assign out_eop 	= (s_curr == stream_data) ? in_eop : 1'b0;
	
	assign out_empty	= 2'b00;
	
	always_ff @(posedge clk_i) begin
		if(rst_i)
			s_curr <= reset;
		else
			s_curr <= s_next;
	end
	
	always_comb begin
		case(s_curr)
			reset:
				s_next = idle;
				
			idle:
				if(start_stream)
					s_next = stream_header;
				else
					s_next = idle;
					
			stream_header:
				if(header_count >= 10)
					s_next = stream_data;
				else
					s_next = stream_header;
					
			wait_for_sop:
				if(in_sop)
					s_next = stream_data;
				else
					s_next = wait_for_sop;
					
			stream_data:
				if(in_eop)
					s_next = idle;
				else
					s_next = stream_data;
		endcase
	end
							
	always_ff @(posedge clk_i) begin
		if(rst_i) begin
			header_count	<= 0;
			udp_length_d 	<= 0;
		end
		else begin
			header_count	<= header_count;
			udp_length_d 	<= udp_length;
			case(s_curr)
				reset: begin
					header_count	<= 0;
					udp_length_d 	<= 0;
				end
				
				idle: begin
					if(start_stream) begin
						header_count	<= 0;
						udp_length_d 	<= udp_length;
					end
				end
				
				stream_header: begin
					header_count	<= header_count+1;
				end
				
				wait_for_sop: ;
				
				stream_data: ;
				
			endcase
		end
	end


endmodule
