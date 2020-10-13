module tags(match_lines, set, select_first, tags, CLK);

input [99:0] write_cell;
input wire [99:0] match_lines;
input wire select_first;
input wire set;
input CLK;
output reg [99:0] tags;


wire [99:0] tag_wires;
wire [99:0] temp;
wire [99:0] some_none;
assign some_none[0] = tag_wires[0];
srff_behave flip (tag_wires[0], set , match_lines[0], CLK);


genvar i;
generate
for(i = 1; i<100; i=i+1) begin: random
  assign some_none[i] = some_none[i-1] || tag_wires[i];
  assign temp[i] = (some_none[i] & select_first) || match_lines[i];
  srff_behave flipflop (tag_wires[i], set, temp[i], CLK);
end
endgenerate


always@(posedge CLK) begin
tags <= tag_wires;
end

endmodule
