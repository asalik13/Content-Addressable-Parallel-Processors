![Content Addressable Parallel Processors](https://raw.githubusercontent.com/asalik13/Content-Addressable-Parallel-Processors/master/FPGA-CAPP%20research%20paper/images/CAPP_cover.jpg)

# Content-Addressable-Parallel-Processors
This is an implementation of a simple CAPP as found in Caxton C Founder's Book 'Content Addressable Memory'.

You can find all the different modules that work with each other in their specific files.

- *CAPP.v* contains the main module. It uses all the modules below and is at the top level. It manages the high-level protocol for communication with the host computer over USB-UART.

- *compare.v* contains 3 inputs, wires from 2 registers, comparand and mask, and the wire that controls the search function. This module outputs 64 mismatch lines, 2 for each bit.

- *cells.v* contain the main memory cells, right now they are only hundred to reduce resource complexity for the TinyFPGA Bx, but can easily be increased. There are various lines that connect to each bit f each cell, These are write lines, read lines and the match lines. The cell outputs tags for each cell

- *tags.v* contain the circuity for all the tags. It has the select_first, set and mismatch lines as its input. It outputs the values of tags.

- *srff_behave.v* contains a helper module, for a simple flip flop that is used in tags.v and cells.v for writing values.


# Notes
- Use `make` to build this program (requires [nextpnr](https://github.com/YosysHQ/nextpnr))
- Use `tinyprog -p CAPP.bin` to upload i (which you can get [here](https://github.com/tinyfpga/TinyFPGA-Bootloader/tree/master/programmer))
