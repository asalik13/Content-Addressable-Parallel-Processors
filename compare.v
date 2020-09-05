// look in pins.pcf for all the pin names on the TinyFPGA BX board
module compare (
    input CLK,    // 16MHz clock
    output LED,   // User/boot LED next to power LED
    output USBPU  // USB pull-up resistor
);

  function generate_match_lines;
    input comparand_bit;
    input mask_bit;
    input perform_search;
    output [1:0] match_line;
    begin
    match_line[0] = perform_search && (comparand_bit && mask_bit);
    match_line[1] = perform_search && ((!comparand_bit) && mask_bit);
    end
  endfunction



  function compare_cell;
    input wire [63:0] match_lines;
    input reg [31:0] cell_values;
    output wire tag_bit;
    tag_bit = 0
    for(i=0;i<32;i=i+1)
      begin
      assign tag_bit = tag_bit || (match_lines[2*i] && cell_values[i]) || (match_lines[2*i+1] && (!cell_values[i]));
      end
  endfunction


  function compare;
    input wire perform_search;
    input reg [31:0] comparand;
    input reg [31:0] mask;
    input reg [4095:0] cells;
    output reg [4095:0] tag;

    wire [31:0] comparand_wire;
    wire [31:0] mask_wire;
    wire [63:0] match_lines;



    assign comparand_wire = comparand;
    assign mask_wire = mask;


    genvar i;
    generate

    for(i=0; i<32;i=i+1) begin
      assign match_lines[2*i:2*i+1] = generate_match_lines(comparand[i], mask[i], perform_search);
      end

    endgenerate

    for(i=0; i<4096; i=i+1) begin
       tag[i] = compare_cell(match_lines, cells[i]);
       end
  endfunction

endmodule
