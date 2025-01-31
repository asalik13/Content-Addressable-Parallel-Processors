// look in pins.pcf for all the pin names on the TinyFPGA BX board
module compare
#( parameter num_bits = 32, parameter num_cells = 100 )
(CLK, comparand, mask, perform_search, mismatch_lines);

input CLK;
input wire [num_bits - 1:0] comparand; //initial value to compare
input wire [num_bits - 1:0] mask; //initial mask
input wire perform_search;
output wire [2*num_bits - 1:0] mismatch_lines;



/* Generates match_lines for each bit of mask and comparand*/


genvar i;
for(i = 0;  i<num_bits; i = i+1)
  begin
    assign mismatch_lines[i + i] = perform_search && comparand[i] && mask[i];
    assign mismatch_lines[i + i + 1] = perform_search && (!comparand[i]) && mask[i];
  end

endmodule
