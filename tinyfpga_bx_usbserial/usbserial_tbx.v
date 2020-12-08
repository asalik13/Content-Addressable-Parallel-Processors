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


parameter STATE_WAIT = 1'b0;
parameter STATE_TX = 1'b1;

reg state = STATE_WAIT;

// Create the output string
parameter OUTPUT_LEN=64;
reg [8*OUTPUT_LEN - 1:0] output_text;
reg [7:0] output_length;
reg [7:0] output_char_count = 0;
// Create the input string
parameter INPUT_LEN = 64;
reg [INPUT_LEN*8 - 1:0] input_text;
reg [7:0] input_char_count = 0;

task sendMessage;
  input [8*OUTPUT_LEN - 1:0] string;
  input [7:0] size;
  begin
    output_text <= string;
    output_length <= size;
    state <= STATE_TX;
    input_char_count = 0;
  end
endtask

// This recieves the reverse of a string (Endian Swap)
task getMessage;
  begin
    uart_in_valid <= 0;
    if (uart_out_valid) begin
        if(uart_out_data == "\r" || input_char_count == INPUT_LEN) begin
            doStuff();
        end
        else begin
          input_text[8*(input_char_count + 1)- 1: 8*(input_char_count)] <= uart_out_data;
          input_char_count <= input_char_count + 1;
        end
      end
    end
endtask

// central control
task doStuff;
  begin
    case(input_text)
          "trats": sendMessage("Starting the CAPP...\r\n", 22);
          "etirw": sendMessage("Enter data now..\r\n", 18);
          default: sendMessage({input_text, "\r\n"}, input_char_count + 2);
    endcase
  end
endtask

always @(posedge clk_48mhz)
  begin
      uart_out_ready <= 1;
      case(state)
      STATE_WAIT:
        begin
            getMessage();
        end
      STATE_TX:
        begin

          if (uart_in_ready || (~uart_in_valid && ~uart_in_ready))
          begin
              // send next character
              uart_in_data <= output_text[8*(output_length - output_char_count)- 1: 8*(output_length - output_char_count - 1)];
              // enable write
              uart_in_valid <= 1;
              // increment char count
              output_char_count <= output_char_count +1;
              // do this if message is sent
              if (output_char_count +1 == output_length)
              begin 
                  output_char_count <= 0;
                  input_text <= 0;
                  state <= STATE_WAIT;
              end 
          end
        end
      endcase
  end
 

  // USB Host Detect Pull Up
  assign pin_pu = 1'b1;

endmodule