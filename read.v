// look in pins.pcf for all the pin names on the TinyFPGA BX board
module read (
    input CLK,    // 16MHz clock
    output LED,   // User/boot LED next to power LED
    output USBPU  // USB pull-up resistor
);

  function read_cell;
    input reg [31:0] cell_values;
    input reg tag_bit
    output wire [31:0] read_lines

    for(i = 0; i<32; i=i+1) begin
      assign read_lines[i] = tag_bit && cell_values[i];
    end
  endfunction


  function read;
    input reg [4095:0] cells;
    input reg [4095:0] tags;
    output wire [31:0] read_lines;
    for(i = 0; i<4096; i=i+1) begin
      assign read_lines = read_lines | read_cell(cells[i], tags[i])
    end
  endfunction
endmodule
