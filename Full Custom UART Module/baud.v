// baud.v
// Brandon Boesch
// Josh Randall
// James Schulman

// EE 382M.7 - VLSI1
// Nov 28th, 2015

//-----------------------------------------------------
// Baud Rate Module 
//-----------------------------------------------------
// Functionality:
// This module generates a clock by diving the input clock down to the user's specified
// speed.


module baud(clk_in, rst, baud_sel, tx_clk, rx_clk);
  parameter clk_rate = 50000000;   // 50 Mhz input clock
  parameter tx_check0 = clk_rate / 300;
  parameter tx_check1 = clk_rate / 600;
  parameter tx_check2 = clk_rate / 1600;
  parameter tx_check3 = clk_rate / 2400;
  parameter tx_check4 = clk_rate / 4800;
  parameter tx_check5 = clk_rate / 9600;
  parameter tx_check6 = clk_rate / 19200;
  parameter tx_check7 = clk_rate / 115200;
  
  input rst;
  input clk_in;
  input [2:0]baud_sel;
  output reg tx_clk, rx_clk;
  integer tx_cnt, rx_cnt, tx_check, rx_check;
  integer baud;

  always @(baud_sel) begin
    case(baud_sel)  // used to generate tx_clk
      0: tx_check = tx_check0;
      1: tx_check = tx_check1;
      2: tx_check = tx_check2;
      3: tx_check = tx_check3;
      4: tx_check = tx_check4;
      5: tx_check = tx_check5;
      6: tx_check = tx_check6;
      7: tx_check = tx_check7;
    endcase
    rx_check = (tx_check >> 3);  // check used to generate rx_clk. 8 times faster than tx.
  end

  always@(posedge clk_in, negedge rst) begin
    if(!rst) begin
      tx_cnt <= 0;
      rx_cnt <= 0;
      tx_clk <= 0;
      rx_clk <= 0;
    end
    else begin
      tx_cnt <= tx_cnt + 1;
      rx_cnt <= rx_cnt + 1;

      if(tx_cnt == tx_check) begin
        tx_cnt <= 0;
        tx_clk <= ~ tx_clk;
      end
      if(rx_cnt == rx_check) begin
        rx_cnt <= 0;
        rx_clk <= ~ rx_clk;
      end
    end
  end
endmodule






