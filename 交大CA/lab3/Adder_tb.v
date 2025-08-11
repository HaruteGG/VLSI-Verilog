`timescale 1ns / 10ps

module Adder_tb;
    reg  [32-1:0]  src1_i;
    reg  [32-1:0]	 src2_i;

    wire [32-1:0]	 sum_o;

    Adder uut(
        .src1_i(src1_i),
        .src2_i(src2_i),
        .sum_o(sum_o)
    );
    initial begin
        $dumpfile("Adder.vcd");
        $dumpvars(0, Adder_tb);
        
        src1_i = 32'h00000008; // Test input
        src2_i = 32'h00000002; // Test input
        #1;
        
        
        $display("Test passed: %h + %h = %h", src1_i, src2_i, sum_o);
        #10
        
        $finish;
    end
endmodule
