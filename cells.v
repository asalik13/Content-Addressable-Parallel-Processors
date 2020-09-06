

module cells(match_lines, tags);
input [63:0] match_lines;
output [99:0] tags;
reg [31:0] store[0:99];
genvar i,j;
generate
for(i=0; i<100; i = i+1) begin
   for(j=0; j<32; j = j+1) begin
     assign tags[i] = tags[i] || (match_lines[j+j] & store[i][j]) || (match_lines[j+j+1] & (!store[i][j]));
   end
  end
endgenerate

endmodule
