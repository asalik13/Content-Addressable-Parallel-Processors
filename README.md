![Content Addressable Parallel Processors](https://raw.githubusercontent.com/asalik13/Content-Addressable-Parallel-Processors/master/FPGA-CAPP%20research%20paper/images/CAPP.jpg)

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
- This uses System Verilog for some tests, specifically so I can send N bit vectors instead of typing the whole vector out. Example, `'1` is the same as `32'b11111111...1`
  

# Hyper Dimensional Computing / CAPP Ideas


- Graph coloring ([related paper for GPUs](https://people.eecs.berkeley.edu/~aydin/coloring.pdf)) 
  - Search is done in O(1) instead of O(n), but we would need to keep track of visited nodes. 
  - This can be done by writing 0 to the bit at their index of each cell. This is too an O(1) operation.

- Simple calculations like multiplication might match the time compexity of the same for GPUs, which would lead to faster matrix multiplication. 
   - We could start by finding powers of an adjacency matrix of an unweighted graph. [Which would help finding shortest paths faster ](https://people.cs.umass.edu/~barring/cs575f16/lecture/11.pdf) 
- Find the most similar/ closest vector(s) to find the closest one. Store neural network patterns in a CAPP and fetch them with this algorithm. Can be done in O(n). Something similar is done [here](http://moimani.weebly.com/uploads/2/3/8/6/23860882/nvmw2017.pdf)
- Graph search
  - There are at least two ways we can go about this
   1. The author's way of doing it is by dividing each cell into four sections: source, destination, counter and flag.
   2. Another possible way is limited to undirected, edge-dense simple graphs, where each cell represents a row of the graph's adjacency matrix. 
   
- We can also think of tweaking the architecture to allow for multiple layers of search lines, theoretically
  
  - This could this parallelize our graph search algorithms as well as make the '|' regex expression possible. This [patent](https://patents.google.com/patent/US7225188) uses multiple CAPPs for regex parsing.
  
  - This would be able to collect multiple searches with different tags registers for each layer. 
  
  - Then, we could pass read lines through each tag register of the layers, to accumulate them in the main tag register. 
  
  
 
