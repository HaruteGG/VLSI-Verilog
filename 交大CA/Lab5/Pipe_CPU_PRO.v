// ID:614001005

`include "Adder.v"
`include "ALU_Ctrl.v"
`include "ALU.v"
`include "Data_Memory.v"
`include "Decoder.v"
`include "Forwarding_Unit.v"
`include "Hazard_Detection.v"
`include "Instruction_Memory.v"
`include "MUX_2to1.v"
`include "MUX_3to1.v"
`include "Reg_File.v"
`include "Shift_Left_Two_32.v"
`include "Sign_Extend.v"
`include "Pipe_Reg.v"
`include "ProgramCounter.v"

`timescale 1ns / 1ps

module Pipe_CPU_PRO(
    clk_i,
    rst_i
    );
    
// I/O ports

input clk_i;
input rst_i;

// Internal signal=====================================================================

// IF stage
wire [32-1:0] pc, pc_out, pc_add4, instr;
wire [32-1:0] pc_out_ID, instr_ID;

// ID stage
wire [32-1:0] ReadData1, ReadData2;
wire [2-1:0] ALUOp;
wire ALUSrc, RegWrite, RegDst, Branch, MemRead, MemWrite, MemtoReg;
wire [32-1:0] signed_addr;
//control signal
wire [32-1:0] pc_out_EX, ReadData1_EX, ReadData2_EX, signed_addr_EX;
wire [21-1:0] instr_EX;
wire [2-1:0] ALUOp_EX;
wire ALUSrc_EX, RegWrite_EX, RegDst_EX, Branch_EX, MemRead_EX, MemWrite_EX, MemtoReg_EX, PCwrite, IF_flush, ID_flush, EX_flush, IF_ID_write;
wire [5-1:0] rs_EX, rt_EX;
wire [6-1:0] opcode_branch_EX;

// EX stage
wire [32-1:0] addr_shift2, ALU_src, ALU_result, pc_branch, mux_forwardA_output, mux_forwardB_output;
wire [4-1:0] ALUCtrl;
wire ALU_zero;
wire [5-1:0] write_Reg_addr;
wire [2-1:0] forwardA_result, forwardB_result;
//control signal
wire [32-1:0] ALU_result_MEM, pc_branch_MEM, forwardB_MEM;
wire zero_MEM;
wire [5-1:0] write_Reg_addr_MEM;
wire RegWrite_MEM, Branch_MEM, MemRead_MEM, MemWrite_MEM, MemtoReg_MEM;
wire [6-1:0] opcode_branch_MEM;

// MEM stage
wire [32-1:0] read_data;
wire [5:0] BNE_OPCODE = 6'b000101;
wire is_bne;
wire condition_met;
//control signal
wire [32-1:0] read_data_WB, ALU_result_WB;
wire [5-1:0] write_Reg_addr_WB;
wire RegWrite_WB, MemtoReg_WB;

// WB stage
wire [32-1:0] write_data;
//control signal


// Instantiate modules
//Instantiate the components in IF stage=====================================================================
MUX_2to1 #(.size(32)) Mux0(
    .data0_i(pc_add4),
    .data1_i(pc_branch_MEM),
    .select_i(Branch_MEM & condition_met), // PCSrc
    .data_o(pc)
);

ProgramCounter PC(
    .clk_i(clk_i),      
	.rst_i(rst_i),  
    .pc_write(PCwrite),   
	.pc_in_i(pc),   
	.pc_out_o(pc_out)
);

Instruction_Memory IM(
    .addr_i(pc_out),  
	.instr_o(instr)
);
			
Adder Add_pc(
    .src1_i(pc_out),     
	.src2_i(32'd4),
	.sum_o(pc_add4)
);

		
Pipe_Reg #(.size(64)) IF_ID(       //N is the total length of input/output
    .clk_i(clk_i),
    .rst_i(rst_i),
    .flush(IF_flush),
    .write(IF_ID_write),
    .data_i({pc_out, instr}),
    .data_o({pc_out_ID, instr_ID})
);


