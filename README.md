# Content-Addressable-Parallel-Processors
This is an implementation of a simple CAPP as found in Caxton C Founder's Book 'Content Addressable Memory'.

You can find all the different modules that work with each other in their specific files.

- *CAPP.v* contains the main module. It uses all the modules below and is at top level.

- *compare.v* contains 3 inputs, wires from 2 registers, comparand and mask, and the wire that controls the search function. This module outputs 64 mismatch lines, 2 for each bit.

- *cells.v* contain the main memory cells, right now they are only hundred to reduce resource complexity for the TinyFPGA Bx, but can easily be increased. There are various lines that connect to each bit f each cell, These are write lines, read lines and the match lines. The cell outputs tags for each cell

- *tags.v* contain the circuity for all the tags. It has the select_first, set and mismatch lines as its input. It outputs the values of tags.

- *srff_behave.v* contains a helper module, for a simple flip flop that is used in tags.v and cells.v for writing values.

The control.v is currently under development. The goal is for it to use these individual models with multiple overlaying programs like search, write, read, find_biggest, add_one.

# Notes
- Use `make` to build this program (requires )
- Use `tinyprog -p CAPP.bin` to upload it.
- This uses System Verilog for some tests, specifically so we can send N bit vectors instead of typing the whole vector out. Example, `'1` is the same as `32'b11111111...1`
