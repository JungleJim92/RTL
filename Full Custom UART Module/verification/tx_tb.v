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

module tx_tb;

	reg			clk;
	reg			rst;
	reg			data_valid;
	reg[7:0]	data_in;
	wire		tx;
	wire		rdy_4_data;
	wire		transmitting;
	
	txlogic t1 (	
		.clk(clk),
		.rst(rst),
		.data_in(data_in),
		.data_valid(data_valid),
		.rdy_4_data(rdy_4_data),
		.transmitting(transmitting),
		.tx(tx)
	);
	
	integer clk_delay = 10;
	
//	Clock Initialization
	initial begin
		clk = 0;
		
		forever begin
			#clk_delay;
			clk = ~clk;
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
	reg [7:0] read_data;
	
//	Test Initialization
	initial begin
		test_data[0] = 8'h88;
		test_data[1] = 8'h44;
		test_data[2] = 8'h22;
		test_data[3] = 8'h11;
	end
	
//	Test Program
	initial begin
		data_valid = 0;
		data_in = 0;
		read_data = 0;
	
		$display("Starting tx module testbench");
		$display("\tcreated by THE James Schulman");
	
		$display("\nWaiting for reset to deassert...");
		wait(rst == 1);
		$display("Done.");
		
		wait(clk == 0);
		wait(clk == 1);
		wait(clk == 0);
		
		$display("Starting tx test");
		$display("This test will transmit one byte at a time and wait for the serial output");
		
		for(i = 0; i < 4; i = i+1) begin
			$display("Waiting for rdy_4_data...");
			
			wait(rdy_4_data == 1);
			
			$display("Ready.");
			
			wait(clk == 1);
			wait(clk == 0);
			
			$display("Simulating transmit of 0x%x",test_data[i]);
			data_valid = 1;
			data_in = test_data[i];
			
			wait(clk == 1);
			wait(clk == 0);
			
			data_valid = 0;
			
			$display("Waiting for start bit...");
			
			while(tx == 1) begin
				wait(clk == 1);
				wait(clk == 0);
			end
			
			$display("Found it.");
			
			wait(clk == 1);
			wait(clk == 0);
			
			for(j = 0; j < 8; j = j+1) begin
				read_data[j] = tx;
			
				wait(clk == 1);
				wait(clk == 0);
			end
			
			$display("Transmit finished");
			$display("Read data = 0x%x",read_data);
			
			if(read_data == test_data[i])
				$display("COMM SUCCESS");
			else
				$display("COMM FAILURE");
			
		end
		
		$display("Testing done");
		
		$finish;
		
	end
	
endmodule