// Components in ID stage=====================================================================
Hazard_Detection Hazard(
    .memread(MemRead_EX),
    .instr_i(instr_ID),
    .idex_regt(rt_EX),
    .branch(Branch_MEM & condition_met),
    .pcwrite(PCwrite),
    .ifid_write(IF_ID_write),
    .ifid_flush(IF_flush),
    .idex_flush(ID_flush),
    .exmem_flush(EX_flush)
);
assign final_RegWrite = RegWrite_WB & (write_Reg_addr_WB != 5'b0);
Reg_File RF(
    .clk_i(clk_i),      
	.rst_i(rst_i) ,     
    .RSaddr_i(instr_ID[25:21]),  
    .RTaddr_i(instr_ID[20:16]),  
    .RDaddr_i(write_Reg_addr_WB),  
    .RDdata_i(write_data), // WB
    .RegWrite_i(final_RegWrite),
    .RSdata_o(ReadData1),  
    .RTdata_o(ReadData2)
);

Decoder Control(
    .instr_op_i(instr_ID[31:26]), 
	.ALUOp_o(ALUOp),   
	.ALUSrc_o(ALUSrc),
    .RegWrite_o(RegWrite), 
	.RegDst_o(RegDst),
	.Branch_o(Branch),
	.MemRead_o(MemRead), 
	.MemWrite_o(MemWrite), 
	.MemtoReg_o(MemtoReg)
);

Sign_Extend Sign_Ext(
    .data_i(instr_ID[15:0]),
    .data_o(signed_addr)
);	

Pipe_Reg #(.size(174)) ID_EX(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .flush(ID_flush),
    .write(1'b1),
    .data_i({pc_out_ID, instr_ID[20:0], ReadData1, ReadData2,
            ALUOp, ALUSrc, RegWrite, RegDst, Branch, MemRead, MemWrite, MemtoReg, signed_addr, instr_ID[25:21], instr_ID[20:16], instr_ID[31:26]}),
    .data_o({pc_out_EX, instr_EX, ReadData1_EX, ReadData2_EX, 
            ALUOp_EX, ALUSrc_EX, RegWrite_EX, RegDst_EX, Branch_EX, MemRead_EX, MemWrite_EX, MemtoReg_EX, signed_addr_EX, rs_EX, rt_EX, opcode_branch_EX})
);


// Components in EX stage=====================================================================	   
Shift_Left_Two_32 Shift2(
    .data_i(signed_addr_EX),
    .data_o(addr_shift2)
);
Forwarding_Unit forwarding_unit(
    .regwrite_mem(RegWrite_MEM),
    .regwrite_wb(RegWrite_WB),
    .idex_regs(rs_EX),
    .idex_regt(rt_EX),
    .exmem_regd(write_Reg_addr_MEM),
    .memwb_regd(write_Reg_addr_WB),
    .forwarda(forwardA_result),
    .forwardb(forwardB_result)
);
MUX_3to1 #(.size(32)) mux_forwardA(
    .data0_i(ReadData1_EX),
    .data1_i(ALU_result_MEM),
    .data2_i(write_data),
    .select_i(forwardA_result),
    .data_o(mux_forwardA_output)
);
MUX_3to1 #(.size(32)) mux_forwardB(
    .data0_i(ReadData2_EX),
    .data1_i(ALU_result_MEM),
    .data2_i(write_data),
    .select_i(forwardB_result),
    .data_o(mux_forwardB_output)
);
ALU ALU(
    .src1_i(mux_forwardA_output),
	.src2_i(ALU_src),
	.ctrl_i(ALUCtrl),
	.result_o(ALU_result),
	.zero_o(ALU_zero)
);
		
ALU_Ctrl ALU_Control(
    .funct_i(instr_EX[5:0]),   
    .ALUOp_i(ALUOp_EX),
    .ALUCtrl_o(ALUCtrl)
);

MUX_2to1 #(.size(32)) Mux1(
    .data0_i(mux_forwardB_output),
    .data1_i(signed_addr_EX),
    .select_i(ALUSrc_EX),
    .data_o(ALU_src)
);
		
MUX_2to1 #(.size(5)) Mux2(
    .data0_i(instr_EX[20:16]),
    .data1_i(instr_EX[15:11]),
    .select_i(RegDst_EX),
    .data_o(write_Reg_addr)
);

Adder Add_pc_branch(
    .src1_i(pc_out_EX), //     
	.src2_i(addr_shift2),
	.sum_o(pc_branch)
);

Pipe_Reg #(.size(113)) EX_MEM(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .flush(EX_flush),
    .write(1'b1),
    .data_i({ALU_result, pc_branch, mux_forwardB_output, ALU_zero, write_Reg_addr,  
	        RegWrite_EX, Branch_EX, MemRead_EX, MemWrite_EX, MemtoReg_EX, opcode_branch_EX}),
    .data_o({ALU_result_MEM, pc_branch_MEM, forwardB_MEM, zero_MEM, write_Reg_addr_MEM, 
		    RegWrite_MEM, Branch_MEM, MemRead_MEM, MemWrite_MEM, MemtoReg_MEM, opcode_branch_MEM})
);


// Components in MEM stage=====================================================================
Data_Memory DM(
    .clk_i(clk_i), 
	.addr_i(ALU_result_MEM), 
	.data_i(forwardB_MEM), 
	.MemRead_i(MemRead_MEM), 
	.MemWrite_i(MemWrite_MEM), 
	.data_o(read_data)
);
assign is_bne = (opcode_branch_MEM == BNE_OPCODE);
assign condition_met = (is_bne) ? ~zero_MEM : zero_MEM;
Pipe_Reg #(.size(71)) MEM_WB(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .flush(1'b0),
    .write(1'b1),
	.data_i({read_data, ALU_result_MEM, write_Reg_addr_MEM, RegWrite_MEM, MemtoReg_MEM}),
    .data_o({read_data_WB, ALU_result_WB, write_Reg_addr_WB, RegWrite_WB, MemtoReg_WB})
);


// Components in WB stage=====================================================================
MUX_2to1 #(.size(32)) Mux3(
    .data0_i(ALU_result_WB),
    .data1_i(read_data_WB),
    .select_i(MemtoReg_WB),
    .data_o(write_data)
);

endmodule