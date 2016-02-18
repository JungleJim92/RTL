// txlogic.v
// Brandon Boesch
// Josh Randall
// James Schulman

// EE 382M.7 - VLSI1
// Nov 28th, 2015

//-----------------------------------------------------------------------
// Transmit Logic Module 
//-----------------------------------------------------------------------
// Functionality:
// Successively reads words from the UART transmit FIFO and performs parallel to 
// serial conversion on the word. It then sends the serial data stream along with
// start and stop bits on the tx line

module txlogic(clk, rst, data_in, data_valid, transmitting, tx);

  parameter DATA_WIDTH = 8; 

  input clk;
  input rst;
  input data_valid;
  input [DATA_WIDTH-1:0]data_in;  // parallel data received from TX FIFO
  
  output reg tx;                  // 1bit serial tx data output     
  output reg transmitting;        // set true during transmissions

  reg [3:0]cnt;
  reg [DATA_WIDTH-1:0]temp_mem;

  always @(posedge clk, negedge rst) begin
    if(!rst) begin
      cnt <= 0;
      tx <= 1;
      transmitting <= 0;
    end
    else begin
      if(data_valid && !transmitting) begin
        temp_mem <= data_in;
        transmitting <= 1;
        cnt <= cnt + 1;
        tx <= 0; // start bit set at beggining of transmission
      end
      else if(transmitting) begin
        cnt <= cnt + 1; 
        if(cnt < 9)   tx <= temp_mem[cnt - 1];  // send out 8 data bits.Least sig first
        else if(cnt == 9) begin
          tx  <= 1;                             // stop bit at end of transmission
          cnt <= 0;                       
          transmitting <= 0;                    // transmission finished
        end
      end
    end
  end
endmodule





