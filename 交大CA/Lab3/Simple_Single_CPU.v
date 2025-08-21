// student ID :614001005

`include "ProgramCounter.v"
`include "Instr_Memory.v"
`include "Reg_File.v"
`include "Data_Memory.v"
`include "ALU_Ctrl.v"
`include "ALU.v"
`include "Sign_Extend.v"
`include "Decoder.v"
`include "Adder.v"
`include "Shift_Left_Two_32.v"
`include "MUX_3to1.v"



module Simple_Single_CPU(
        clk_i,
	rst_i
);


// I/O port
input         clk_i;
input         rst_i;

// Internal Signals
wire [32-1:0] pc_out_next; 
wire [32-1:0] pc_current_address; 
wire [32-1:0] instruction; 
wire [32-1:0] pc_plus_4;
wire [2-1:0] ALU_op_o;
wire       ALUSrc_o;
wire       ALU_shamt;
wire       RegWrite_o;
wire [2-1:0] RegDst_o;
wire [2-1:0] Branch_o;
wire       Jump_o;
wire       MemRead_o;
wire       MemWrite_o;
wire [2-1:0] MemtoReg_o;
wire [32-1:0] RSdata_from_reg;
wire [32-1:0] RTdata_from_reg;
wire [32-1:0] write_back_data;
wire [5-1:0] write_reg_addr;
wire [4-1:0] ALU_control;
wire [32-1:0] ALU_output;
wire       zero;
wire       cout;
wire       overflow;
wire [32-1:0] data_from_memory;
wire [32-1:0] sign_extend_output;
wire [32-1:0] jump_addr;
wire [32-1:0] shift_for_jump_output;
wire [32-1:0] shift_for_branch_output;
wire [32-1:0] branch_adder_output;
wire [32-1:0] branch_mux_output;
wire       branch_control;
// Components
ProgramCounter PC(
        .clk_i(clk_i),      
        .rst_i(rst_i),     
        .pc_in_i(pc_out_next),   
        .pc_out_o(pc_current_address) 
);

Instr_Memory IM(
        .pc_addr_i(pc_current_address),  
        .instr_o(instruction)    
);
Shift_Left_Two_32 shift_for_jump (
        .data_i({6'b000000, instruction[25:0]}), // Jump address
        .data_o(shift_for_jump_output)
);
assign jump_addr = {pc_plus_4[31:28], shift_for_jump_output[27:0]};
Adder PC_adder(
        .src1_i(pc_current_address), 
        .src2_i(32'd4), 
        .sum_o(pc_plus_4) 
);
Shift_Left_Two_32 shift_for_branch (
        .data_i(sign_extend_output), 
        .data_o(shift_for_branch_output)
);
Adder branch_adder(
        .src1_i(pc_current_address), 
        .src2_i(shift_for_branch_output), 
        .sum_o(branch_adder_output)
);
assign branch_control = (Branch_o[0] & zero) | (Branch_o[1] & ~zero);
MUX_2to1 #(.size(32)) mux_branch(
        .src1(pc_plus_4), 
        .src2(branch_adder_output), 
        .select(branch_control), 
        .result(branch_mux_output)
);
MUX_2to1 #(.size(32)) mux_jump(
        .src1(branch_mux_output), 
        .src2(jump_addr), 
        .select(Jump_o), 
        .result(pc_out_next)
);

Decoder Dc(
        .instr_op_i(instruction[31:26]),
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

MUX_3to1 #(.size(5)) mux_write_reg(
        .data0_i(instruction[20:16]),
        .data1_i(instruction[15:11]),
        .data2_i(5'b11111), // $ra
        .select_i(RegDst_o),
        .data_o(write_reg_addr)
);

Reg_File Registers(
        .clk_i(clk_i),
        .rst_i(rst_i),     
        .RSaddr_i(instruction[25:21]),
        .RTaddr_i(instruction[20:16]),
        .RDaddr_i(write_reg_addr), 
        .RDdata_i(write_back_data),
        .RegWrite_i(RegWrite_o),
        .RSdata_o(RSdata_from_reg),  
        .RTdata_o(RTdata_from_reg) 
);

ALU_Ctrl ALU_Ctrl(
        .funct_i(instruction[5:0]),
        .ALUOp_i(ALU_op_o),
        .ALUCtrl_o(ALU_control)
);
Sign_Extend Sign_Extend(
        .data_i(instruction[15:0]),
        .data_o(sign_extend_output)
);
ALU alu(
        .rst_n(rst_i),
        .src1(RSdata_from_reg),
        .src2(ALUSrc_o ? sign_extend_output : RTdata_from_reg),
        .ALU_control(ALU_control),
        .shamt(instruction[10:6]),
        .result(ALU_output),
        .zero(zero),
        .cout(cout),
        .overflow(overflow)
);

Data_Memory Data_Memory(
	.clk_i(clk_i), 
	.addr_i(ALU_output), 
	.data_i(RTdata_from_reg), 
	.MemRead_i(MemRead_o), 
	.MemWrite_i(MemWrite_o), 
	.data_o(data_from_memory)
);

MUX_3to1 #(.size(32)) mux_write_back(
        .data0_i(ALU_output),
        .data1_i(data_from_memory),
        .data2_i(pc_plus_4), // jal
        .select_i(MemtoReg_o),
        .data_o(write_back_data)
);

endmodule
