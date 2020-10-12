module cells(match_lines, write_lines, read_lines, mismatch_lines, tags);
input [99:0] tags;
input [63:0] mismatch_lines;
input [63:0] write_lines;
output wire [99:0] match_lines;
output [31:0] read_lines;
reg [31:0] store[99:0];
wire [31:0] temp_search_wires [99:0];
wire [31:0] temp_read_wires [99:0];




genvar i,j;
//match_lines
for(i = 0; i<100; i = i+1) begin
    assign temp_search_wires[i][0] = (mismatch_lines[1] & store[i][0]) || (mismatch_lines[0] & !store[i][0]);
    for(j = 1; j<32; j = j+1) begin
        assign temp_search_wires[i][j] = temp_search_wires[i][j-1] || (mismatch_lines[2*j + 1] & store[i][j]) || (mismatch_lines[2*j] & !store[i][j]);
  end
    assign match_lines[i] = temp_search_wires[i][31];
end



 //read_lines
  //generate temp read lines from first cell
  for(j=0; j<32; j=j+1) begin
      assign temp_read_wires[0][j] = store[0][j] && tags[0];
  end
  //generate all other temp read lines
  for(i = 1; i<100; i = i+1) begin
    for(j=0; j<32; j=j+1) begin
        assign temp_read_wires[i][j] = temp_read_wires[i-1][j] || ( store[i][j] && tags[i]);
    end
  end
  //assign read lines
  assign read_lines = temp_read_wires[99];





integer idx;
initial begin
  store[0] <= 456;
  store[1] <= 457;
  store[2] <= 1000;
  store[3] <= 1000;
  store[4] <= 457;
  for(idx=5; idx<99; idx= idx+1) begin
  store[idx] = idx;
  end
  store[99] = 457;
end

/*
reg temp;
integer i,j;
always @(*) begin
for(i=0; i<100; i = i+1) begin
  temp = 1'b0;
  for(j=0; j<32; j = j+1) begin
    temp = temp || (mismatch_lines[j+j+1] & store[i][j]) || (mismatch_lines[j+j] & !store[i][j]);
  end
  match_lines[i] <= temp;
end
end
*/
endmodule
