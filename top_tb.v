module tb(CLK); 
input CLK;
wire [31:0] comparand = 457;
wire [31:0] mask = 32'b111111;
wire [99:0] tag_wires;
wire [63:0] mismatch_lines;
wire [63:0] write_lines;
wire [99:0] match_lines;
wire [31:0] read_lines;
wire perform_search, set, select_first;
assign perform_search = 1'b1;


compare compare_module (CLK, comparand,mask,perform_search, mismatch_lines);
cells cells_module (match_lines, write_lines, read_lines, mismatch_lines);
//tags tags_module(match_lines, set, select_first, tag_wires, CLK);
initial
begin
#200000000000
$display("Comparand value: %b", comparand);
$display("Mask Value: %b", mask);
$display("Perform Search: %b", perform_search);
$display("Mismatch Lines: %b", mismatch_lines);
$display("Match Lines: %b", match_lines);




end
endmodule