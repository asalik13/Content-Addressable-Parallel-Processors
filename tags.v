module tags(mismatch_lines, set, select_first, tag_wires, CLK);
input wire [99:0] mismatch_lines;
input wire select_first;
input wire set;
input CLK;
output wire [99:0] tag_wires;
reg [99:0] tags;
wire some_none;
genvar i;

assign tag_wires = tags;
assign some_none = tags[0];
srff_behave flipflop (tag_wires[0], set, mismatch_lines[0], CLK);

generate
wire temp;
for(i = 1; i<99; i=i+1) begin
  or(some_none, some_none, tags[i]);
  and(temp, some_none, select_first);
  or(temp, temp, mismatch_lines[i]);
  srff_behave flipflop (tag_wires[i], set, temp, CLK);
  end
endgenerate

always @ (posedge CLK) begin
  tags <= tag_wires;
end

endmodule
