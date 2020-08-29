// look in pins.pcf for all the pin names on the TinyFPGA BX board
module top (
    input CLK,    // 16MHz clock
    output LED,   // User/boot LED next to power LED
    output USBPU  // USB pull-up resistor
);
    // drive USB pull-up resistor to '0' to disable USB
    assign USBPU = 0;

    reg [31:0] comparand; // holds item

    wire[31:0] comparand_wire; //continuous value of comparand

    assign comparand_wire = comparand;

    reg [31:0] mask; //holds required bits of item

    wire[31:0] mask_wire; //continous value of mask

    assign mask_wire = mask;

    wire perform_search; //controls search

endmodule
