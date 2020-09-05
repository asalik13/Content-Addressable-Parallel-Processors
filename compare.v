// look in pins.pcf for all the pin names on the TinyFPGA BX board
module compare (
    input CLK,    // 16MHz clock
    output LED,   // User/boot LED next to power LED
    output USBPU  // USB pull-up resistor
);
integer i;
integer first;
integer second;

  function [63:0] match_lines;
    input [31:0] comparand;
    input [31:0] mask;
    input perform_search;
    begin: match_lines
    for(i=0; i<32;i=i+1)
      begin
      first = i+i;
      second = first+1;
        match_lines[first] = perform_search && (comparand[i] && mask[i]);
        match_lines[second] = perform_search && ((!comparand[i]) && mask[i]);
      end
    end
  endfunction




  function tag_bit;
    input [63:0] match_lines;
    input [31:0] cell_values;
    begin
    for (i=0; i<32; i=i+1) begin
       tag_bit = (tag_bit || (match_lines[2*i] && cell_values[i]) || (match_lines[2*i+1] && (!cell_values[i])));
      end
    end
  endfunction


  function [4095:0] tag;
    input [4095:0] cells;
    input [63:0] match_lines;
    begin
    for(i=0; i<4096; i=i+1) begin
       tag[i] = tag_bit(match_lines, cells[i]);
       end
    end
  endfunction

endmodule
