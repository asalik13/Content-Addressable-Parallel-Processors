module cells(match_lines, write_lines, read_lines, mismatch_lines, tags, CLK);
input CLK;
input [99:0] tags;

input [63:0] mismatch_lines;
input [63:0] write_lines;
output wire [99:0] match_lines;
output wire [31:0] read_lines;
reg [99:0][31:0] store;
wire [31:0] temp_search_wires [99:0];
wire [31:0] temp_read_wires [99:0];
wire [99:0][31:0] store_wires;



genvar i,j;
//match_lines
for(i = 0; i<100; i = i+1) begin
    assign temp_search_wires[i][0] = (mismatch_lines[1] & store[i][0]) || (mismatch_lines[0] & !store[i][0]);
    for(j = 1; j<32; j = j+1) begin
        assign temp_search_wires[i][j] = temp_search_wires[i][j-1] || (mismatch_lines[2*j + 1] & store[i][j]) || (mismatch_lines[2*j] & !store[i][j]);
  end
    assign match_lines[i] = temp_search_wires[i][31];
end



//write lines
for (i = 0; i<100; i = i+1) begin
  for (j = 0; j<32; j = j+1) begin
    srff_behave flipflop(store_wires[i][j], (tags[i] && write_lines[2*j]), (tags[i] && write_lines[2*j+1]), CLK);
  end
end



always@(posedge CLK) begin
  store <= store_wires;
end

/*
integer idx;
initial begin
for(idx = 0; idx <100; idx = idx + 1) begin
store[idx] = idx;
end
end
*/


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

endmodule
