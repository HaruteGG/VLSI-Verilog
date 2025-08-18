//ID:614001005
`include "Adder.v"
`include "ALU_Ctrl.v"
`include "ALU.v"
`include "Reg_File.v"
`include "Data_Memory.v"
`include "Decoder.v"
`include "Instruction_Memory.v"
`include "Pipe_Reg.v"
`include "ProgramCounter.v"
`include "Shift_Left_Two_32.v"
`include "Sign_Extend.v"

`timescale 1ns/1ps

module Pipe_CPU(
    clk_i,
    rst_i
    );

input clk_i;
input rst_i;

// TO DO

// Internal signal
wire [32-1:0] pc_out_next;
wire [32-1:0] pc_current_address;
wire [32-1:0] instruction;
wire [32-1:0] pc_plus_4;
wire [32-1:0] branch_out;
wire [32-1:0] IF_ID_IM_out;
wire [32-1:0] IF_ID_PC_out;
wire [2-1:0] ALU_op_o;
wire        ALUSrc_o;
wire        ALU_shamt;
wire        RegWrite_o;
wire [2-1:0] RegDst_o;
wire [2-1:0] Branch_o;
wire        Jump_o;
wire        MemRead_o;
wire        MemWrite_o;
wire [2-1:0] MemtoReg_o;
wire [32-1:0] RSdata_from_reg;
wire [32-1:0] RTdata_from_reg;
wire [32-1:0] write_back_data;
wire [4-1:0] ALU_control;
wire [32-1:0] ALU_output;
wire        zero;
wire        cout;
wire        overflow;
wire [32-1:0] data_from_memory;
wire [32-1:0] sign_extend_output;
wire        ID_EX_WB_RegWrite_out;
wire [2-1:0] ID_EX_WB_MemtoReg_out;
wire [2-1:0] ID_EX_M_Branch_out;
wire        ID_EX_M_MemRead_out;
wire        ID_EX_M_MemWrite_out;
wire [32-1:0] ID_EX_PC_current_out;
wire [32-1:0] ID_EX_RSdata_out;
wire [32-1:0] ID_EX_RTdata_out;
wire [32-1:0] ID_EX_sign_extend_out;
wire [5-1:0] instruction_20_16_out;
wire [5-1:0] instruction_15_11_out;
wire [32-1:0] shift_for_branch_output;
wire [32-1:0] branch_adder_output;
wire        ID_EX_EX_RegDst_out;
wire        ID_EX_EX_ALUSrc_out;
wire [2-1:0] ID_EX_EX_ALUOp_out;
wire [32-1:0] mux_RT_output;
wire         EX_MEM_WB_RegWrite_out;
wire [2-1:0] EX_MEM_WB_MemtoReg_out;
wire [5-1:0] mux_regdst_out;
wire [2-1:0] EX_MEM_M_Branch_out;
wire        EX_MEM_M_MemRead_out;
wire        EX_MEM_M_MemWrite_out;
wire [32-1:0] EX_MEM_branch_adder_output;
wire        EX_MEM_Zero_out;
wire [32-1:0] EX_MEM_ALU_output_output;
wire [5-1:0] EX_MEM_mux_regdst_output;
wire [32-1:0] EX_MEM_RTdata_output;
wire         PCSrc;
wire [32-1:0] MEM_WB_data_from_memory_out;
wire [32-1:0] MEM_WB_ALU_output_out;
wire [5-1:0] MEM_WB_mux_regdst_out_output;
wire [32-1:0] PC_out_next;
wire         MEM_WB_WB_MemtoReg_out;
wire [32-1:0] pc_mux_out;
wire        final_RegWrite;



// IF stage==============================================================================

MUX_2to1 #(.size(32)) PC_mux (
    .src1(pc_plus_4),
    .src2(EX_MEM_branch_adder_output),
    .select(PCSrc),
    .result(pc_mux_out)
);
assign pc_out_next = rst_i ? pc_mux_out : pc_plus_4;
ProgramCounter PC (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .pc_in_i(pc_out_next),
    .pc_out_o(pc_current_address)
);

Instruction_Memory IM (
    .addr_i(pc_current_address),
    .instr_o(instruction)
);

Adder PC_adder (
    .src1_i(pc_current_address),
    .src2_i(32'd4),
    .sum_o(pc_plus_4)
);

Pipe_Reg #(.size(32)) IF_ID_IM (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? instruction:32'b0),
    .data_o(IF_ID_IM_out)
);

Pipe_Reg #(.size(32)) IF_ID_PC (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? pc_current_address:32'b0),
    .data_o(IF_ID_PC_out)
);

