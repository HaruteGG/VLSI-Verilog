`timescale 1ns/10ps

module MUX_4to1_tb;
    reg src1_tb;
    reg src2_tb;
    reg src3_tb;
    reg src4_tb;
    reg [2-1:0]select_tb;

    wire result_tb;
    
    MUX_4to1 UUT (
        .src1(src1_tb),
        .src2(src2_tb),
        .src3(src3_tb),
        .src4(src4_tb),
        .select(select_tb),
        .result(result_tb)    
    );
    initial begin
        $dumpfile("MUX_4to1_tb.vcd");
        $dumpvars(0, MUX_4to1_tb);

        src1_tb = 0;
        src2_tb = 0;
        src3_tb = 0;
        src4_tb = 0;
        select_tb = 0;
        #10;
        $display("time = %0t, select = %b, src1 = %b, src2 = %b, src3 = %b, src4 = %b, result = %b", $time, select_tb, src1_tb, src2_tb, src3_tb, src4_tb, result_tb);

        src1_tb = 1;
        src2_tb = 0;
        src3_tb = 0;
        src4_tb = 0;
        select_tb = 0;
        #10;
        $display("time = %0t, select = %b, src1 = %b, src2 = %b, src3 = %b, src4 = %b, result = %b", $time, select_tb, src1_tb, src2_tb, src3_tb, src4_tb, result_tb);

        src1_tb = 0;
        src2_tb = 1;    
        src3_tb = 0;
        src4_tb = 0;
        select_tb = 0;
        #10;
        $display("time = %0t, select = %b, src1 = %b, src2 = %b, src3 = %b, src4 = %b, result = %b", $time, select_tb, src1_tb, src2_tb, src3_tb, src4_tb, result_tb);

        src1_tb = 0;
        src2_tb = 0;
        src3_tb = 1;
        src4_tb = 0;
        select_tb = 2;
        #10;
        $display("time = %0t, select = %b, src1 = %b, src2 = %b, src3 = %b, src4 = %b, result = %b", $time, select_tb, src1_tb, src2_tb, src3_tb, src4_tb, result_tb);

        src1_tb = 0;
        src2_tb = 0;
        src3_tb = 0;
        src4_tb = 1;
        select_tb = 3;
        #10;
        $display("time = %0t, select = %b, src1 = %b, src2 = %b, src3 = %b, src4 = %b, result = %b", $time, select_tb, src1_tb, src2_tb, src3_tb, src4_tb, result_tb);

        $finish;
    end
endmodule