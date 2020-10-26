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
  $display("searching...");
  comparand = comparand_value;
  mask = mask_value;
  set = 1;
  #100;
  set = 0;
  #100;
  perform_search = 1;
  #100;
  perform_search = 0;
  #100;
end
endtask

task selectFirst;
begin
  $display("selecting first...");
  select_first = 1;
  #20;
  select_first = 0;
  #20;
end
endtask

task write;
input [31:0] value;
input [31:0] mask;
integer i;
begin
$display("writing...");
write_lines = 0;
for(i = 0;  i<32; i = i+1)
  begin
    write_lines[2*i] = value[i] && mask[i];
    write_lines[2*i + 1] = (!value[i]) && mask[i];
  end
#100;
write_lines = '0;
#1000;
end
endtask


initial begin
  CLK=0;
  forever #5 CLK = ~CLK;  
end 

initial begin
  $dumpfile("top_tb.vcd");
  $dumpvars(0,tb);
  $monitor("tags: %b\n", tag_wires);

end

integer i;
initial begin: main
  set = 1;
  write(0, '1);
  set = 0;
  for(i = 1; i <= 100; i = i + 1) begin: loop
    search(0, '1);
    selectFirst();
    write(i, '1);
  end
  search(35, '1);
  $finish;
end 
endmodule