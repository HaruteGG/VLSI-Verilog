// ID:614001005
module Hazard_Detection(
    memread,
    instr_i,
    idex_regt,
    branch,
    pcwrite,
    ifid_write,
    ifid_flush,
    idex_flush,
    exmem_flush
);
input memread;
input [32-1:0] instr_i;
input [5-1:0] idex_regt;
input branch;
output pcwrite;
output ifid_write;
output ifid_flush;
output idex_flush;
output exmem_flush;
reg pcwrite_reg, ifid_write_reg, ifid_flush_reg, idex_flush_reg, exmem_flush_reg;
// TO DO
always@(*)begin
    if(memread && ((idex_regt == instr_i[25:21]) || (idex_regt == instr_i[20:16]))) begin
        pcwrite_reg = 1'b0;
        ifid_write_reg = 1'b0;
        ifid_flush_reg = 1'b0;
        idex_flush_reg = 1'b1;
        exmem_flush_reg = 1'b0;
    end else if(branch)begin
        pcwrite_reg = 1'b1;
        ifid_write_reg = 1'b1;
        ifid_flush_reg = 1'b1;
        idex_flush_reg = 1'b1;
        exmem_flush_reg = 1'b1;
    end else begin
        pcwrite_reg = 1'b1;
        ifid_write_reg = 1'b1;
        ifid_flush_reg = 1'b0;
        idex_flush_reg = 1'b0;
        exmem_flush_reg = 1'b0;
    end
end
assign pcwrite = pcwrite_reg;
assign ifid_write = ifid_write_reg;
assign ifid_flush = ifid_flush_reg;
assign idex_flush = idex_flush_reg;
assign exmem_flush = exmem_flush_reg;
endmodule