// ID:614001005
module Forwarding_Unit(
    regwrite_mem,
    regwrite_wb,
    idex_regs,
    idex_regt,
    exmem_regd,
    memwb_regd,
    forwarda,
    forwardb
);
input          regwrite_mem;
input          regwrite_wb;
input  [5-1:0] idex_regs;
input  [5-1:0] idex_regt;
input  [5-1:0] exmem_regd;
input  [5-1:0] memwb_regd;
output [2-1:0] forwarda;
output [2-1:0] forwardb;
reg [2-1:0] forwarda_out, forwardb_out;
// TO DO
always@(*)begin
    forwarda_out = 2'b00;
    forwardb_out = 2'b00;
    
    if(regwrite_mem && (exmem_regd != 0) && (exmem_regd == idex_regs)) begin
        forwarda_out = 2'b01;
    end else if(regwrite_wb && (memwb_regd != 0) && (memwb_regd == idex_regs)) begin
        forwarda_out = 2'b10;    
    end



    if(regwrite_mem && (exmem_regd != 0) && (exmem_regd == idex_regt)) begin
        forwardb_out = 2'b01;
    end else if(regwrite_wb && (memwb_regd != 0) && (memwb_regd == idex_regt)) begin
        forwardb_out = 2'b10;
    end
end
assign forwarda = forwarda_out;
assign forwardb = forwardb_out;
endmodule