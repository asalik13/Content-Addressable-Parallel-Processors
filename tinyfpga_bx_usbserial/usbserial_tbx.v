/*
  USB Serial
*/

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

    // LED
    reg [24:0] ledCounter;
    always @(posedge clk_48mhz) begin
        ledCounter <= ledCounter + 1;
    end
    assign pin_led = ledCounter[ 24 ];

    // Generate reset signal
    reg [5:0] reset_cnt = 0;
    wire reset = ~reset_cnt[5];
    always @(posedge clk_48mhz)
        if ( clk_locked )
            reset_cnt <= reset_cnt + reset;

  parameter TEXT_LEN=32;
  
  // Create the text string
  reg [8*TEXT_LEN - 1:0] text;
  reg [4:0] length;
  reg [3:0] char_count =4'b0;

    // uart pipeline in
    reg [7:0] uart_in_data;
    reg       uart_in_valid = 1'b1;
    wire       uart_in_ready;

    wire [7:0] uart_out_data;
    wire       uart_out_valid;
    reg       uart_out_ready;
    // assign debug = { uart_in_valid, uart_in_ready, reset, clk_48mhz };



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
  reg [23:0] cnt = 24'b0;

task sendMessage;
  input [8*TEXT_LEN - 1:0] string;
  input [4:0] size;
  begin
    text <= string;
    length <= size;
    state <= STATE_TX;
  end
endtask

always @(posedge clk_48mhz)
  begin
      uart_out_ready <= 1;
      case(state)
      STATE_WAIT:
        begin
            uart_in_valid <= 0;
            case(uart_out_data)
            "a":
                sendMessage("Ayush\r\n", 7);
            "b":
                sendMessage("Salik\r\n", 7);
            endcase
        end
      STATE_TX:
        begin

          if (uart_in_ready || (~uart_in_valid && ~uart_in_ready))
          begin
              uart_in_data <= text[8*(length - char_count)- 1: 8*(length - char_count - 1)];
              uart_in_valid <= 1;
              char_count <= char_count +1;
              if (char_count +1 == length)
              begin 
                  char_count <= 0;
                  state <= STATE_WAIT;
              end 
          end
        end
      endcase
  end
 

  // USB Host Detect Pull Up
  assign pin_pu = 1'b1;

endmodule