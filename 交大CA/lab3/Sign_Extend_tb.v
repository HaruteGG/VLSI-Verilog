`timescale 1ns / 10ps

module Sign_Extend_tb;
    reg [15:0] data_i;
    wire [31:0] data_o;

    Sign_Extend uut (
        .data_i(data_i),
        .data_o(data_o)
    );

    initial begin
        $dumpfile("Sign_Extend_tb.vcd");
        $dumpvars(0, Sign_Extend_tb);
        // Test case 1: Positive number
        data_i = 16'h1234; // 4660 in decimal
        #10;
        $display("Input: %h, Output: %h", data_i, data_o); // Expected output: 00001234

        // Test case 2: Negative number
        data_i = 16'hFFFE; // -2 in decimal
        #10;
        $display("Input: %h, Output: %h", data_i, data_o); // Expected output: FFFFFFFE

        // Test case 3: Zero
        data_i = 16'h0000; // 0 in decimal
        #10;
        $display("Input: %h, Output: %h", data_i, data_o); // Expected output: 00000000

        // Test case 4: Maximum positive value
        data_i = 16'h7FFF; // 32767 in decimal
        #10;
        $display("Input: %h, Output: %h", data_i, data_o); // Expected output: 00007FFF

        // Test case 5: Minimum negative value
        data_i = 16'h8000; // -32768 in decimal
        #10;
        $display("Input: %h, Output: %h", data_i, data_o); // Expected output: FFFF8000

        $finish;
    end
endmodule