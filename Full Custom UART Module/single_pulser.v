// single_pulser.v
//
// Brandon Boesch
// Mitch Hinrichs
// ------------------------------------------------------------------------
// Provides user with a single output per button press and release.
// ------------------------------------------------------------------------


module Single_Pulse(Clk, SyncedIn, SP);
  input SyncedIn, Clk;
  output SP;

  wire S1, S0;

  Dff DFFA(SyncedIn, Clk, S1, S0); 
  And2 AND(S0, SyncedIn, SP);

endmodule

// D Flip-Flop
module Dff(D, CLK, Q, QN);
  input D, CLK;
  output reg Q, QN;

  always @(posedge CLK) begin
    Q <= D;
    QN <= (~D);
  end
endmodule

// 2 input AND gate
module And2(A1, A2, Z);
  input A1, A2;
  output Z;

  assign Z = (A1 & A2);
endmodule 
