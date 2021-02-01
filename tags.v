module tags
#( parameter num_bits = 32, parameter num_cells = 100 )
(match_lines, set, select_first, tag_wires, some_none, CLK);

input wire [num_cells - 1:0] match_lines;
input wire select_first;
input wire set;
input wire [num_cells - 1:0] tag_wires;

input CLK;
output reg [num_cells - 1:0] some_none;
wire [num_cells - 1:0] temp;

reg [num_cells - 1:0] tag_regs; 
integer j, k;
always @(posedge CLK) begin

  if(set)
    tag_regs = '1;
  else if(match_lines[0]) 
      tag_regs[0] = 0;

  some_none[0] = tag_regs[0];
  for(j = 1; j < num_cells; j = j+1) begin: random
    some_none[j] = some_none[j - 1] || tag_regs[j];
    if((some_none[j - 1] && select_first) || match_lines[j]) begin
      tag_regs[j] <= 0;
    end  
  end
end

assign tag_wires = tag_regs;

endmodule