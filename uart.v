/**
  * Assuming external clock at 50MHz -- change BAUDRATE!!!!
  *
  * UART Specs:
  *     Baudrate:   9600 bps
  *     Data bits:  8 bits
  *     Start bit:  1 bit
  *     Stop bit:   1 bit
  */
module uart (ex_clk, reset, tx_pin, rx_pin, tx_data, rx_data, ctrl, uart_state);
    input ex_clk, reset, rx_pin;
    input [7:0] tx_data, ctrl;
    output tx_pin;
    output [7:0] rx_data;
    output [7:0] uart_state;

    wire bp_clk, uart_tx_en, uart_tx_sending, uart_rx_contains;

    assign uart_state = {ctrl[7:3], uart_rx_contains, uart_tx_sending, uart_tx_en};

    // clock divider to sample at BAUDRATE
    counter #(10, 625) clk_div (ex_clk, reset, bp_clk);
    
    // transmitter
    uart_tx tx (bp_clk, reset, tx_pin, tx_data, ctrl, uart_tx_sending, uart_tx_en);

    // receiver
    uart_rx rx (bp_clk, reset, rx_pin, rx_data, ctrl[2], uart_rx_contains);

endmodule