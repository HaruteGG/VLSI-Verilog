// student ID:614001005
module Decoder( 
	instr_op_i,
	ALU_op_o,
	ALUSrc_o,
	RegWrite_o,
	RegDst_o,
	Branch_o,
	Jump_o,
	MemRead_o,
	MemWrite_o,
	MemtoReg_o
);

// I/O ports
input	[6-1:0] instr_op_i;

output	[2-1:0] ALU_op_o;
output	[2-1:0] RegDst_o, MemtoReg_o;
output  [2-1:0] Branch_o;
output			ALUSrc_o, RegWrite_o, Jump_o, MemRead_o, MemWrite_o;

// Internal Signals
reg [2-1:0] ALU_op_o_reg, RegDst_o_reg, MemtoReg_o_reg, Branch_o_reg;
reg ALUSrc_o_reg, RegWrite_o_reg, Jump_o_reg, MemRead_o_reg, MemWrite_o_reg;

// Main function
always@(*)begin
	case(instr_op_i)
		6'b000000: begin // R-type
			ALU_op_o_reg = 2'b10;
			RegDst_o_reg = 2'b01;
			MemtoReg_o_reg = 2'b00;
			Branch_o_reg = 2'b00;
			ALUSrc_o_reg = 1'b0;
			RegWrite_o_reg = 1'b1;
			Jump_o_reg = 1'b0;
			MemRead_o_reg = 1'b0;
			MemWrite_o_reg = 1'b0;
		end
		6'b001001: begin // addi
			ALU_op_o_reg = 2'b00;
			RegDst_o_reg = 2'b00;
			MemtoReg_o_reg = 2'b00;
			Branch_o_reg = 2'b00;
			ALUSrc_o_reg = 1'b1;
			RegWrite_o_reg = 1'b1;
			Jump_o_reg = 1'b0;
			MemRead_o_reg = 1'b0;
			MemWrite_o_reg = 1'b0;
		end
		6'b101100: begin // lw
			ALU_op_o_reg = 2'b00;
			RegDst_o_reg = 2'b00;
			MemtoReg_o_reg = 2'b01;
			Branch_o_reg = 2'b00;
			ALUSrc_o_reg = 1'b1;
			RegWrite_o_reg = 1'b1;
			Jump_o_reg = 1'b0;
			MemRead_o_reg = 1'b1;
			MemWrite_o_reg = 1'b0;
		end
		6'b100100: begin // sw
			ALU_op_o_reg = 2'b00;
			RegDst_o_reg = 2'b00;
			MemtoReg_o_reg = 2'b00;
			Branch_o_reg = 2'b00;
			ALUSrc_o_reg = 1'b1;
			RegWrite_o_reg = 1'b0;
			Jump_o_reg = 1'b0;
			MemRead_o_reg = 1'b0;
			MemWrite_o_reg = 1'b1;
		end
		6'b000110: begin // beq
			ALU_op_o_reg = 2'b01;
			RegDst_o_reg = 2'b00;
			MemtoReg_o_reg = 2'b00;
			Branch_o_reg = 2'b01;
			ALUSrc_o_reg = 1'b0;
			RegWrite_o_reg = 1'b0;
			Jump_o_reg = 1'b0;
			MemRead_o_reg = 1'b0;
			MemWrite_o_reg = 1'b0;
		end
		6'b000101: begin // bne
			ALU_op_o_reg = 2'b01;
			RegDst_o_reg = 2'b00;
			MemtoReg_o_reg = 2'b00;
			Branch_o_reg = 2'b10;
			ALUSrc_o_reg = 1'b0;
			RegWrite_o_reg = 1'b0;
			Jump_o_reg = 1'b0;
			MemRead_o_reg = 1'b0;
			MemWrite_o_reg = 1'b0;
		end
		
		default : begin // default case
			ALU_op_o_reg = 2'b00;
			RegDst_o_reg = 2'b00;
			MemtoReg_o_reg = 2'b00;
			Branch_o_reg = 2'b00;
			ALUSrc_o_reg = 1'b0;
			RegWrite_o_reg = 1'b0;
			Jump_o_reg = 1'b0;
			MemRead_o_reg = 1'b0;
			MemWrite_o_reg = 1'b0;
		end
	endcase
end
assign ALU_op_o = ALU_op_o_reg;
assign RegDst_o = RegDst_o_reg;
assign MemtoReg_o = MemtoReg_o_reg;
assign Branch_o = Branch_o_reg;
assign ALUSrc_o = ALUSrc_o_reg;
assign RegWrite_o = RegWrite_o_reg;
assign Jump_o = Jump_o_reg;
assign MemRead_o = MemRead_o_reg;
assign MemWrite_o = MemWrite_o_reg;
endmodule
                

