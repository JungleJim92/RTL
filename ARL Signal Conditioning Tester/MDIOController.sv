module MDIOController (
	// System Interface
	input clk_i,
	input rst_i,
	output [31:0] mdio_dbg,
	// NIOS Interface
	input [15:0] ctrl_data,
	input [4:0] reg_addr,
	input write_request,
	output reg [15:0] read_data,
	input read_request,
	output reg op_done,
	// MDIO Interface
	output	MDC,                // MII Management Data Clock
	output	MDO,                // MII Management Data Output
	output	MDIO_oen,           // MII Management Data Output Enable
	input		MDI
);

// Constants
	parameter clk_div = 8'h19;	// Divide 25 MHz clk by 25 to get 1.0 MHz
	parameter phy_addr = 5'b00000;
	parameter us = 25;	// 1 microsecond on 25 MHz clk
	
// Internal Registers
	logic [31:0] t_count;

// MDIO Guts
	logic [15:0] ctrl_data_d;
	logic [15:0] read_data_i;
	logic [4:0] reg_addr_d;
	logic do_write;
	logic do_read;
	logic busy;
	logic link_fail;
	logic nvalid;
	logic write_started;
	logic read_started;
	logic data_valid;
	eth_miim eth_miim_controller (
		.Clk(clk_i),
		.Reset(rst_i),
		.Divider(clk_div),
		.NoPre(1'b0),
		.CtrlData(ctrl_data_d),
		.Rgad(reg_addr_d),
		.Fiad(phy_addr),
		.WCtrlData(do_write),
		.RStat(do_read),
		.ScanStat(1'b0),
		.Mdo(MDO),   
		.MdoEn(MDIO_oen), 
		.Mdi(MDI),   
		.Mdc(MDC),
		.Busy(busy),
		.Prsd(read_data_i),
		.LinkFail(link_fail),
		.Nvalid(nvalid),
		.WCtrlDataStart(write_started),
		.RStatStart(read_started),
		.UpdateMIIRX_DATAReg(data_valid)
	);
	
	logic clr_regs;
	logic do_read_i;
	logic do_write_i;
	input_register in_reg_1(.clk_i(clk_i),.data_i(read_request),.clr_i(clr_regs),.data_o(do_read_i));
	input_register in_reg_2(.clk_i(clk_i),.data_i(write_request),.clr_i(clr_regs),.data_o(do_write_i));
	
// Debug
	logic [31:0] mdio_dbg_temp;
	assign mdio_dbg_temp = {	clk_i,					// 1
										rst_i,					// 2
										do_read_i,				// 3
										do_write_i,				// 4
										op_done,					// 5
										MDC,						// 6
										MDI,						// 7
										MDO,						// 8
										MDIO_oen,				// 9
										busy,						// 10
										link_fail,				// 11
										nvalid,					// 12
										write_started,			// 13
										read_started,			// 14
										data_valid,				// 15
										clr_regs,				// 16
										reg_addr_d,				// 21
										read_data[10:0]		// 32
										};
																
	genvar i;
	generate
		for( i=0; i<32; i=i+1 ) begin : reverse
			assign mdio_dbg[i] = mdio_dbg_temp[31-i];
		end
	endgenerate
	
// Initialization
	initial begin
		t_count <= 0;
		clr_regs <= 0;
		
		ctrl_data_d <= 0;
		reg_addr_d <= 0;
		do_write <= 0;
		do_read <= 0;
		
		op_done <= 0;
	end
	
// State declarations
	enum int unsigned {
		reset,
		initialize,
		
		hold,
		
		write,
		wait_for_write_start,
		
		read,
		wait_for_read_start,
		
		wait_for_busy,
		set_op_done
		
	} s_curr, s_next;
	
// State transitions
	always_ff @(posedge clk_i) begin
		if(rst_i)
			s_curr <= reset;
		else
			s_curr <= s_next;
	end
	
	always_comb begin
		case(s_curr)
			reset: begin
				s_next = initialize;
			end
			
			initialize: begin
				if(t_count >= us*100)
					s_next = hold;
				else
					s_next = initialize;
			end
			
			hold: begin
				if(do_write_i)
					s_next = write;
				else if(do_read_i)
					s_next = read;
				else
					s_next = hold;
			end
			
			write: begin
				s_next = wait_for_write_start;
			end
			
			wait_for_write_start: begin
				if(write_started)
					s_next = wait_for_busy;
				else
					s_next = wait_for_write_start;
			end
			
			read: begin
				s_next = wait_for_read_start;
			end
			
			wait_for_read_start: begin
				if(read_started)
					s_next = wait_for_busy;
				else
					s_next = wait_for_read_start;
			end
			
			wait_for_busy: begin
				if(busy)
					s_next = wait_for_busy;
				else
					s_next = set_op_done;
			end
			
			set_op_done: begin
				s_next = hold;
			end
		endcase
	end
	
	always_ff @(posedge clk_i) begin
		if(rst_i) begin
			t_count <= 0;
			clr_regs <= 0;
			
			ctrl_data_d <= 0;
			reg_addr_d <= 0;
			do_write <= 0;
			do_read <= 0;
			
			op_done <= 0;
		end
		else begin
			t_count <= t_count;
			clr_regs <= clr_regs;
			
			ctrl_data_d <= ctrl_data_d;
			reg_addr_d <= reg_addr_d;
			do_write <= do_write;
			do_read <= do_read;
			
			op_done <= op_done;
			case(s_curr)
				reset: begin
					t_count <= 0;
					clr_regs <= 0;
					
					ctrl_data_d <= 0;
					reg_addr_d <= 0;
					do_write <= 0;
					do_read <= 0;
					
					op_done <= 0;
				end
				
				initialize: begin
					clr_regs <= 1;
					t_count <= t_count + 1;
				end
				
				hold: begin
					clr_regs <= 0;
					op_done <= 0;
				end
				
				write: begin
					clr_regs <= 1;
					
					ctrl_data_d <= ctrl_data;
					reg_addr_d <= reg_addr;
					do_write <= 1;
					op_done <= 0;
				end
				
				wait_for_write_start: begin
					clr_regs <= 0;
				end
				
				read: begin
					clr_regs <= 1;
					
					reg_addr_d <= reg_addr;
					do_read <= 1;
					op_done <= 0;
				end
				
				wait_for_read_start: begin
					clr_regs <= 0;
				end
				
				wait_for_busy: begin
					clr_regs <= 0;
					
					do_write <= 0;
					do_read <= 0;
					
					op_done <= 0;
				end
				
				set_op_done: begin
					op_done <= 1;
					read_data <= read_data_i;
				end
			endcase
		end
	end
	
endmodule
