module cells(match_lines, write_lines, read_lines, mismatch_lines);
input [63:0] mismatch_lines;
input [63:0] write_lines;
output reg [99:0] match_lines;
output [31:0] read_lines;
reg [31:0] store[0:99];
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

initial begin
store[0] <= 456;
store[1] <= 457;
store[5] <= 457;
store[4] <= 1000;
#10000

$display("match lines: %b", match_lines);
$display("store 0: %b", store[0]);
end
/*
genvar i,j;
generate
  for(i=0; i<100; i = i+1) begin
    reg temp = 1'b0;
     for(j=0; j<32; j = j+1) begin
       assign match_lines[i] = match_lines[i] || (mismatch_lines[j+j] & store[i][j]) || (mismatch_lines[j+j+1] & (!store[i][j]));
       assign read_lines[j] = (match_lines[i] && store[i][j]) || read_lines[j];
       always @ ( * ) begin
        if(mismatch_lines[i])
          begin
            if (write_lines[j+j])
                store[i][j] <= 1;
            else if (write_lines[j+j+1])
                store[i][j] <= 0;
          end
       end

     end
  end

endgenerate
*/
endmodule
