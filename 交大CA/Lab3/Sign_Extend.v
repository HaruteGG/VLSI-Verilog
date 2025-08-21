// student ID:614001005
module Sign_Extend(
    data_i,
    data_o
    );
               
// I/O ports
input   [16-1:0] data_i;

output  [32-1:0] data_o;

// Internal Signals
reg [32-1:0] data_o_reg;

// Main function
always @(*) begin
    if(data_i[15]) begin
        data_o_reg = {16'b1111111111111111, data_i};
    end else begin
        data_o_reg = {16'b0000000000000000, data_i};
    end
end
assign data_o = data_o_reg;
endmodule
  
     