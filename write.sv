module write_task();
task write;
    input [31:0] value;
    input [31:0] cell;
        begin
            write_lines = value;
            write_cell[cell] = 1;
            #100;
            write_cell[cell] = 0;
            write_lines = 0;
            #100;
        end
endtask
endmodule