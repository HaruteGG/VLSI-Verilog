`timescale 1ns / 10ps

module MUX_3to1_tb; 
    reg   [32-1:0] data0_i;          
    reg   [32-1:0] data1_i;
    reg   [32-1:0] data2_i;
    reg   [2-1:0]  select_i;

    wire  [32-1:0] data_o; 
    MUX_3to1  #(.size(32))
        uut (
            .data0_i(data0_i),
            .data1_i(data1_i),
            .data2_i(data2_i),
            .select_i(select_i),
            .data_o(data_o)
        );
    initial begin
        $dumpfile("MUX_3to1.vcd");
        $dumpvars(0, MUX_3to1_tb);

        data0_i = 32'hdeadbeef;
        data1_i = 32'h12345678;
        data2_i = 32'h87654321;
        select_i = 2'b00;

        #2

        $display("Time: %t, Select: %b, Data0: %h, Data1: %h, Data2: %h, Output: %h",
                 $time, select_i, data0_i, data1_i, data2_i, data_o);

        #10; // 等待 10ns
        select_i = 2'b01; // 改變選擇訊號
        #2  
        $display("Time: %t, Select: %b, Data0: %h, Data1: %h, Data2: %h, Output: %h",
                 $time, select_i, data0_i, data1_i, data2_i, data_o);
        #10; // 等待 10ns
        select_i = 2'b10; // 改變選擇訊號
        #2
        $display("Time: %t, Select: %b, Data0: %h, Data1: %h, Data2: %h, Output: %h",
                 $time, select_i, data0_i, data1_i, data2_i, data_o);
        #10; // 等待 10ns
        $finish; // 結束模擬
    end
endmodule