// uart_rx_tb.v
// Brandon Boesch
// Josh Randall
// James Schulman

// EE 382M.7 - VLSI1
// Nov 28th, 2015

//-----------------------------------------------------
// Top Level Testbench
//-----------------------------------------------------
// Functionality:
// This testbench will simulate and verify functionality
// of uart rx module.

module rx_tb;
reg			rst;
reg			rx_clk;
reg         ext_clk;
reg[2:0]    clk_cnt;
reg			rx_data_in;
reg			rx_en;
reg			rx_req;
wire[7:0]	rx_data_out;
wire		rx_empty;
		
	rx u1 (
		.rst(rst),
		.rx_clk(rx_clk),
		.rx_data_in(rx_data_in),
		.rx_en(rx_en),
		.rx_req(rx_req),
		.rx_data_out(rx_data_out),
		.rx_empty(rx_empty)
	);
	
	integer clk_delay = 10;
	
//	Clock Initialization
	initial begin
		rx_clk = 0;
		clk_cnt = 0;
        ext_clk = 0;
		forever begin
			#clk_delay;
			rx_clk = ~rx_clk;
            clk_cnt = clk_cnt + 1;
            if(clk_cnt == 3'b111)
            begin
                ext_clk = ~ext_clk;
            end
		end
	end
	
	integer rst_delay = 60;
	
//	Reset Initialization
	initial begin
		rst = 0;
		#rst_delay
		rst = 1;
	end
	
	integer i;
	integer j;
	reg [7:0] test_data [0:3];
	
//	Test Initialization
	initial begin
		test_data[0] = 8'h88;
		test_data[1] = 8'h44;
		test_data[2] = 8'h22;
		test_data[3] = 8'h11;
	end
	
//	Test Program
	initial begin
		rx_data_in	= 1;
		rx_en		= 1;
		rx_req		= 0;
	
		$display("Starting rx module testbench");
		$display("\tcreated by THE James Schulman");
	
		$display("\nWaiting for reset to deassert...");
		wait(rst == 1);
		$display("Done.");
		
		wait(ext_clk == 0);
		wait(ext_clk == 1);
		
		$display("Starting rx test");
		$display("This test will transmit one byte at a time, wait for fifo to get value, read value out of FIFO and verify it is what we sent");
		
		for(i = 0; i < 4; i = i+1) begin
			$display("Simulating transmit of 0x%x",test_data[i]);
			rx_data_in = 0;
			
			wait(ext_clk == 0);
			wait(ext_clk == 1);
			
			for(j = 0; j < 8; j = j+1) begin
				rx_data_in = test_data[i][j];
		
				wait(ext_clk == 0);
				wait(ext_clk == 1);
			end
			
			$display("Transmit complete");
			$display("Waiting for rx_empty to deassert...");
			
			rx_data_in = 1;
		
			wait(rx_empty == 0);
			wait(ext_clk == 0);
			wait(ext_clk == 1);
			
			rx_req = 1;
			
			wait(ext_clk == 0);
			wait(ext_clk == 1);
			
			rx_req = 0;
			
			if(rx_data_out == test_data[i])
				$display("COMM SUCCESS");
			else
				$display("COMM FAILURE");
			$display("Received: 0x%x",rx_data_out);
			
			wait(ext_clk == 0);
			wait(ext_clk == 1);
		end
		
		$display("This test will transmit four bytes, then read all values out of FIFO and verify it is what we sent");
		
		for(i = 0; i < 4; i = i+1) begin
			$display("Simulating transmit of 0x%x",test_data[i]);
			rx_data_in = 0;
			
			wait(ext_clk == 0);
			wait(ext_clk == 1);
			
			for(j = 0; j < 8; j = j+1) begin
				rx_data_in = test_data[i][j];
		
				wait(ext_clk == 0);
				wait(ext_clk == 1);
			end
			
			rx_data_in = 1;
			
			$display("Transmit complete");
			
//			$display("Waiting %d clock cycles",i+1);
//			j = 0;
//			while(j <= i) begin
//				wait(ext_clk == 0);
//				wait(ext_clk == 1);
//				j = j+1;
//			end
		
			wait(ext_clk == 0);
			wait(ext_clk == 1);
		end
		
		$display("Simulating read of FIFO data");
		$display("rx_req will be high for 4 clock cycles");
		
		rx_req = 1;
			
		wait(ext_clk == 0);
		wait(ext_clk == 1);
		
		repeat(4) begin
			if(rx_empty)
				$display("Error, FIFO is unexpectedly empty");
				
			if(rx_data_out == test_data[i])
				$display("COMM SUCCESS");
			else
				$display("COMM FAILURE");
			$display("Received: 0x%x",rx_data_out);
			
			wait(ext_clk == 0);
			wait(ext_clk == 1);
		end
		
		$finish;
		
	end
	
endmodule
