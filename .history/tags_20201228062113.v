module tags
#( parameter num_bits = 32, parameter num_cells = 100 )
(match_lines, set, select_first, tag_wires, some_none, CLK);

input wire [num_cells - 1:0] match_lines;
input wire select_first;
input wire set;
input wire [num_cells - 1:0] tag_wires;

input CLK;
output [num_cells - 1:0] some_none;
wire [num_cells - 1:0] temp;
assign some_none[0] = tag_wires[0];


srff_behave flip (tag_wires[0], set, match_lines[0], CLK);


genvar i;
generate
for(i = 1; i<num_cells; i=i+1) begin: random
  assign some_none[i] = some_none[i-1] || tag_wires[i];
  assign temp[i] = (some_none[i - 1] && select_first) || match_lines[i];
  srff_behave flipflop (tag_wires[i], set, temp[i], CLK);
end
endgenerate


endmodule
