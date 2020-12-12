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
    parameter OUTPUT_LEN=32;
    reg [8*OUTPUT_LEN - 1:0] output_text;
    reg [7:0] output_length;
    reg [7:0] output_char_count = 0;

    // Input string
    parameter INPUT_LEN = 32;
    reg [INPUT_LEN*8 - 1:0] input_text;
    reg [7:0] input_char_count = 0;


    // cam parameters
    localparam num_bits = 32;
    localparam num_cells = 100;

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

    /*
    reg RECIEVE = 1;
    reg SEND = 0;
    reg IDLE = 0;
    reg DO = 0;
    */
    // state control
    reg [9:0] curr_state = LISTEN;
    reg [9:0] next_state;

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
          "dnarapmoc-tes": curr_state <= SET_COMPARAND_1;
          "dnarapmoc-teg": curr_state <= GET_COMPARAND;
          "ksam-tes": curr_state <= SET_MASK_1;
          "ksam-teg": curr_state <= GET_MASK;
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

    endcase
  end

  // USB Host Detect Pull Up
  assign pin_pu = 1'b1;

endmodule