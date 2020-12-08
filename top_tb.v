`timescale 1ns/1ps

module tb; 

reg  pin_clk;
localparam num_bits = 16;
localparam num_cells = 5;

reg [num_bits - 1:0] comparand;
reg [num_bits - 1:0] mask;
reg perform_search;
reg set;
reg select_first;
reg [2*num_bits - 1:0] write_lines;
reg [2:0] state;
reg [9:0] cnt = 0;
wire [num_cells - 1:0] tag_wires;
wire [num_bits - 1:0] read_lines;
wire clk_48mhz;
wire clk_locked;

// Use an icepll generated pll
//pll pll48( .clock_in(pin_clk), .clock_out(clk_48mhz), .locked( clk_locked ) );


cam #(
  .num_bits(num_bits),
  .num_cells(num_cells) 
)

CAM_EXAMPLE(
  .CLK(pin_clk),
  .comparand(comparand),
  .mask(mask),
  .perform_search(perform_search),
  .set(set),
  .select_first(select_first),
  .write_lines(write_lines),
  .tag_wires(tag_wires),
  .read_lines(read_lines)
  );

  always @(posedge pin_clk) begin
    set <= state[0];
    perform_search <= state[1];
    select_first <= state[2];
  end

  initial begin
    #100000;
    $finish;
  end


  always @(posedge pin_clk) begin
    if(cnt<30 == 0) state <= 3'b001;
    else state <= 3'b100;
    cnt <= cnt + 1;
    if(cnt == 60) cnt <= 0;
  end




initial begin
  $printtimescale(tb);
  pin_clk=0;
  forever #21 pin_clk = ~pin_clk;  
end 
/*
initial begin
  state = 3'b001;
  #100;
  state = 3'b100;
  #100;
  $finish;
end

*/
/*
task search;
input [num_bits - 1:0] comparand_value;
input [num_bits - 1:0] mask_value;
begin
  $display("searching...");
  comparand <= comparand_value;
  mask <= mask_value;
  set <= 1;
  #100;
  set <= 0;
  #100;
  perform_search <= 1;
  #100;
  perform_search <= 0;
  #100;
end
endtask

task selectFirst;
begin
  $display("selecting first...");
  select_first <= 1;
  #20;
  select_first <= 0;
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
write_lines <= 0;
for(i = 0;  i<num_bits; i = i+1)
  begin
    write_lines[2*i] <= value[i] && mask[i];
    write_lines[2*i + 1] <= (!value[i]) && mask[i];
  end
#100;
write_lines <= '0;
#1000;
end
endtask

*/
initial begin
  $dumpfile("top_tb.vcd");
  $dumpvars(0,tb);
  $monitor("tags: %b\n", tag_wires);

end

/*
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
*/
endmodule