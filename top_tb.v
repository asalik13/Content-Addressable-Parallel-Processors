module tb; 
reg CLK = 1'b1;
reg [31:0] comparand;
reg [31:0] mask;
wire [99:0] tag_wires;
wire [63:0] mismatch_lines;
wire [99:0] match_lines;
wire [31:0] read_lines;


reg perform_search;
reg set;
reg select_first;
reg [63:0] write_lines;

compare compare_module (CLK, comparand,mask,perform_search, mismatch_lines);
cells cells_module (match_lines, write_lines, read_lines, mismatch_lines, tag_wires, CLK);
tags tags_module(match_lines, set, select_first, tag_wires, CLK);




initial begin
  CLK=0;
     forever #5 CLK = ~CLK;  
end 

initial begin
  $monitor("\n clk = %ggit,\n comparand = %b, \n mask = %b, \n tags =  %b \n read = %b", $time, comparand, mask, tag_wires, read_lines);
end

initial begin 
    comparand = 5;
    mask = '1;
    set = 1;
    #10;
    set = 0;
    perform_search = 1;
end 
endmodule