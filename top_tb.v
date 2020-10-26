module tb; 
reg CLK = 1'b1;
reg [31:0] comparand;
reg [31:0] mask;
wire [99:0] tag_wires;
wire [63:0] mismatch_lines;
wire [99:0] match_lines;
wire [31:0] read_lines;
wire [99:0] some_none;
 
reg perform_search;
reg set;
reg select_first;
reg [63:0] write_lines;


reg [99:0] write_cell;
reg [99:0] reset_cell;

compare compare_module (CLK, comparand,mask,perform_search, mismatch_lines);
cells cells_module (match_lines, write_lines, read_lines, mismatch_lines, tag_wires, CLK);
tags tags_module(match_lines, set, select_first, tag_wires, some_none, CLK);

task search;
input [31:0] comparand_value;
input [31:0] mask_value;
begin
  comparand = comparand_value;
  mask = mask_value;
  set = 1;
  #5;
  set = 0;
  perform_search = 1;

end
endtask

task selectFirst;
input [31:0] comparand_value;
input [31:0] mask_value;
begin
  comparand = comparand_value;
  mask = mask_value;
  set = 1;
  #5;
  set = 0;
  perform_search = 1;
  #20;
  perform_search = 0;
  select_first = 1;

end
endtask

initial begin
  CLK=0;
  forever #5 CLK = ~CLK;  
end 

initial begin
  $dumpfile("top_tb.vcd");
  $dumpvars(0,tb);
  $monitor("%b\n", tag_wires);

end

initial begin 
  selectFirst(5,5);
  #100;
  $finish;
end 
endmodule