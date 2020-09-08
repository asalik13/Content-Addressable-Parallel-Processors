module cam(CLK);
input CLK;
reg [31:0] comparand, mask;
wire [99:0] tag_wires;
wire [63:0] match_lines;
wire [63:0] write_lines;
wire [99:0] mismatch_lines;
wire [31:0] read_lines;
wire perform_search, set, select_first;

compare compare_module (comparand,mask,perform_search, mismatch_lines);
cells cells_module (match_lines, write_lines, read_lines, mismatch_lines);
tags tags_module(mismatch_lines, set, select_first, tag_wires, CLK);

endmodule
