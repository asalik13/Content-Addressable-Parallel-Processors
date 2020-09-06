module cells(match_lines, write_lines, read_lines, tags);
input [63:0] match_lines;
input [63:0] write_lines;
output [4:0] tags;
output [31:0] read_lines;
reg [31:0] store[0:4];





genvar i,j;
generate
  for(i=0; i<5; i = i+1) begin
     for(j=0; j<32; j = j+1) begin
       assign tags[i] = tags[i] || (match_lines[j+j] & store[i][j]) || (match_lines[j+j+1] & (!store[i][j]));
       assign read_lines[j] = (tags[i] && store[i][j]) || read_lines[j];
       always @ ( * ) begin
        if(tags[i])
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

endmodule