// ID stage =====================================================================================
Decoder Dc(
        .instr_op_i(IF_ID_IM_out[31:26]),
        .ALU_op_o(ALU_op_o), 
        .ALUSrc_o(ALUSrc_o), 
        .RegWrite_o(RegWrite_o), 
        .RegDst_o(RegDst_o), 
        .Branch_o(Branch_o), 
        .Jump_o(Jump_o), 
        .MemRead_o(MemRead_o), 
        .MemWrite_o(MemWrite_o), 
        .MemtoReg_o(MemtoReg_o)
);
assign final_RegWrite = MEM_WB_WB_RegWrite_out & (MEM_WB_mux_regdst_out_output != 5'b0);
Reg_File RF(
        .clk_i(clk_i),
        .rst_i(rst_i),     
        .RSaddr_i(IF_ID_IM_out[25:21]),
        .RTaddr_i(IF_ID_IM_out[20:16]),
        .RDaddr_i(MEM_WB_mux_regdst_out_output), 
        .RDdata_i(write_back_data),
        .RegWrite_i(final_RegWrite),
        .RSdata_o(RSdata_from_reg),  
        .RTdata_o(RTdata_from_reg) 
);

Sign_Extend Sign_Extend(
        .data_i(IF_ID_IM_out[15:0]),
        .data_o(sign_extend_output)
);

Pipe_Reg #(.size(1)) ID_EX_WB_RegWrite (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? RegWrite_o:1'b0),
    .data_o(ID_EX_WB_RegWrite_out)
);
Pipe_Reg #(.size(2)) ID_EX_WB_MemtoReg (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? MemtoReg_o:2'b0),
    .data_o(ID_EX_WB_MemtoReg_out)
);
Pipe_Reg #(.size(2)) ID_EX_M_Branch (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? Branch_o:2'b0),
    .data_o(ID_EX_M_Branch_out)
);
Pipe_Reg #(.size(1)) ID_EX_M_MemRead (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? MemRead_o:1'b0),
    .data_o(ID_EX_M_MemRead_out)
);
Pipe_Reg #(.size(1)) ID_EX_M_MemWrite (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? MemWrite_o:1'b0),
    .data_o(ID_EX_M_MemWrite_out)
);
Pipe_Reg #(.size(1)) ID_EX_EX_RegDst (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? RegDst_o[0]:1'b0),
    .data_o(ID_EX_EX_RegDst_out)
);
Pipe_Reg #(.size(1)) ID_EX_EX_ALUSrc (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? ALUSrc_o:1'b0),
    .data_o(ID_EX_EX_ALUSrc_out)
);
Pipe_Reg #(.size(2)) ID_EX_EX_ALUOp (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? ALU_op_o:2'b0),
    .data_o(ID_EX_EX_ALUOp_out)
);
Pipe_Reg #(.size(32)) ID_EX_PC_current ( 
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? IF_ID_PC_out:32'b0),
    .data_o(ID_EX_PC_current_out)
);
Pipe_Reg #(.size(32)) ID_EX_RSdata (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? RSdata_from_reg:32'b0),
    .data_o(ID_EX_RSdata_out)
);
Pipe_Reg #(.size(32)) ID_EX_RTdata (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? RTdata_from_reg:32'b0),
    .data_o(ID_EX_RTdata_out)
);
Pipe_Reg #(.size(32)) ID_EX_sign_extend (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? sign_extend_output:32'b0),
    .data_o(ID_EX_sign_extend_out)
);
Pipe_Reg #(.size(5)) instruction_20_16 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? IF_ID_IM_out[20:16]:5'b0),
    .data_o(instruction_20_16_out)
);
Pipe_Reg #(.size(5)) instruction_15_11 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? IF_ID_IM_out[15:11]:5'b0),
    .data_o(instruction_15_11_out)
);




// EX stage =====================================================================================

