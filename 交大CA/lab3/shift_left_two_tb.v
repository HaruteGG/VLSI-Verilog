`timescale 1ns / 10ps

module Shift_Left_Two_32_tb;
    reg [32-1:0] data_i;
    wire [32-1:0] data_o;
    
    Shift_Left_Two_32 uut(
        .data_i(data_i),
        .data_o(data_o)
    );
    initial begin
        $dumpfile("Shift_Left_Two_32.vcd");
        $dumpvars(0, Shift_Left_Two_32_tb);
        data_i = 32'h00000001; // Test input
        #1
        
        $display("Input: %h, Output: %h", data_i, data_o);

        #10; // Wait for 10 time units
        $finish;
    end
endmodule
