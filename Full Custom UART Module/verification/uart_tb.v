// uart_tb.v
// Brandon Boesch
// Josh Randall
// James Schulman

// EE 382M.7 - VLSI1
// Nov 28th, 2015

//-----------------------------------------------------
// Top Level Testbench
//-----------------------------------------------------
// Functionality:
// This testbench will simulate and verify tx and rx
// functionality of top level UART module.

module uart_tb;
	reg			clk_i;
	reg			rst_i;
	reg [2:0]	baud_rate;
	
	reg			ld_tx_data;
	reg [7:0]	tx_data;
	wire		tx_full;
	
	reg			ld_rx_data;
	wire[7:0]	rx_data;
	wire		rx_empty;
	
//	Serial link from TX to RX
//	(Loopback mode)
	wire d;
		
	uart u1 (
		.clk_i(clk_i),	
	    .rst_i(rst_i),
		.baud_rate_i(baud_rate),
	    .ld_tx_data(ld_tx_data),
	    .tx_data(tx_data),
	    .tx_d(d),
	    .tx_full(tx_full),
	    .ld_rx_data(ld_rx_data),
	    .rx_data(rx_data),
	    .rx_d(d),
	    .rx_empty(rx_empty)
	);
	
	integer clk_delay = 10;
	
//	Clock Initialization
	initial begin
		clk_i = 0;
		
		forever begin
			#clk_delay;
			clk_i = ~clk_i;
		end
	end
	
	integer rst_delay = 60;
	
//	Reset Initialization
	initial begin
		rst_i = 0;
		#rst_delay
		rst_i = 1;
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
		baud_rate = 3'b111;
	
		$display("Starting top level testbench");
		$display("\tcreated by THE James Schulman");
	
		$display("\nWaiting for reset to deassert...");
		wait(rst_i == 1);
		$display("Done.");
		
		baud_rate = 3'b111;
		
		#500000;
		
		baud_rate = 3'b110;
		
		#500000;
		
		baud_rate = 3'b101;
		
		#500000;
		
		wait(clk_i == 0);
		wait(clk_i == 1);
		wait(clk_i == 0);
		
		$display("Loading 0x5A into TX FIFO");
		tx_data		= 8'h5A;
		ld_tx_data	= 1;
		
		wait(clk_i == 1);
		wait(clk_i == 0);
		
		ld_tx_data = 0;
		
		$display("Waiting for RX module...");
		
		while(rx_empty) begin
			wait(clk_i == 1);
			wait(clk_i == 0);
		end
		
		$display("Data received");
		$display("Reading data from FIFO");
		
		ld_rx_data = 1;
		
		wait(clk_i == 1);
		wait(clk_i == 0);
		
		ld_rx_data = 0;
		
		if(rx_data == 8'h5A)
			$display("COMM SUCCESS");
		else
			$display("COMM FAILURE");
		$display("Received: 0x%x",rx_data);
		
		wait(clk_i == 1);
		wait(clk_i == 0);
		
		for(i = 0; i < 4; i = i+1) begin
			$display("Loading TX FIFO with 0x%x",test_data[i]);
			
			tx_data = test_data[i];
			ld_tx_data = 1;
			
			wait(clk_i == 1);
			wait(clk_i == 0);
		end
		
		$display("Done.");
		ld_tx_data = 0;
		
		wait(clk_i == 1);
		wait(clk_i == 0);
		
		for(i = 0; i < 4; i = i+1) begin
			$display("Waiting for RX module...");
			
			while(rx_empty) begin
				wait(clk_i == 1);
				wait(clk_i == 0);
			end
			
			$display("Data received");
			$display("Reading data from FIFO");
			
			ld_rx_data = 1;
			
			wait(clk_i == 1);
			wait(clk_i == 0);
			
			ld_rx_data = 0;
			
			if(rx_data == test_data[i])
				$display("COMM SUCCESS");
			else
				$display("COMM FAILURE");
			$display("Received: 0x%x",rx_data);
			ld_rx_data = 0;
		end
		
		$display("Done with simulation");
		
	end
	
endmodule
