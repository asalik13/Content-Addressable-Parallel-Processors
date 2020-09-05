// look in pins.pcf for all the pin names on the TinyFPGA BX board
module read (
    input CLK,    // 16MHz clock
    output LED,   // User/boot LED next to power LED
    output USBPU  // USB pull-up resistor
);
  integer i;

  function [31:0] read_cell;
    input reg [31:0] cell_values;
    input reg tag_bit;
    begin
    for(i = 0; i<32; i=i+1) begin
      read_cell[i] = tag_bit && cell_values[i];
    end
    end
  endfunction


  function [31:0] read;
    input [4095:0] cells;
    input [4095:0] tags;
    begin
    for(i = 0; i<4096; i=i+1) begin
       read = read | read_cell(cells[i], tags[i]);
    end
    end
  endfunction
endmodule
