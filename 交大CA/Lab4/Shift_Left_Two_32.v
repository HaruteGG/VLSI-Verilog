// student ID:614001005
module Shift_Left_Two_32(
    data_i,
    data_o
    );

// I/O ports                    
input [32-1:0] data_i;

output [32-1:0] data_o;

// Internal Signals
reg [32-1:0] data_o_reg;

// Main function
always @(*) begin
    data_o_reg = data_i << 2;
end
assign data_o = data_o_reg;
     
endmodule
