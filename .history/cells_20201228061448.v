module cells
#( parameter num_bits = 32, parameter num_cells = 100 )
(match_lines, write_lines, read_lines, mismatch_lines, tags, CLK);
input CLK;
input [num_cells - 1:0] tags;

input [2*num_bits - 1:0] mismatch_lines;
input [2*num_bits - 1:0] write_lines;
output wire [num_cells - 1:0] match_lines;
output wire [num_bits - 1:0] read_lines;
wire [num_bits - 1:0] temp_search_wires [num_cells - 1:0];
wire [num_bits - 1:0] temp_read_wires [num_cells - 1:0];
wire [num_bits - 1:0] store_wires [num_cells - 1:0];



genvar i,j;
//match_lines
for(i = 0; i<num_cells; i = i+1) begin
    assign temp_search_wires[i][0] = (mismatch_lines[1] & store_wires[i][0]) || (mismatch_lines[0] & !store_wires[i][0]);
    for(j = 1; j<num_bits; j = j+1) begin
        assign temp_search_wires[i][j] = temp_search_wires[i][j-1] || (mismatch_lines[2*j + 1] & store_wires[i][j]) 
        || (mismatch_lines[2*j] & !store_wires[i][j]);
  end
    assign match_lines[i] = temp_search_wires[i][num_bits - 1];
end



//write lines
for (i = 0; i<num_cells; i = i+1) begin
  for (j = 0; j<num_bits; j = j+1) begin
    srff_behave flipflop(store_wires[i][j], (tags[i] && write_lines[2*j]), (tags[i] && write_lines[2*j+1]), CLK);
  end
end


//read_lines
//generate temp read lines from first cell
for(j=0; j<num_bits; j=j+1) begin
    assign temp_read_wires[0][j] = store_wires[0][j] && tags[0];
end
//generate all other temp read lines
for(i = 1; i<num_cells; i = i+1) begin
  for(j=0; j<num_bits; j=j+1) begin
      assign temp_read_wires[i][j] = temp_read_wires[i-1][j] || ( store_wires[i][j] && tags[i]);
  end
end
//assign read lines
assign read_lines = temp_read_wires[num_cells - 1];

endmodule
