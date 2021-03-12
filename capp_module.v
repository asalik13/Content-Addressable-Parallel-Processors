
module capp_module 
#( parameter num_bits = 32, parameter num_cells = 100 )
(CLK, comparand, mask, perform_search, set, select_first, write_lines, tag_wires, read_lines);
input CLK;

input  [num_bits - 1:0] comparand;
input  [num_bits - 1:0] mask;
input  perform_search;
input set;
input select_first;
input [2*num_bits - 1:0] write_lines;
output [num_cells - 1:0] tag_wires;
output [num_bits - 1:0] read_lines;
 

wire [2*num_bits - 1:0] mismatch_lines;
wire [num_cells - 1:0] match_lines;
wire [num_cells - 1:0] some_none;


compare #(num_bits, num_cells) compare_module (CLK, comparand,mask,perform_search, mismatch_lines);
cells #(num_bits, num_cells) cells_module (match_lines, write_lines, read_lines, mismatch_lines, tag_wires, CLK);
tags  #(num_bits, num_cells)tags_module(match_lines, set, select_first, tag_wires, some_none, CLK);

endmodule