module tb; 
localparam num_bits = 2;
localparam num_cells = 10;

reg CLK = 1'b1;
reg [num_bits - 1:0] comparand;
reg [num_bits - 1:0] mask;
reg perform_search;
reg set;
reg select_first;
reg [2*num_bits - 1:0] write_lines;

wire [num_cells - 1:0] tag_wires;
wire [num_bits - 1:0] read_lines;

cam #(
  .num_bits(num_bits),
  .num_cells(num_cells) 
)

CAM_EXAMPLE(
  .CLK(CLK),
  .comparand(comparand),
  .mask(mask),
  .perform_search(perform_search),
  .set(set),
  .select_first(select_first),
  .write_lines(write_lines),
  .tag_wires(tag_wires),
  .read_lines(read_lines)
  );


task search;
input [num_bits - 1:0] comparand_value;
input [num_bits - 1:0] mask_value;
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
//101
//write(56, 1111111111);
task write;
input [31:0] value;
input [31:0] mask;
integer i;
begin
$display("writing...");
write_lines = 0;
for(i = 0;  i<num_bits; i = i+1)
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
  for(i = 1; i <= num_cells; i = i + 1) begin: loop
    search(0, '1);
    selectFirst();
    write(i, '1);
  end
  search(35, '1);
  $finish;
end 
endmodule