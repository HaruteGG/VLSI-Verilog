`timescale 1ns/10ps

module MUX_2to1_tb; 
    reg   [32-1:0] data0_i;          
    reg   [32-1:0] data1_i;
    reg            select_i;

    wire  [32-1:0] data_o; 
    MUX_2to1  #(.size(32))
        uut (
            .data0_i(data0_i),
            .data1_i(data1_i),
            .select_i(select_i),
            .data_o(data_o)
        );
     initial begin
        $dumpfile("MUX_2to1.vcd");
        $dumpvars(0, MUX_2to1_tb);
        // 初始化訊號
        data0_i = 32'hdeadbeef;
        data1_i = 32'h12345678;
        select_i = 1'b0;

        #2
        // 觀察點 1
        $display("Time: %t, Select: %b, Data0: %h, Data1: %h, Output: %h",
                 $time, select_i, data0_i, data1_i, data_o);
        
        #10; // 等待 10ns
        
        // 改變選擇訊號，觀察輸出是否變化
        select_i = 1'b1;
        #2
        // 觀察點 2
        $display("Time: %t, Select: %b, Data0: %h, Data1: %h, Output: %h",
                 $time, select_i, data0_i, data1_i, data_o);
                 
        #10; // 等待 10ns
        
        // 結束模擬
        $finish;
    end
    
endmodule


 