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
endmodule