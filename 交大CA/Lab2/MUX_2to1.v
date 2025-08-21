//Student ID:614001005
`timescale 1ns/1ps

module MUX_2to1(
	input      src1,
	input      src2,
	input	   select,
	output reg result
	);

/* Write down your code HERE */
	always @(*) begin
		result = (select & src2) | (~select & src1);
	end

endmodule