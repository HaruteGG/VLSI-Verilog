`timescale 1ns/10ps

module MUX_2to1_tb;
    reg src1_tb;
    reg src2_tb;
    reg select_tb;

    wire result_tb;
    MUX_2to1 UUT (
        .src1(src1_tb),
        .src2(src2_tb),
        .select(select_tb),
        .result(result_tb)    
    );
    initial begin
        $dumpfile("MUX_2to1_tb.vcd");
        $dumpvars(0, MUX_2to1_tb);

        src1_tb = 0;
        src2_tb = 0;
        select_tb = 0;
        #10;
        $display("time = %0t, select = %b, src1 = %b, src2 = %b, result = %b", $time, select_tb, src1_tb, src2_tb, result_tb);
        
        src1_tb = 0;
        src2_tb = 1;
        select_tb = 1;
        #10;
        $display("time = %0t, select = %b, src1 = %b, src2 = %b, result = %b", $time, select_tb, src1_tb, src2_tb, result_tb);
        
        src1_tb = 1;    
        src2_tb = 0;
        select_tb = 1;
        #10;
        $display("time = %0t, select = %b, src1 = %b, src2 = %b, result = %b", $time, select_tb, src1_tb, src2_tb, result_tb);
        
        src1_tb = 1;
        src2_tb = 1;
        select_tb = 1;
        #10;
        $display("time = %0t, select = %b, src1 = %b, src2 = %b, result = %b", $time, select_tb, src1_tb, src2_tb, result_tb);

        $finish;
    end
endmodule