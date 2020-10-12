module tb; 
reg CLK;
wire [31:0] comparand = 457;
wire [31:0] mask = 32'b111111111;
wire [99:0] tag_wires;
wire [63:0] mismatch_lines;
wire [63:0] write_lines;
wire [99:0] match_lines;
wire [31:0] read_lines;

reg perform_search;
reg set;
reg select_first;


compare compare_module (CLK, comparand,mask,perform_search, mismatch_lines);
cells cells_module (match_lines, write_lines, read_lines, mismatch_lines);
tags tags_module(match_lines, set, select_first, tag_wires, CLK);


initial begin
$monitor("simtime = %g, Tags =  %b", $time, tag_wires);
end

initial begin
  CLK=0;
     forever #5 CLK = ~CLK;  
end 

initial begin 
 #10; 
 set = 1;
 #10;
 set = 0;
 #10;
 perform_search = 1;
end 

endmodule