/*
  USB Serial
*/

module usbserial_tbx (
        input  pin_clk,
      
        inout  pin_usb_p,
        inout  pin_usb_n,

        output pin_pu,
        output pin_led,
        output [3:0] debug
    );

    wire clk_48mhz;

    wire clk_locked;
    //misc
    integer i;

    // Use an icepll generated pll
    pll pll48( .clock_in(pin_clk), .clock_out(clk_48mhz), .locked( clk_locked ) );

    // Generate reset signal
    reg [5:0] reset_cnt = 0;
    wire reset = ~reset_cnt[5];
    always @(posedge clk_48mhz)
        if ( clk_locked )
            reset_cnt <= reset_cnt + reset;

    // uart pipeline in
    reg [7:0] uart_in_data;
    reg       uart_in_valid = 1'b1;
    wire       uart_in_ready;

    // uart pipeline out
    wire [7:0] uart_out_data;
    wire       uart_out_valid;
    reg       uart_out_ready;

    // Output string
    parameter OUTPUT_LEN=16;
    reg [8*OUTPUT_LEN - 1:0] output_text;
    reg [7:0] output_length;
    reg [7:0] output_char_count = 0;

    // Input string
    parameter INPUT_LEN = 16;
    reg [INPUT_LEN*8 - 1:0] input_text;
    reg [7:0] input_char_count = 0;


    // cam parameters (keep these as multiples of 8)
    localparam num_bits = 32;
    localparam num_cells = 16;

    // cam in
    reg [num_bits - 1:0] comparand;
    reg [num_bits - 1:0] mask;
    reg perform_search;
    reg set;
    reg select_first;
    reg [2*num_bits - 1:0] write_lines;

    // cam out
    wire [num_cells - 1:0] tag_wires;
    wire [num_bits - 1:0] read_lines;

    // cam control
    reg [31:0] cnt = 0;
    reg [31:0] delay = 0;

    // state control
    reg [4:0] curr_state = LISTEN;
    reg [4:0] next_state;

    // defining states
    parameter IDLE = 0;
    parameter SEND = 1;
    parameter RECIEVE = 2;
    parameter LISTEN = 3;
    parameter ERROR = 4;
    parameter CHOOSE_STATE = 5;
    parameter SET_COMPARAND_1 = 6;
    parameter SET_COMPARAND_2 = 7;
    parameter GET_COMPARAND = 8;    
    parameter SET_MASK_1 = 9;
    parameter SET_MASK_2 = 10;
    parameter GET_MASK = 11;
    parameter GET_TAGS = 12;
    parameter SELECT_FIRST_1 = 13;
    parameter SELECT_FIRST_2 = 14;
    parameter SET_HIGH = 15;
    parameter SET_LOW = 16;
    parameter SEARCH_1 = 17;
    parameter SEARCH_2 = 18;
    parameter WRITE_1 = 19;
    parameter READ = 20;
    // usb uart - this instanciates the entire USB device.
    usb_uart uart (
        .clk_48mhz  (clk_48mhz),
        .reset      (reset),

        // pins
        .pin_usb_p( pin_usb_p ),
        .pin_usb_n( pin_usb_n ),

        // uart pipeline in
        .uart_in_data( uart_in_data ),
        .uart_in_valid( uart_in_valid ),
        .uart_in_ready( uart_in_ready ),
        .uart_out_data( uart_out_data ),
        .uart_out_valid( uart_out_valid ),
        .uart_out_ready( uart_out_ready  )


        //.debug( debug )
    );

  // cam - instanciates a cam with given parameters
  cam #(
    .num_bits(num_bits),
    .num_cells(num_cells) 
  )

  CAM_EXAMPLE(
    .CLK(pin_clk),
    .comparand(comparand),
    .mask(mask),
    .perform_search(perform_search),
    .set(set),
    .select_first(select_first),
    .write_lines(write_lines),
    .tag_wires(tag_wires),
    .read_lines(read_lines)
  );
  always @(posedge clk_48mhz) begin
    case(curr_state)
      IDLE: begin
        cnt <= cnt + 1;
        if(cnt == delay) begin
          cnt <= 0;
          curr_state <= next_state;
        end
      end
      SEND: begin
         if (uart_in_ready || (~uart_in_valid && ~uart_in_ready))
          begin
              // send next character
              uart_in_data <= output_text[8*(output_length - output_char_count - 1)+: 8];
              // enable write
              uart_in_valid <= 1;
              // increment char count
              output_char_count <= output_char_count +1;
              // do this if message is sent
              if (output_char_count +1 == output_length)
              begin 
                  output_char_count <= 0;
                  curr_state <= next_state;
              end 
          end
      end
      RECIEVE: begin
        uart_out_ready <= 1;
        uart_in_valid <= 0;
        if (uart_out_valid) begin
            if(uart_out_data == "\r" || input_char_count == INPUT_LEN) begin
              curr_state <= next_state;
            end
            else begin
              input_text[8*(input_char_count)+: 7] <= uart_out_data;
              input_char_count <= input_char_count + 1;
            end
          end
      end
      CHOOSE_STATE: begin
        case(input_text)
          //set comparand
          "a": curr_state <= SET_COMPARAND_1;
          // get comparand
          "b": curr_state <= GET_COMPARAND;
          // set mask
          "c": curr_state <= SET_MASK_1;
          // get mask
          "d": curr_state <= GET_MASK;
          // select first
          "e": curr_state <= SELECT_FIRST_1;
          // get tags
          "f": curr_state <= GET_TAGS;
          // change the set-line to high
          "g": curr_state <= SET_HIGH;
          // change the set-line to low
          "h": curr_state <= SET_LOW;
          "i": curr_state <= WRITE;
          "j": curr_state <= READ;
          "k": curr_state <= SEARCH_1;
          // error 
          default: curr_state <= ERROR;
        endcase
        // Clear input
        input_char_count <= 0;
        input_text <= 0;
      end
      LISTEN: begin
        curr_state <= RECIEVE;
        next_state <= CHOOSE_STATE;
        // Clear input
        input_char_count <= 0;
        input_text <= 0;
      end
      ERROR: begin
        output_text <= {"ERROR", "\r\n"};
        output_length <= 7;
        curr_state <= SEND;
        next_state <= LISTEN;
      end
      SET_COMPARAND_1: begin
        // set next states
        curr_state <= RECIEVE;
        next_state <= SET_COMPARAND_2;
      end
      SET_COMPARAND_2: begin
        // set comparand
        comparand <= input_text;
        curr_state <= LISTEN;

      end
      GET_COMPARAND: begin
        output_text <= {comparand, "\r\n"};
        output_length <= 6;
        curr_state <= SEND;
        next_state <= LISTEN;
      end
      SET_MASK_1: begin
        // set next states
        curr_state <= RECIEVE;
        next_state <= SET_MASK_2;
      end
      SET_MASK_2: begin
        mask <= input_text;
        // Clear input
        input_char_count <= 0;
        input_text <= 0;
        curr_state <= LISTEN;
      end
      GET_MASK: begin
        output_text <= {mask, "\r\n"};
        output_length <= 6;
        curr_state <= SEND;
        next_state <= LISTEN;
      end
      GET_TAGS: begin
        output_text <= {tag_wires, "\r\n"};
        output_length <= 4;
        curr_state <= SEND;
        next_state <= LISTEN;
      end
      SELECT_FIRST_1: begin
        select_first <= 1;
        delay <= 5;
        curr_state <= IDLE;
        next_state <= SELECT_FIRST_2;
      end
      SELECT_FIRST_2: begin
        select_first <= 0;
        delay <= 5;
        curr_state <= IDLE;
        next_state <= LISTEN;
      end
      SET_HIGH:begin
        set <= 1;
        curr_state <= LISTEN;
      end
      SET_LOW: begin
        set <= 0;
        curr_state <= LISTEN;
      end
      SEARCH_1: begin
        perform_search <= 1;
        delay <= 1024;
        curr_state <= IDLE;
        next_state <= SEARCH_2;
      end
      SEARCH_2: begin
        perform_search <= 0;
        delay <= 1024;
        curr_state <= IDLE;
        next_state <= LISTEN;
      end
      READ: begin
        output_text <= {read_lines, "\r\n"};
        output_length <= 6;
        curr_state <= SEND;
        next_state <= LISTEN;
      end
      WRITE_1: begin
        for(i = 0;  i<num_bits; i = i+1)
        begin
            write_lines[2*i] <= comparand[i] && mask[i];
            write_lines[2*i + 1] <= (!comparand[i]) && mask[i];
        end
      end

    endcase
  end

  // USB Host Detect Pull Up
  assign pin_pu = 1'b1;

endmodule