//Student ID:614001005
`timescale 1ns/1ps
`include "ALU_1bit.v"
module ALU(
	input                   rst_n,         // negative reset            (input)
	input	     [32-1:0]	src1,          // 32 bits source 1          (input)
	input	     [32-1:0]	src2,          // 32 bits source 2          (input)
	input 	     [ 4-1:0] 	ALU_control,   // 4 bits ALU control input  (input)
	input        [ 5-1:0] 	shamt,         // 5 bits shift amount       (input)
	output reg   [32-1:0]	result,        // 32 bits result            (output)
	output reg              zero,          // 1 bit when the output is 0, zero must be set (output)
	output reg              cout,          // 1 bit carry out           (output)
	output reg              overflow       // 1 bit overflow            (output)
	);
	
/* Write down your code HERE */
wire [32-1:0] carry_out;
wire Ainvert; 
wire Binvert; 
wire [2-1:0] operation; 
assign Ainvert = ALU_control[3];
assign Binvert = ALU_control[2];
assign operation = ALU_control[1:0];
wire [32-1:0] result_wire;
wire overflow_wire;
wire slt_result;

genvar i;
generate for(i = 0; i < 32; i = i + 1) begin : alu_1bit_obj
	ALU_1bit obj(
		.src1(src1[i]),
		.src2(src2[i]),
		.less(1'b0), //alu[0].less == 0),
		.Ainvert(Ainvert),
		.Binvert(Binvert),
		.cin(i == 0 ? Binvert : carry_out[i-1]),
		.operation(operation),
		.result(result_wire[i]),
		.cout(carry_out[i])
	);
	end
endgenerate
assign overflow_wire = (carry_out[31] != carry_out[30]);
assign slt_result = result_wire[31] ^ overflow_wire;
always @(*) begin //output zero cout overflow result
	
	if(ALU_control == 4'b0111) begin
		result = {31'b0, slt_result};
	end else if(ALU_control == 4'b1100) begin // jr
		result = src1;
	end else if(ALU_control == 4'b1000) begin // sll
		result = src2 << shamt;
	end else if(ALU_control == 4'b1001) begin // srl
		result = src2 >> shamt;
	end else if(ALU_control == 4'b1010) begin // sllv
		result = src2 << src1;
	end else if(ALU_control == 4'b1011) begin // srlv
		result = src2 >> src1;
	end else begin
		result = result_wire;
	end

	if(result == 32'b0) begin
		zero = 1'b1;
	end else begin
		zero = 1'b0;
	end
	cout = (ALU_control == 4'b0111) ? 1'b0 : carry_out[31];
	overflow = overflow_wire;
end

endmodule

		
