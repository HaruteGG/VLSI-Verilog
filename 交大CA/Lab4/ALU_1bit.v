//Student ID:614001005
`timescale 1ns/1ps
`include "MUX_2to1.v"
`include "MUX_4to1.v"

module ALU_1bit(
	input				src1,       //1 bit source 1  (input)
	input				src2,       //1 bit source 2  (input)
	input				less,       //1 bit less      (input)
	input 				Ainvert,    //1 bit A_invert  (input)
	input				Binvert,    //1 bit B_invert  (input)
	input 				cin,        //1 bit carry in  (input)
	input 	    [2-1:0] operation,  //2 bit operation (input)
	output reg          result,     //1 bit result    (output)
	output reg          cout        //1 bit carry out (output)
	);
		
/* Write down your code HERE */
wire muxa_out;
wire muxb_out;
wire and_out;
wire or_out;
wire add_out;
wire add_cout;
wire result_mux;
MUX_2to1 muxa (
		.src1(src1),
		.src2(~src1),
		.select(Ainvert),
		.result(muxa_out)
	);
MUX_2to1 muxb (
		.src1(src2),
		.src2(~src2),
		.select(Binvert),
		.result(muxb_out)
	);
MUX_4to1 mux_op (
		.src1(or_out),
		.src2(and_out),
		.src3(add_out),
		.src4(add_out),
		.select(operation),
		.result(result_mux)
	);
assign and_out = muxa_out & muxb_out;
assign or_out = muxa_out | muxb_out; 
assign add_out = muxa_out ^ muxb_out ^ cin;
assign add_cout = (muxa_out & muxb_out) | (cin & (muxa_out ^ muxb_out));

always @(*) begin

	result = result_mux;
	cout = (operation == 2'b10 || operation == 2'b11) ? add_cout : 1'b0;

end
endmodule