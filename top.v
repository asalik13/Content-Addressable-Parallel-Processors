// look in pins.pcf for all the pin names on the TinyFPGA BX board
module top (
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


    // drive USB pull-up resistor to '0' to disable USB
    assign USBPU = 0;

    reg [31:0] comparand; // holds item

    wire[31:0] comparand_wire; //continuous value of comparand

    assign comparand_wire = comparand;

    reg [31:0] mask; //holds required bits of item

    wire[31:0] mask_wire; //continous value of mask

    assign mask_wire = mask;

    wire perform_search; //controls search

    wire [63:0] match_lines;
    genvar i;
    generate
    for(i=0; i<32;i=i+1) begin
      assign match_lines[2*i:2*i+2] = generate_match_lines(comparand[i], mask[i], perform_search);
      end
    endgenerate






endmodule
