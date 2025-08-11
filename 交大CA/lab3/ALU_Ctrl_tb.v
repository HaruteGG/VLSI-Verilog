`timescale 1ns / 10ps

module ALU_Ctrl_tb;
    reg [6-1:0] funct_i;
    reg [2-1:0] ALUOp_i;
    wire [4-1:0] ALUCtrl_o;
    ALU_Ctrl uut (
        .funct_i(funct_i),
        .ALUOp_i(ALUOp_i),
        .ALUCtrl_o(ALUCtrl_o)
    );
    initial begin
        // Test case 1: ADD operation
        funct_i = 6'b100000; // ADD function code
        ALUOp_i = 2'b10; // R-type instruction
        #10;
        if (ALUCtrl_o !== 4'b0010) $display("Test case 1 failed");

        // Test case 2: SUB operation
        funct_i = 6'b100010; // SUB function code
        ALUOp_i = 2'b10; // R-type instruction
        #10;
        if (ALUCtrl_o !== 4'b0110) $display("Test case 2 failed");

        // Test case 3: AND operation
        funct_i = 6'b100100; // AND function code
        ALUOp_i = 2'b10; // R-type instruction
        #10;
        if (ALUCtrl_o !== 4'b0000) $display("Test case 3 failed");

        // Test case 4: OR operation
        funct_i = 6'b100101; // OR function code
        ALUOp_i = 2'b10; // R-type instruction
        #10;
        if (ALUCtrl_o !== 4'b0001) $display("Test case 4 failed");

        // Test case 5: SLT operation
        funct_i = 6'b101010; // SLT function code
        ALUOp_i = 2'b10; // R-type instruction
        #10;
        if (ALUCtrl_o !== 4'b0111) $display("Test case 5 failed");

        $finish;
    end
endmodule