// student ID:614001005
module MUX_2to1(
               data0_i,
               data1_i,
               select_i,
               data_o
               );

parameter size = 0;			   
			
// I/O ports               
input   [size-1:0] data0_i;          
input   [size-1:0] data1_i;
input              select_i;

output  [size-1:0] data_o; 

// Internal Signals
reg    [size-1:0] data_o_reg;
// Main function
always@(*)begin
	case (select_i)
        1'b0: data_o_reg = data0_i;
        1'b1: data_o_reg = data1_i;
        default: data_o_reg = {size{1'bx}};
    endcase
end
assign data_o = data_o_reg;
endmodule      
          
          