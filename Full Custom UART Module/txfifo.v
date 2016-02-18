// txfifo.v
// Brandon Boesch
// Josh Randall
// James Schulman

// EE 382M.7 - VLSI1
// Nov 28th, 2015

//-----------------------------------------------------------------------
// UART TX FIFO Module 
//-----------------------------------------------------------------------
// Functionality:
// UART FIFO memory buffer with synchronous reset.  Data will remain 
// in the buffer until read out.  When the FIFO is full, it will generate 
// an interupt signal.

module txfifo(clk, rst, data_in, ld_tx_fifo, transmitting, data_out, data_valid, full);

  parameter DATA_WIDTH = 8;  
  parameter ADDR_WIDTH = 2;
  parameter FIFO_DEPTH = (1 << ADDR_WIDTH);  // how many elements the fifo can hold

  input clk;
  input rst;
  input ld_tx_fifo;
  input transmitting;
  input [DATA_WIDTH-1:0]data_in;

  output reg data_valid;  
  output full;                                   // true only when fifo is full
  output reg [DATA_WIDTH-1:0]data_out;  

  reg empty;
  reg [ADDR_WIDTH-1:0]wr_ptr;                    // write pointer
  reg [ADDR_WIDTH-1:0]rd_ptr;                    // read pointer
  reg [ADDR_WIDTH:0] fifo_cnt;                   // status counter 
  reg [DATA_WIDTH-1:0]fifo_mem[0:FIFO_DEPTH-1];  // FIFO memory

  wire transmitting_sp; // single pulse needed so that cnt and pnts only update once    
                      
  Single_Pulse SP1(clk, transmitting, transmitting_sp);
  

  //---------fifo full logic------------------
  assign full = (fifo_cnt == FIFO_DEPTH);

  //---------fifo_cnt logic-------------------
  always @(posedge clk, negedge rst) begin 
    if(!rst) begin
      fifo_cnt <= 0;
    end
    else begin
      empty <= (fifo_cnt == 0);
      // both data_in and data_out
      if(ld_tx_fifo && (fifo_cnt != FIFO_DEPTH) && transmitting_sp) begin 
        fifo_cnt <= fifo_cnt;
      end
      
      // data_in
      else if(ld_tx_fifo && (fifo_cnt != FIFO_DEPTH)) begin
        fifo_cnt <= fifo_cnt + 1;
      end

      // data_out
      else if(transmitting_sp) begin
        fifo_cnt <= fifo_cnt - 1;
      end
    end
  end

  //----------write to fifo logic-----------
  always @(posedge clk) begin
    if((ld_tx_fifo && (fifo_cnt != FIFO_DEPTH))) fifo_mem[wr_ptr] <= data_in;
  end

  //---------- write pointer logic------------
  always @(posedge clk, negedge rst) begin
    if(!rst) wr_ptr <= 0;
    else if((ld_tx_fifo && (fifo_cnt != FIFO_DEPTH))) wr_ptr <= wr_ptr + 1;
  end

  //----------read from fifo logic------------
  always @(posedge clk, negedge rst) begin
    if(!rst) data_valid <= 0;
    else begin
      if(!empty && !transmitting) begin 
        data_out <= fifo_mem[rd_ptr];
        data_valid <= 1;
      end 
      else if(transmitting) data_valid <= 0;
    end
  end

  //-----------read pointer logic------------
  always @(posedge clk, negedge rst) begin
    if(!rst) begin
      rd_ptr <= 0;
    end
    else if(transmitting_sp) begin
      rd_ptr <= rd_ptr + 1;
    end
  end

endmodule







