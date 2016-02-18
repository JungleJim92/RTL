`timescale 1 ns / 1 ps

module input_register (
    input clk_i,
    input data_i,
	 input clr_i,
	 output data_o
	);
	
logic data_s;

dffe_verilog_ir u1 (
	.d(1'b1),
	.clk(data_i),
	.clrn(~clr_i),
	.prn(1'b1),
	.ena(1'b1),
	.q(data_s)
	);
	
dffe_verilog_ir u2 (
	.d(data_s),
	.clk(clk_i),
	.clrn(1'b1),
	.prn(1'b1),
	.ena(1'b1),
	.q(data_o)
	);
	
endmodule

module dffe_verilog_ir (q, d, clk, ena, clrn, prn);

// port declaration

input   d, clk, ena, clrn, prn;
output  q;
reg     q;

always @ (posedge clk or negedge clrn or negedge prn) begin

//asynchronous active-low preset
    if (~prn)
        begin
        if (clrn)
            q = 1'b1;
        else
            q = 1'bx;
        end

//asynchronous active-low reset
     else if (~clrn)
        q = 1'b0;

//enable
     else if (ena)
        q = d;
end

endmodule