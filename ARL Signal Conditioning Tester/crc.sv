`timescale 1 ns / 1 ps

module CRC32_D32(
	input clk,
	input rst,
	input [31:0] data_in,
	input crc_en,
	output [31:0] crc_out
	);

	logic [31:0] data_in_reg;
	logic crc_en_reg;
	logic [7:0] data_in_0;
	logic [7:0] data_in_1;
	logic [7:0] data_in_2;
	logic [7:0] data_in_3;
	
	assign data_in_0 = {data_in[0], data_in[1], data_in[2], data_in[3], data_in[4], data_in[5], data_in[6], data_in[7]};
	assign data_in_1 = {data_in[8], data_in[9], data_in[10], data_in[11], data_in[12], data_in[13], data_in[14], data_in[15]};
	assign data_in_2 = {data_in[16], data_in[17], data_in[18], data_in[19], data_in[20], data_in[21], data_in[22], data_in[23]};
	assign data_in_3 = {data_in[24], data_in[25], data_in[26], data_in[27], data_in[28], data_in[29], data_in[30], data_in[31]};
	
	always_ff @(posedge clk) begin
		data_in_reg[7:0] <= data_in_0;
		data_in_reg[15:8] <= data_in_1;
		data_in_reg[23:16] <= data_in_2;
		data_in_reg[31:24] <= data_in_3;
		crc_en_reg <= crc_en;
	end
	
	reg [31:0] lfsr_q,lfsr_c;

	assign crc_out = { ~lfsr_q[0], ~lfsr_q[1], ~lfsr_q[2], ~lfsr_q[3], ~lfsr_q[4], ~lfsr_q[5], ~lfsr_q[6], ~lfsr_q[7], ~lfsr_q[8], ~lfsr_q[9], ~lfsr_q[10], ~lfsr_q[11], ~lfsr_q[12], ~lfsr_q[13], ~lfsr_q[14], ~lfsr_q[15], ~lfsr_q[16], ~lfsr_q[17], ~lfsr_q[18], ~lfsr_q[19], ~lfsr_q[20], ~lfsr_q[21], ~lfsr_q[22], ~lfsr_q[23], ~lfsr_q[24], ~lfsr_q[25], ~lfsr_q[26], ~lfsr_q[27], ~lfsr_q[28], ~lfsr_q[29], ~lfsr_q[30], ~lfsr_q[31]};

	always @(*) begin
		lfsr_c[0] = data_in_reg[31] ^ data_in_reg[30] ^ data_in_reg[29] ^ data_in_reg[28] ^ data_in_reg[26] ^ data_in_reg[25] ^ data_in_reg[24] ^ data_in_reg[16] ^ data_in_reg[12] ^ data_in_reg[10] ^ data_in_reg[9] ^ data_in_reg[6] ^ data_in_reg[0] ^ lfsr_q[0] ^ lfsr_q[6] ^ lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[12] ^ lfsr_q[16] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[28] ^ lfsr_q[29] ^ lfsr_q[30] ^ lfsr_q[31];
		lfsr_c[1] = data_in_reg[28] ^ data_in_reg[27] ^ data_in_reg[24] ^ data_in_reg[17] ^ data_in_reg[16] ^ data_in_reg[13] ^ data_in_reg[12] ^ data_in_reg[11] ^ data_in_reg[9] ^ data_in_reg[7] ^ data_in_reg[6] ^ data_in_reg[1] ^ data_in_reg[0] ^ lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[9] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[24] ^ lfsr_q[27] ^ lfsr_q[28];
		lfsr_c[2] = data_in_reg[31] ^ data_in_reg[30] ^ data_in_reg[26] ^ data_in_reg[24] ^ data_in_reg[18] ^ data_in_reg[17] ^ data_in_reg[16] ^ data_in_reg[14] ^ data_in_reg[13] ^ data_in_reg[9] ^ data_in_reg[8] ^ data_in_reg[7] ^ data_in_reg[6] ^ data_in_reg[2] ^ data_in_reg[1] ^ data_in_reg[0] ^ lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[24] ^ lfsr_q[26] ^ lfsr_q[30] ^ lfsr_q[31];
		lfsr_c[3] = data_in_reg[31] ^ data_in_reg[27] ^ data_in_reg[25] ^ data_in_reg[19] ^ data_in_reg[18] ^ data_in_reg[17] ^ data_in_reg[15] ^ data_in_reg[14] ^ data_in_reg[10] ^ data_in_reg[9] ^ data_in_reg[8] ^ data_in_reg[7] ^ data_in_reg[3] ^ data_in_reg[2] ^ data_in_reg[1] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[14] ^ lfsr_q[15] ^ lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[19] ^ lfsr_q[25] ^ lfsr_q[27] ^ lfsr_q[31];
		lfsr_c[4] = data_in_reg[31] ^ data_in_reg[30] ^ data_in_reg[29] ^ data_in_reg[25] ^ data_in_reg[24] ^ data_in_reg[20] ^ data_in_reg[19] ^ data_in_reg[18] ^ data_in_reg[15] ^ data_in_reg[12] ^ data_in_reg[11] ^ data_in_reg[8] ^ data_in_reg[6] ^ data_in_reg[4] ^ data_in_reg[3] ^ data_in_reg[2] ^ data_in_reg[0] ^ lfsr_q[0] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[6] ^ lfsr_q[8] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[15] ^ lfsr_q[18] ^ lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[29] ^ lfsr_q[30] ^ lfsr_q[31];
		lfsr_c[5] = data_in_reg[29] ^ data_in_reg[28] ^ data_in_reg[24] ^ data_in_reg[21] ^ data_in_reg[20] ^ data_in_reg[19] ^ data_in_reg[13] ^ data_in_reg[10] ^ data_in_reg[7] ^ data_in_reg[6] ^ data_in_reg[5] ^ data_in_reg[4] ^ data_in_reg[3] ^ data_in_reg[1] ^ data_in_reg[0] ^ lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[10] ^ lfsr_q[13] ^ lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[24] ^ lfsr_q[28] ^ lfsr_q[29];
		lfsr_c[6] = data_in_reg[30] ^ data_in_reg[29] ^ data_in_reg[25] ^ data_in_reg[22] ^ data_in_reg[21] ^ data_in_reg[20] ^ data_in_reg[14] ^ data_in_reg[11] ^ data_in_reg[8] ^ data_in_reg[7] ^ data_in_reg[6] ^ data_in_reg[5] ^ data_in_reg[4] ^ data_in_reg[2] ^ data_in_reg[1] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[11] ^ lfsr_q[14] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[22] ^ lfsr_q[25] ^ lfsr_q[29] ^ lfsr_q[30];
		lfsr_c[7] = data_in_reg[29] ^ data_in_reg[28] ^ data_in_reg[25] ^ data_in_reg[24] ^ data_in_reg[23] ^ data_in_reg[22] ^ data_in_reg[21] ^ data_in_reg[16] ^ data_in_reg[15] ^ data_in_reg[10] ^ data_in_reg[8] ^ data_in_reg[7] ^ data_in_reg[5] ^ data_in_reg[3] ^ data_in_reg[2] ^ data_in_reg[0] ^ lfsr_q[0] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[5] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[10] ^ lfsr_q[15] ^ lfsr_q[16] ^ lfsr_q[21] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[28] ^ lfsr_q[29];
		lfsr_c[8] = data_in_reg[31] ^ data_in_reg[28] ^ data_in_reg[23] ^ data_in_reg[22] ^ data_in_reg[17] ^ data_in_reg[12] ^ data_in_reg[11] ^ data_in_reg[10] ^ data_in_reg[8] ^ data_in_reg[4] ^ data_in_reg[3] ^ data_in_reg[1] ^ data_in_reg[0] ^ lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[8] ^ lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[17] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[28] ^ lfsr_q[31];
		lfsr_c[9] = data_in_reg[29] ^ data_in_reg[24] ^ data_in_reg[23] ^ data_in_reg[18] ^ data_in_reg[13] ^ data_in_reg[12] ^ data_in_reg[11] ^ data_in_reg[9] ^ data_in_reg[5] ^ data_in_reg[4] ^ data_in_reg[2] ^ data_in_reg[1] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[9] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[18] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[29];
		lfsr_c[10] = data_in_reg[31] ^ data_in_reg[29] ^ data_in_reg[28] ^ data_in_reg[26] ^ data_in_reg[19] ^ data_in_reg[16] ^ data_in_reg[14] ^ data_in_reg[13] ^ data_in_reg[9] ^ data_in_reg[5] ^ data_in_reg[3] ^ data_in_reg[2] ^ data_in_reg[0] ^ lfsr_q[0] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[5] ^ lfsr_q[9] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[16] ^ lfsr_q[19] ^ lfsr_q[26] ^ lfsr_q[28] ^ lfsr_q[29] ^ lfsr_q[31];
		lfsr_c[11] = data_in_reg[31] ^ data_in_reg[28] ^ data_in_reg[27] ^ data_in_reg[26] ^ data_in_reg[25] ^ data_in_reg[24] ^ data_in_reg[20] ^ data_in_reg[17] ^ data_in_reg[16] ^ data_in_reg[15] ^ data_in_reg[14] ^ data_in_reg[12] ^ data_in_reg[9] ^ data_in_reg[4] ^ data_in_reg[3] ^ data_in_reg[1] ^ data_in_reg[0] ^ lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[9] ^ lfsr_q[12] ^ lfsr_q[14] ^ lfsr_q[15] ^ lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[20] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[27] ^ lfsr_q[28] ^ lfsr_q[31];
		lfsr_c[12] = data_in_reg[31] ^ data_in_reg[30] ^ data_in_reg[27] ^ data_in_reg[24] ^ data_in_reg[21] ^ data_in_reg[18] ^ data_in_reg[17] ^ data_in_reg[15] ^ data_in_reg[13] ^ data_in_reg[12] ^ data_in_reg[9] ^ data_in_reg[6] ^ data_in_reg[5] ^ data_in_reg[4] ^ data_in_reg[2] ^ data_in_reg[1] ^ data_in_reg[0] ^ lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[9] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[15] ^ lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[21] ^ lfsr_q[24] ^ lfsr_q[27] ^ lfsr_q[30] ^ lfsr_q[31];
		lfsr_c[13] = data_in_reg[31] ^ data_in_reg[28] ^ data_in_reg[25] ^ data_in_reg[22] ^ data_in_reg[19] ^ data_in_reg[18] ^ data_in_reg[16] ^ data_in_reg[14] ^ data_in_reg[13] ^ data_in_reg[10] ^ data_in_reg[7] ^ data_in_reg[6] ^ data_in_reg[5] ^ data_in_reg[3] ^ data_in_reg[2] ^ data_in_reg[1] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[10] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[16] ^ lfsr_q[18] ^ lfsr_q[19] ^ lfsr_q[22] ^ lfsr_q[25] ^ lfsr_q[28] ^ lfsr_q[31];
		lfsr_c[14] = data_in_reg[29] ^ data_in_reg[26] ^ data_in_reg[23] ^ data_in_reg[20] ^ data_in_reg[19] ^ data_in_reg[17] ^ data_in_reg[15] ^ data_in_reg[14] ^ data_in_reg[11] ^ data_in_reg[8] ^ data_in_reg[7] ^ data_in_reg[6] ^ data_in_reg[4] ^ data_in_reg[3] ^ data_in_reg[2] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[11] ^ lfsr_q[14] ^ lfsr_q[15] ^ lfsr_q[17] ^ lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[23] ^ lfsr_q[26] ^ lfsr_q[29];
		lfsr_c[15] = data_in_reg[30] ^ data_in_reg[27] ^ data_in_reg[24] ^ data_in_reg[21] ^ data_in_reg[20] ^ data_in_reg[18] ^ data_in_reg[16] ^ data_in_reg[15] ^ data_in_reg[12] ^ data_in_reg[9] ^ data_in_reg[8] ^ data_in_reg[7] ^ data_in_reg[5] ^ data_in_reg[4] ^ data_in_reg[3] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[12] ^ lfsr_q[15] ^ lfsr_q[16] ^ lfsr_q[18] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[24] ^ lfsr_q[27] ^ lfsr_q[30];
		lfsr_c[16] = data_in_reg[30] ^ data_in_reg[29] ^ data_in_reg[26] ^ data_in_reg[24] ^ data_in_reg[22] ^ data_in_reg[21] ^ data_in_reg[19] ^ data_in_reg[17] ^ data_in_reg[13] ^ data_in_reg[12] ^ data_in_reg[8] ^ data_in_reg[5] ^ data_in_reg[4] ^ data_in_reg[0] ^ lfsr_q[0] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[8] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[17] ^ lfsr_q[19] ^ lfsr_q[21] ^ lfsr_q[22] ^ lfsr_q[24] ^ lfsr_q[26] ^ lfsr_q[29] ^ lfsr_q[30];
		lfsr_c[17] = data_in_reg[31] ^ data_in_reg[30] ^ data_in_reg[27] ^ data_in_reg[25] ^ data_in_reg[23] ^ data_in_reg[22] ^ data_in_reg[20] ^ data_in_reg[18] ^ data_in_reg[14] ^ data_in_reg[13] ^ data_in_reg[9] ^ data_in_reg[6] ^ data_in_reg[5] ^ data_in_reg[1] ^ lfsr_q[1] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[9] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[18] ^ lfsr_q[20] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[25] ^ lfsr_q[27] ^ lfsr_q[30] ^ lfsr_q[31];
		lfsr_c[18] = data_in_reg[31] ^ data_in_reg[28] ^ data_in_reg[26] ^ data_in_reg[24] ^ data_in_reg[23] ^ data_in_reg[21] ^ data_in_reg[19] ^ data_in_reg[15] ^ data_in_reg[14] ^ data_in_reg[10] ^ data_in_reg[7] ^ data_in_reg[6] ^ data_in_reg[2] ^ lfsr_q[2] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[10] ^ lfsr_q[14] ^ lfsr_q[15] ^ lfsr_q[19] ^ lfsr_q[21] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[26] ^ lfsr_q[28] ^ lfsr_q[31];
		lfsr_c[19] = data_in_reg[29] ^ data_in_reg[27] ^ data_in_reg[25] ^ data_in_reg[24] ^ data_in_reg[22] ^ data_in_reg[20] ^ data_in_reg[16] ^ data_in_reg[15] ^ data_in_reg[11] ^ data_in_reg[8] ^ data_in_reg[7] ^ data_in_reg[3] ^ lfsr_q[3] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[11] ^ lfsr_q[15] ^ lfsr_q[16] ^ lfsr_q[20] ^ lfsr_q[22] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[27] ^ lfsr_q[29];
		lfsr_c[20] = data_in_reg[30] ^ data_in_reg[28] ^ data_in_reg[26] ^ data_in_reg[25] ^ data_in_reg[23] ^ data_in_reg[21] ^ data_in_reg[17] ^ data_in_reg[16] ^ data_in_reg[12] ^ data_in_reg[9] ^ data_in_reg[8] ^ data_in_reg[4] ^ lfsr_q[4] ^ lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[12] ^ lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[21] ^ lfsr_q[23] ^ lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[28] ^ lfsr_q[30];
		lfsr_c[21] = data_in_reg[31] ^ data_in_reg[29] ^ data_in_reg[27] ^ data_in_reg[26] ^ data_in_reg[24] ^ data_in_reg[22] ^ data_in_reg[18] ^ data_in_reg[17] ^ data_in_reg[13] ^ data_in_reg[10] ^ data_in_reg[9] ^ data_in_reg[5] ^ lfsr_q[5] ^ lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[13] ^ lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[22] ^ lfsr_q[24] ^ lfsr_q[26] ^ lfsr_q[27] ^ lfsr_q[29] ^ lfsr_q[31];
		lfsr_c[22] = data_in_reg[31] ^ data_in_reg[29] ^ data_in_reg[27] ^ data_in_reg[26] ^ data_in_reg[24] ^ data_in_reg[23] ^ data_in_reg[19] ^ data_in_reg[18] ^ data_in_reg[16] ^ data_in_reg[14] ^ data_in_reg[12] ^ data_in_reg[11] ^ data_in_reg[9] ^ data_in_reg[0] ^ lfsr_q[0] ^ lfsr_q[9] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[14] ^ lfsr_q[16] ^ lfsr_q[18] ^ lfsr_q[19] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[26] ^ lfsr_q[27] ^ lfsr_q[29] ^ lfsr_q[31];
		lfsr_c[23] = data_in_reg[31] ^ data_in_reg[29] ^ data_in_reg[27] ^ data_in_reg[26] ^ data_in_reg[20] ^ data_in_reg[19] ^ data_in_reg[17] ^ data_in_reg[16] ^ data_in_reg[15] ^ data_in_reg[13] ^ data_in_reg[9] ^ data_in_reg[6] ^ data_in_reg[1] ^ data_in_reg[0] ^ lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[6] ^ lfsr_q[9] ^ lfsr_q[13] ^ lfsr_q[15] ^ lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[26] ^ lfsr_q[27] ^ lfsr_q[29] ^ lfsr_q[31];
		lfsr_c[24] = data_in_reg[30] ^ data_in_reg[28] ^ data_in_reg[27] ^ data_in_reg[21] ^ data_in_reg[20] ^ data_in_reg[18] ^ data_in_reg[17] ^ data_in_reg[16] ^ data_in_reg[14] ^ data_in_reg[10] ^ data_in_reg[7] ^ data_in_reg[2] ^ data_in_reg[1] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[7] ^ lfsr_q[10] ^ lfsr_q[14] ^ lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[27] ^ lfsr_q[28] ^ lfsr_q[30];
		lfsr_c[25] = data_in_reg[31] ^ data_in_reg[29] ^ data_in_reg[28] ^ data_in_reg[22] ^ data_in_reg[21] ^ data_in_reg[19] ^ data_in_reg[18] ^ data_in_reg[17] ^ data_in_reg[15] ^ data_in_reg[11] ^ data_in_reg[8] ^ data_in_reg[3] ^ data_in_reg[2] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[8] ^ lfsr_q[11] ^ lfsr_q[15] ^ lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[19] ^ lfsr_q[21] ^ lfsr_q[22] ^ lfsr_q[28] ^ lfsr_q[29] ^ lfsr_q[31];
		lfsr_c[26] = data_in_reg[31] ^ data_in_reg[28] ^ data_in_reg[26] ^ data_in_reg[25] ^ data_in_reg[24] ^ data_in_reg[23] ^ data_in_reg[22] ^ data_in_reg[20] ^ data_in_reg[19] ^ data_in_reg[18] ^ data_in_reg[10] ^ data_in_reg[6] ^ data_in_reg[4] ^ data_in_reg[3] ^ data_in_reg[0] ^ lfsr_q[0] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[6] ^ lfsr_q[10] ^ lfsr_q[18] ^ lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[28] ^ lfsr_q[31];
		lfsr_c[27] = data_in_reg[29] ^ data_in_reg[27] ^ data_in_reg[26] ^ data_in_reg[25] ^ data_in_reg[24] ^ data_in_reg[23] ^ data_in_reg[21] ^ data_in_reg[20] ^ data_in_reg[19] ^ data_in_reg[11] ^ data_in_reg[7] ^ data_in_reg[5] ^ data_in_reg[4] ^ data_in_reg[1] ^ lfsr_q[1] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[7] ^ lfsr_q[11] ^ lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[27] ^ lfsr_q[29];
		lfsr_c[28] = data_in_reg[30] ^ data_in_reg[28] ^ data_in_reg[27] ^ data_in_reg[26] ^ data_in_reg[25] ^ data_in_reg[24] ^ data_in_reg[22] ^ data_in_reg[21] ^ data_in_reg[20] ^ data_in_reg[12] ^ data_in_reg[8] ^ data_in_reg[6] ^ data_in_reg[5] ^ data_in_reg[2] ^ lfsr_q[2] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[8] ^ lfsr_q[12] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[22] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[27] ^ lfsr_q[28] ^ lfsr_q[30];
		lfsr_c[29] = data_in_reg[31] ^ data_in_reg[29] ^ data_in_reg[28] ^ data_in_reg[27] ^ data_in_reg[26] ^ data_in_reg[25] ^ data_in_reg[23] ^ data_in_reg[22] ^ data_in_reg[21] ^ data_in_reg[13] ^ data_in_reg[9] ^ data_in_reg[7] ^ data_in_reg[6] ^ data_in_reg[3] ^ lfsr_q[3] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[9] ^ lfsr_q[13] ^ lfsr_q[21] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[27] ^ lfsr_q[28] ^ lfsr_q[29] ^ lfsr_q[31];
		lfsr_c[30] = data_in_reg[30] ^ data_in_reg[29] ^ data_in_reg[28] ^ data_in_reg[27] ^ data_in_reg[26] ^ data_in_reg[24] ^ data_in_reg[23] ^ data_in_reg[22] ^ data_in_reg[14] ^ data_in_reg[10] ^ data_in_reg[8] ^ data_in_reg[7] ^ data_in_reg[4] ^ lfsr_q[4] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[10] ^ lfsr_q[14] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[26] ^ lfsr_q[27] ^ lfsr_q[28] ^ lfsr_q[29] ^ lfsr_q[30];
		lfsr_c[31] = data_in_reg[31] ^ data_in_reg[30] ^ data_in_reg[29] ^ data_in_reg[28] ^ data_in_reg[27] ^ data_in_reg[25] ^ data_in_reg[24] ^ data_in_reg[23] ^ data_in_reg[15] ^ data_in_reg[11] ^ data_in_reg[9] ^ data_in_reg[8] ^ data_in_reg[5] ^ lfsr_q[5] ^ lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[11] ^ lfsr_q[15] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[27] ^ lfsr_q[28] ^ lfsr_q[29] ^ lfsr_q[30] ^ lfsr_q[31];
	end

	always @(posedge clk, posedge rst) begin
	if(rst) begin
	  lfsr_q <= 32'hFFFFFFFF;
	end
	else begin
	  lfsr_q <= crc_en_reg ? lfsr_c : lfsr_q;
	end
	end // always
	
endmodule

module crc32_d16(
	input clk,
	input rst,
	input [15:0] data_in,
   input crc_en,
   output [31:0] crc_out
	);

	logic [15:0] data_in_reg;
	logic crc_en_reg;
	logic crc_en_reg2;
	logic [7:0] data_in_lo;
	logic [7:0] data_in_hi;
	
	assign data_in_lo = {data_in[0], data_in[1], data_in[2], data_in[3], data_in[4], data_in[5], data_in[6], data_in[7]};
	assign data_in_hi = {data_in[8], data_in[9], data_in[10], data_in[11], data_in[12], data_in[13], data_in[14], data_in[15]};
	
	always_ff @(posedge clk) begin
		data_in_reg[7:0] <= data_in_lo;//{<<{data_in[7:0]}};
		data_in_reg[15:8] <= data_in_hi;//{<<{data_in[15:8]}};
		//data_in_reg <= data_in;
		crc_en_reg2 <= crc_en;
		crc_en_reg <= crc_en_reg2;
	end
	
  reg [31:0] lfsr_q,lfsr_c;

  assign crc_out = { ~lfsr_q[0], ~lfsr_q[1], ~lfsr_q[2], ~lfsr_q[3], ~lfsr_q[4], ~lfsr_q[5], ~lfsr_q[6], ~lfsr_q[7], ~lfsr_q[8], ~lfsr_q[9], ~lfsr_q[10], ~lfsr_q[11], ~lfsr_q[12], ~lfsr_q[13], ~lfsr_q[14], ~lfsr_q[15], ~lfsr_q[16], ~lfsr_q[17], ~lfsr_q[18], ~lfsr_q[19], ~lfsr_q[20], ~lfsr_q[21], ~lfsr_q[22], ~lfsr_q[23], ~lfsr_q[24], ~lfsr_q[25], ~lfsr_q[26], ~lfsr_q[27], ~lfsr_q[28], ~lfsr_q[29], ~lfsr_q[30], ~lfsr_q[31]};
  
  always @(*) begin
    lfsr_c[0] = lfsr_q[16] ^ lfsr_q[22] ^ lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[28] ^ data_in_reg[0] ^ data_in_reg[6] ^ data_in_reg[9] ^ data_in_reg[10] ^ data_in_reg[12];
    lfsr_c[1] = lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[25] ^ lfsr_q[27] ^ lfsr_q[28] ^ lfsr_q[29] ^ data_in_reg[0] ^ data_in_reg[1] ^ data_in_reg[6] ^ data_in_reg[7] ^ data_in_reg[9] ^ data_in_reg[11] ^ data_in_reg[12] ^ data_in_reg[13];
    lfsr_c[2] = lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[29] ^ lfsr_q[30] ^ data_in_reg[0] ^ data_in_reg[1] ^ data_in_reg[2] ^ data_in_reg[6] ^ data_in_reg[7] ^ data_in_reg[8] ^ data_in_reg[9] ^ data_in_reg[13] ^ data_in_reg[14];
    lfsr_c[3] = lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[19] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[30] ^ lfsr_q[31] ^ data_in_reg[1] ^ data_in_reg[2] ^ data_in_reg[3] ^ data_in_reg[7] ^ data_in_reg[8] ^ data_in_reg[9] ^ data_in_reg[10] ^ data_in_reg[14] ^ data_in_reg[15];
    lfsr_c[4] = lfsr_q[16] ^ lfsr_q[18] ^ lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[22] ^ lfsr_q[24] ^ lfsr_q[27] ^ lfsr_q[28] ^ lfsr_q[31] ^ data_in_reg[0] ^ data_in_reg[2] ^ data_in_reg[3] ^ data_in_reg[4] ^ data_in_reg[6] ^ data_in_reg[8] ^ data_in_reg[11] ^ data_in_reg[12] ^ data_in_reg[15];
    lfsr_c[5] = lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[26] ^ lfsr_q[29] ^ data_in_reg[0] ^ data_in_reg[1] ^ data_in_reg[3] ^ data_in_reg[4] ^ data_in_reg[5] ^ data_in_reg[6] ^ data_in_reg[7] ^ data_in_reg[10] ^ data_in_reg[13];
    lfsr_c[6] = lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[27] ^ lfsr_q[30] ^ data_in_reg[1] ^ data_in_reg[2] ^ data_in_reg[4] ^ data_in_reg[5] ^ data_in_reg[6] ^ data_in_reg[7] ^ data_in_reg[8] ^ data_in_reg[11] ^ data_in_reg[14];
    lfsr_c[7] = lfsr_q[16] ^ lfsr_q[18] ^ lfsr_q[19] ^ lfsr_q[21] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[26] ^ lfsr_q[31] ^ data_in_reg[0] ^ data_in_reg[2] ^ data_in_reg[3] ^ data_in_reg[5] ^ data_in_reg[7] ^ data_in_reg[8] ^ data_in_reg[10] ^ data_in_reg[15];
    lfsr_c[8] = lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[24] ^ lfsr_q[26] ^ lfsr_q[27] ^ lfsr_q[28] ^ data_in_reg[0] ^ data_in_reg[1] ^ data_in_reg[3] ^ data_in_reg[4] ^ data_in_reg[8] ^ data_in_reg[10] ^ data_in_reg[11] ^ data_in_reg[12];
    lfsr_c[9] = lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[25] ^ lfsr_q[27] ^ lfsr_q[28] ^ lfsr_q[29] ^ data_in_reg[1] ^ data_in_reg[2] ^ data_in_reg[4] ^ data_in_reg[5] ^ data_in_reg[9] ^ data_in_reg[11] ^ data_in_reg[12] ^ data_in_reg[13];
    lfsr_c[10] = lfsr_q[16] ^ lfsr_q[18] ^ lfsr_q[19] ^ lfsr_q[21] ^ lfsr_q[25] ^ lfsr_q[29] ^ lfsr_q[30] ^ data_in_reg[0] ^ data_in_reg[2] ^ data_in_reg[3] ^ data_in_reg[5] ^ data_in_reg[9] ^ data_in_reg[13] ^ data_in_reg[14];
    lfsr_c[11] = lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[25] ^ lfsr_q[28] ^ lfsr_q[30] ^ lfsr_q[31] ^ data_in_reg[0] ^ data_in_reg[1] ^ data_in_reg[3] ^ data_in_reg[4] ^ data_in_reg[9] ^ data_in_reg[12] ^ data_in_reg[14] ^ data_in_reg[15];
    lfsr_c[12] = lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[22] ^ lfsr_q[25] ^ lfsr_q[28] ^ lfsr_q[29] ^ lfsr_q[31] ^ data_in_reg[0] ^ data_in_reg[1] ^ data_in_reg[2] ^ data_in_reg[4] ^ data_in_reg[5] ^ data_in_reg[6] ^ data_in_reg[9] ^ data_in_reg[12] ^ data_in_reg[13] ^ data_in_reg[15];
    lfsr_c[13] = lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[19] ^ lfsr_q[21] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[26] ^ lfsr_q[29] ^ lfsr_q[30] ^ data_in_reg[1] ^ data_in_reg[2] ^ data_in_reg[3] ^ data_in_reg[5] ^ data_in_reg[6] ^ data_in_reg[7] ^ data_in_reg[10] ^ data_in_reg[13] ^ data_in_reg[14];
    lfsr_c[14] = lfsr_q[18] ^ lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[27] ^ lfsr_q[30] ^ lfsr_q[31] ^ data_in_reg[2] ^ data_in_reg[3] ^ data_in_reg[4] ^ data_in_reg[6] ^ data_in_reg[7] ^ data_in_reg[8] ^ data_in_reg[11] ^ data_in_reg[14] ^ data_in_reg[15];
    lfsr_c[15] = lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[28] ^ lfsr_q[31] ^ data_in_reg[3] ^ data_in_reg[4] ^ data_in_reg[5] ^ data_in_reg[7] ^ data_in_reg[8] ^ data_in_reg[9] ^ data_in_reg[12] ^ data_in_reg[15];
    lfsr_c[16] = lfsr_q[0] ^ lfsr_q[16] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[24] ^ lfsr_q[28] ^ lfsr_q[29] ^ data_in_reg[0] ^ data_in_reg[4] ^ data_in_reg[5] ^ data_in_reg[8] ^ data_in_reg[12] ^ data_in_reg[13];
    lfsr_c[17] = lfsr_q[1] ^ lfsr_q[17] ^ lfsr_q[21] ^ lfsr_q[22] ^ lfsr_q[25] ^ lfsr_q[29] ^ lfsr_q[30] ^ data_in_reg[1] ^ data_in_reg[5] ^ data_in_reg[6] ^ data_in_reg[9] ^ data_in_reg[13] ^ data_in_reg[14];
    lfsr_c[18] = lfsr_q[2] ^ lfsr_q[18] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[26] ^ lfsr_q[30] ^ lfsr_q[31] ^ data_in_reg[2] ^ data_in_reg[6] ^ data_in_reg[7] ^ data_in_reg[10] ^ data_in_reg[14] ^ data_in_reg[15];
    lfsr_c[19] = lfsr_q[3] ^ lfsr_q[19] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[27] ^ lfsr_q[31] ^ data_in_reg[3] ^ data_in_reg[7] ^ data_in_reg[8] ^ data_in_reg[11] ^ data_in_reg[15];
    lfsr_c[20] = lfsr_q[4] ^ lfsr_q[20] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[28] ^ data_in_reg[4] ^ data_in_reg[8] ^ data_in_reg[9] ^ data_in_reg[12];
    lfsr_c[21] = lfsr_q[5] ^ lfsr_q[21] ^ lfsr_q[25] ^ lfsr_q[26] ^ lfsr_q[29] ^ data_in_reg[5] ^ data_in_reg[9] ^ data_in_reg[10] ^ data_in_reg[13];
    lfsr_c[22] = lfsr_q[6] ^ lfsr_q[16] ^ lfsr_q[25] ^ lfsr_q[27] ^ lfsr_q[28] ^ lfsr_q[30] ^ data_in_reg[0] ^ data_in_reg[9] ^ data_in_reg[11] ^ data_in_reg[12] ^ data_in_reg[14];
    lfsr_c[23] = lfsr_q[7] ^ lfsr_q[16] ^ lfsr_q[17] ^ lfsr_q[22] ^ lfsr_q[25] ^ lfsr_q[29] ^ lfsr_q[31] ^ data_in_reg[0] ^ data_in_reg[1] ^ data_in_reg[6] ^ data_in_reg[9] ^ data_in_reg[13] ^ data_in_reg[15];
    lfsr_c[24] = lfsr_q[8] ^ lfsr_q[17] ^ lfsr_q[18] ^ lfsr_q[23] ^ lfsr_q[26] ^ lfsr_q[30] ^ data_in_reg[1] ^ data_in_reg[2] ^ data_in_reg[7] ^ data_in_reg[10] ^ data_in_reg[14];
    lfsr_c[25] = lfsr_q[9] ^ lfsr_q[18] ^ lfsr_q[19] ^ lfsr_q[24] ^ lfsr_q[27] ^ lfsr_q[31] ^ data_in_reg[2] ^ data_in_reg[3] ^ data_in_reg[8] ^ data_in_reg[11] ^ data_in_reg[15];
    lfsr_c[26] = lfsr_q[10] ^ lfsr_q[16] ^ lfsr_q[19] ^ lfsr_q[20] ^ lfsr_q[22] ^ lfsr_q[26] ^ data_in_reg[0] ^ data_in_reg[3] ^ data_in_reg[4] ^ data_in_reg[6] ^ data_in_reg[10];
    lfsr_c[27] = lfsr_q[11] ^ lfsr_q[17] ^ lfsr_q[20] ^ lfsr_q[21] ^ lfsr_q[23] ^ lfsr_q[27] ^ data_in_reg[1] ^ data_in_reg[4] ^ data_in_reg[5] ^ data_in_reg[7] ^ data_in_reg[11];
    lfsr_c[28] = lfsr_q[12] ^ lfsr_q[18] ^ lfsr_q[21] ^ lfsr_q[22] ^ lfsr_q[24] ^ lfsr_q[28] ^ data_in_reg[2] ^ data_in_reg[5] ^ data_in_reg[6] ^ data_in_reg[8] ^ data_in_reg[12];
    lfsr_c[29] = lfsr_q[13] ^ lfsr_q[19] ^ lfsr_q[22] ^ lfsr_q[23] ^ lfsr_q[25] ^ lfsr_q[29] ^ data_in_reg[3] ^ data_in_reg[6] ^ data_in_reg[7] ^ data_in_reg[9] ^ data_in_reg[13];
    lfsr_c[30] = lfsr_q[14] ^ lfsr_q[20] ^ lfsr_q[23] ^ lfsr_q[24] ^ lfsr_q[26] ^ lfsr_q[30] ^ data_in_reg[4] ^ data_in_reg[7] ^ data_in_reg[8] ^ data_in_reg[10] ^ data_in_reg[14];
    lfsr_c[31] = lfsr_q[15] ^ lfsr_q[21] ^ lfsr_q[24] ^ lfsr_q[25] ^ lfsr_q[27] ^ lfsr_q[31] ^ data_in_reg[5] ^ data_in_reg[8] ^ data_in_reg[9] ^ data_in_reg[11] ^ data_in_reg[15];

  end // always

  always @(posedge clk, posedge rst) begin
    if(rst) begin
      lfsr_q <= {32{1'b1}};
    end
    else begin
      lfsr_q <= crc_en_reg ? lfsr_c : lfsr_q;
    end
  end // always
endmodule // crc

module crc16_d16(
	input clk,
	input rst,
	input [15:0] data_in,
   input crc_en,
   output [15:0] crc_out
	);

	logic [15:0] data_in_reg;
	logic crc_en_reg;
	
	always_ff @(posedge clk) begin
		data_in_reg <= data_in;
		crc_en_reg <= crc_en;
	end
	
  reg [15:0] lfsr_q,lfsr_c, lfsr_cs;

  assign crc_out = lfsr_q;

  always @(*) begin
    lfsr_c[0] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[15] ^ data_in_reg[0] ^ data_in_reg[1] ^ data_in_reg[2] ^ data_in_reg[3] ^ data_in_reg[4] ^ data_in_reg[5] ^ data_in_reg[6] ^ data_in_reg[7] ^ data_in_reg[8] ^ data_in_reg[9] ^ data_in_reg[10] ^ data_in_reg[11] ^ data_in_reg[12] ^ data_in_reg[13] ^ data_in_reg[15];
    lfsr_c[1] = lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[14] ^ data_in_reg[1] ^ data_in_reg[2] ^ data_in_reg[3] ^ data_in_reg[4] ^ data_in_reg[5] ^ data_in_reg[6] ^ data_in_reg[7] ^ data_in_reg[8] ^ data_in_reg[9] ^ data_in_reg[10] ^ data_in_reg[11] ^ data_in_reg[12] ^ data_in_reg[13] ^ data_in_reg[14];
    lfsr_c[2] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[14] ^ data_in_reg[0] ^ data_in_reg[1] ^ data_in_reg[14];
    lfsr_c[3] = lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[15] ^ data_in_reg[1] ^ data_in_reg[2] ^ data_in_reg[15];
    lfsr_c[4] = lfsr_q[2] ^ lfsr_q[3] ^ data_in_reg[2] ^ data_in_reg[3];
    lfsr_c[5] = lfsr_q[3] ^ lfsr_q[4] ^ data_in_reg[3] ^ data_in_reg[4];
    lfsr_c[6] = lfsr_q[4] ^ lfsr_q[5] ^ data_in_reg[4] ^ data_in_reg[5];
    lfsr_c[7] = lfsr_q[5] ^ lfsr_q[6] ^ data_in_reg[5] ^ data_in_reg[6];
    lfsr_c[8] = lfsr_q[6] ^ lfsr_q[7] ^ data_in_reg[6] ^ data_in_reg[7];
    lfsr_c[9] = lfsr_q[7] ^ lfsr_q[8] ^ data_in_reg[7] ^ data_in_reg[8];
    lfsr_c[10] = lfsr_q[8] ^ lfsr_q[9] ^ data_in_reg[8] ^ data_in_reg[9];
    lfsr_c[11] = lfsr_q[9] ^ lfsr_q[10] ^ data_in_reg[9] ^ data_in_reg[10];
    lfsr_c[12] = lfsr_q[10] ^ lfsr_q[11] ^ data_in_reg[10] ^ data_in_reg[11];
    lfsr_c[13] = lfsr_q[11] ^ lfsr_q[12] ^ data_in_reg[11] ^ data_in_reg[12];
    lfsr_c[14] = lfsr_q[12] ^ lfsr_q[13] ^ data_in_reg[12] ^ data_in_reg[13];
    lfsr_c[15] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[14] ^ lfsr_q[15] ^ data_in_reg[0] ^ data_in_reg[1] ^ data_in_reg[2] ^ data_in_reg[3] ^ data_in_reg[4] ^ data_in_reg[5] ^ data_in_reg[6] ^ data_in_reg[7] ^ data_in_reg[8] ^ data_in_reg[9] ^ data_in_reg[10] ^ data_in_reg[11] ^ data_in_reg[12] ^ data_in_reg[14] ^ data_in_reg[15];

  end // always
  
//  always @(posedge clk) begin
//		lfsr_cs <= lfsr_c;
//	end

  always @(posedge clk, posedge rst) begin
    if(rst) begin
      lfsr_q <= {16{1'b0}};
    end
    else begin
      lfsr_q <= crc_en_reg ? lfsr_c : lfsr_q;
    end
  end // always
endmodule // crc