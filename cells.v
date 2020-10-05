module cells(match_lines, write_lines, read_lines, mismatch_lines);
input [63:0] mismatch_lines;
input [63:0] write_lines;
output wire [99:0] match_lines;
output [31:0] read_lines;
reg [31:0] store[99:0];
reg temp;
wire [99:0] [31:0] temp_wires;

genvar i,j;
generate
for(i = 0; i<100; i = i+1) begin
    assign temp_wires[i][0] = (mismatch_lines[1] & store[i][0]) || (mismatch_lines[0] & !store[i][0]);
    for(j = 1; j<32; j = j+1) begin
        assign temp_wires[i][j] = temp_wires[i][j-1] || (mismatch_lines[2*j + 1] & store[i][j]) || (mismatch_lines[2*j] & !store[i][j]);
  end
    assign match_lines[i] = temp_wires[i][31];
end
endgenerate


integer idx;
initial begin
  store[0] <= 456;
  store[1] <= 457;
  store[2] <= 1000;
  store[3] <= 1000;
  store[4] <= 457;
  #10000

  for(idx = 0; idx<5; idx= idx+1) begin
    $display("idx:%d value:%d, mismatch: %d", idx, store[idx], match_lines[idx]);
  end
end

//assign match_lines = temp_wires[99];

/*
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
