module PHY_CONFIG_PARAMS (
	output [1:0]	SPEED,
	output			DUPLEX,
	output [1:0]	TEST_MODE,
	output			POWER_DOWN,
	output [15:0]	CLK_SKEW1,
	output [15:0]	CLK_SKEW2,
	output			SREG_READ_START,
	output [8:0]	SREG_REGAD
);

	assign SPEED				= 2'b00;
	assign DUPLEX				= 1'b1;
	assign TEST_MODE			= 2'b00;
	assign POWER_DOWN 		= 1'b0;
	assign CLK_SKEW1			= 0;
	assign CLK_SKEW2			= 0;
	assign SREG_READ_START	= 1'b0;
	assign SREG_REGAD			= 0;

endmodule
