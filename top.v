module top; 
localparam num_bits = 32;
localparam num_cells = 100;

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
//101
//write(56, 1111111111);
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
endmodule