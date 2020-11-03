# Content-Addressable-Memory
This is an implementation of a simple CAM as found in Caxton C Founder's Book 'Content Addressable Memory'.

You can find all the different modules that work with each other in their specific files.

- *cam.v* contains the main module. It uses all the modules below and is at top level. (for now)

- *compare.v* contains 3 inputs, wires from 2 registers, comparand and mask, and the wire that controls the search function. This module outputs 64 mismatch lines, 2 for each bit.

- *cells.v* contain the main memory cells, right now they are only hundred to reduce resource complexity for the TinyFPGA Bx, but can easily be increased. There are various lines that connect to each bit f each cell, These are write lines, read lines and the match lines. The cell outputs tags for each cell

- *tags.v* contain the circuity for all the tags. It has the select_first, set and mismatch lines as its input. It outputs the values of tags.

- *srff_behave.v* contains a helper module, for a simple flip flop that is used in tags.v and cells.v for writing values.

The control.v is currently under development. The goal is for it to use these individual models with multiple overlaying programs like search, write, read, find_biggest, add_one.

# Notes
- Use `apio build` to build the program. (Fixed now)
- Use `tinyprog --program hardware.bin` to upload it.
- This uses System Verilog for some tests, specifically so I can send N bit vectors instead of typing the whole vector out. Example, `'1` is the same as `32'b11111111...1`
  

# Hyper Dimensional Computing / CAM Ideas

- Graph coloring ([related paper for GPUs](https://people.eecs.berkeley.edu/~aydin/coloring.pdf)) 
  - Search is done in O(1) instead of O(n), but we would need to keep track of visited nodes. 
  - This can be done by writing 0 to the bit at their index of each cell. This is too an O(1) operation.

- Simple calculations like multiplication might match the time compexity of the same for GPUs, which would lead to faster matrix multiplication. 
   - We could start by finding powers of an adjacency matrix of an unweighted graph. [Which would help finding shortest paths faster ](https://people.cs.umass.edu/~barring/cs575f16/lecture/11.pdf) 
- Find the most similar/ closest vector(s) to find the closest one. Store neural network patterns in a CAM and fetch them with this algorithm. Can be done in O(n). Something similar is done [here](http://moimani.weebly.com/uploads/2/3/8/6/23860882/nvmw2017.pdf)