// look in pins.pcf for all the pin names on the TinyFPGA BX board
module top (
    input CLK,    // 16MHz clock
    output LED,   // User/boot LED next to power LED
    output USBPU  // USB pull-up resistor
);


    // drive USB pull-up resistor to '0' to disable USB
    assign USBPU = 0;









endmodule
