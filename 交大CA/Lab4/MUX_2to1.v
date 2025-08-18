// student ID:614001005
module MUX_2to1(
               src1,
               src2,
               select,
               result
               );

parameter size = 1;			   
			
// I/O ports               
input   [size-1:0] src1;          
input   [size-1:0] src2;
input              select;

output  [size-1:0] result; 

// Internal Signals
reg    [size-1:0] result_reg;
// Main function
always@(*)begin
	case (select)
        1'b0: result_reg = src1;
        1'b1: result_reg = src2;
        default: result_reg = {size{1'bx}};
    endcase
end
assign result = result_reg;
endmodule      