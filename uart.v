/**
  * Assuming external clock at 6MHz
  *
  * UART Specs:
  *     Baudrate:   9600 bps
  *     Data bits:  8 bits
  *     Start bit:  1 bit
  *     Stop bit:   1 bit
  */
module uart (ex_clk, resetn, tx_pin, rx_pin, tx_data, rx_data, ctrl, uart_state);
    input ex_clk, resetn, rx_pin;
    input [7:0] tx_data, ctrl;
    output tx_pin;
    output [7:0] rx_data;
    output [7:0] uart_state;

    wire bp_clk;

    // clock divider to sample at BAUDRATE
    counter #(10, 625) clk_div (ex_clk, resetn, bp_clk);
    
    // transmitter
    uart_tx tx (bp_clk, resetn, tx_pin, tx_data, ctrl, uart_state);

    // receiver
    uart_rx rx (bp_clk, resetn, rx_pin, rx_data, ctrl, uart_state);

endmodule