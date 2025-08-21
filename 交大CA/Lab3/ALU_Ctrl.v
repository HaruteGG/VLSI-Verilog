// student ID:614001005
module ALU_Ctrl(
        funct_i,
        ALUOp_i,
        ALUCtrl_o
        );
          
// I/O ports 
input      [6-1:0] funct_i;
input      [2-1:0] ALUOp_i;

output     [4-1:0] ALUCtrl_o;  
     
// Internal Signals
reg [4-1:0] ALUCtrl_o_reg;

// Main function
always @(*) begin
        case(ALUOp_i)
            2'b00: ALUCtrl_o_reg = 4'b0010;
            2'b01: ALUCtrl_o_reg = 4'b0110;
            2'b10: begin
                case(funct_i)
                        6'b100011: ALUCtrl_o_reg = 4'b0010; // add
                        6'b100001: ALUCtrl_o_reg = 4'b0110; // sub
                        6'b100110: ALUCtrl_o_reg = 4'b0001; // and
                        6'b100101: ALUCtrl_o_reg = 4'b0000; // or
                        6'b101011: ALUCtrl_o_reg = 4'b1101; // nor
                        6'b101000: ALUCtrl_o_reg = 4'b0111; // slt
                        6'b000010: ALUCtrl_o_reg = 4'b1000; // sll
                        6'b000100: ALUCtrl_o_reg = 4'b1001; // srl
                        6'b000110: ALUCtrl_o_reg = 4'b1010; // sllv
                        6'b001000: ALUCtrl_o_reg = 4'b1011; // srlv
                        6'b001100: ALUCtrl_o_reg = 4'b1100; // jr
                        default:   ALUCtrl_o_reg = 4'b1111; 
                endcase
            end
            default: ALUCtrl_o_reg = 4'b1111; // Invalid operation
        endcase
end  
assign ALUCtrl_o = ALUCtrl_o_reg;
endmodule