Shift_Left_Two_32 shift_for_branch (
    .data_i(ID_EX_sign_extend_out), 
    .data_o(shift_for_branch_output)
);
Adder branch_adder (
    .src1_i(ID_EX_PC_current_out),
    .src2_i(shift_for_branch_output),
    .sum_o(branch_adder_output)
);
MUX_2to1 #(.size(32)) mux_RT(
    .src1(ID_EX_RTdata_out),
    .src2(ID_EX_sign_extend_out),
    .select(ID_EX_EX_ALUSrc_out),
    .result(mux_RT_output)
);
ALU_Ctrl ALU_Ctrl(
    .funct_i(ID_EX_sign_extend_out[5:0]),
    .ALUOp_i(ID_EX_EX_ALUOp_out),
    .ALUCtrl_o(ALU_control)
);
ALU alu(
    .rst_n(rst_i),
    .src1(ID_EX_RSdata_out),
    .src2(mux_RT_output),
    .ALU_control(ALU_control),
    .shamt(ID_EX_sign_extend_out[10:6]),
    .result(ALU_output),
    .zero(zero),
    .cout(cout),
    .overflow(overflow)
);
MUX_2to1 #(.size(5)) mux_regdst (
    .src1(instruction_20_16_out),
    .src2(instruction_15_11_out),
    .select(ID_EX_EX_RegDst_out),
    .result(mux_regdst_out)
);
Pipe_Reg #(.size(1)) EX_MEM_WB_RegWrite (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? ID_EX_WB_RegWrite_out:1'b0),
    .data_o(EX_MEM_WB_RegWrite_out)
);
Pipe_Reg #(.size(2)) EX_MEM_WB_MemtoReg (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? ID_EX_WB_MemtoReg_out:2'b0),
    .data_o(EX_MEM_WB_MemtoReg_out)
);
Pipe_Reg #(.size(2)) EX_MEM_M_Branch (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? ID_EX_M_Branch_out:2'b0),
    .data_o(EX_MEM_M_Branch_out)
);
Pipe_Reg #(.size(1)) EX_MEM_M_MemRead (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? ID_EX_M_MemRead_out:1'b0),
    .data_o(EX_MEM_M_MemRead_out)
);
Pipe_Reg #(.size(1)) EX_MEM_M_MemWrite (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? ID_EX_M_MemWrite_out:1'b0),
    .data_o(EX_MEM_M_MemWrite_out)
);
Pipe_Reg #(.size(32)) EX_MEM_branch_adder (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? branch_adder_output:32'b0),
    .data_o(EX_MEM_branch_adder_output)
);
Pipe_Reg #(.size(1)) EX_MEM_Zero (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? zero:1'b0),
    .data_o(EX_MEM_Zero_out)
);
Pipe_Reg #(.size(32)) EX_MEM_ALU_output (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? ALU_output:32'b0),
    .data_o(EX_MEM_ALU_output_output)
);
Pipe_Reg #(.size(32)) EX_MEM_RTdata (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? ID_EX_RTdata_out:32'b0),
    .data_o(EX_MEM_RTdata_output)
);
Pipe_Reg #(.size(5)) EX_MEM_mux_regdst (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? mux_regdst_out:5'b0),
    .data_o(EX_MEM_mux_regdst_output)
);

// MEM stage =====================================================================================
assign PCSrc = (rst_i == 1'b1) ? ((EX_MEM_M_Branch_out[0] & EX_MEM_Zero_out) | (EX_MEM_M_Branch_out[1] & ~EX_MEM_Zero_out)) : 1'b0;

Data_Memory DM (
    .clk_i(clk_i),
    .addr_i(EX_MEM_ALU_output_output),
    .data_i(EX_MEM_RTdata_output),
    .MemRead_i(EX_MEM_M_MemRead_out),
    .MemWrite_i(EX_MEM_M_MemWrite_out),
    .data_o(data_from_memory)
);
Pipe_Reg #(.size(1)) MEM_WB_WB_RegWrite (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? EX_MEM_WB_RegWrite_out:1'b0),
    .data_o(MEM_WB_WB_RegWrite_out)
);
Pipe_Reg #(.size(1)) MEM_WB_WB_MemtoReg (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? EX_MEM_WB_MemtoReg_out[0]:1'b0),
    .data_o(MEM_WB_WB_MemtoReg_out)
);
Pipe_Reg #(.size(32)) MEM_WB_data_from_memory (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? data_from_memory:32'b0),
    .data_o(MEM_WB_data_from_memory_out)
);
Pipe_Reg #(.size(32)) MEM_WB_ALU_output (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? EX_MEM_ALU_output_output:32'b0),
    .data_o(MEM_WB_ALU_output_out)
);
Pipe_Reg #(.size(5)) MEM_WB_mux_regdst_out (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(rst_i ? EX_MEM_mux_regdst_output:5'b0),
    .data_o(MEM_WB_mux_regdst_out_output)
);

// WB stage =====================================================================================

MUX_2to1 #(.size(32)) mux_write_back(
    .src1(MEM_WB_ALU_output_out),
    .src2(MEM_WB_data_from_memory_out),
    .select(MEM_WB_WB_MemtoReg_out),
    .result(write_back_data)
);


// Components

// Components in IF stage



// Components in ID stage



// Components in EX stage	   



// Components in MEM stage



// Components in WB stage


endmodule