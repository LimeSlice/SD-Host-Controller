/**
  * Assuming external clock at 50MHz
  *
  * UART Specs:
  *     Baudrate:   9600 bps
  *     Data bits:  8 bits
  *     Start bit:  1 bit
  *     Stop bit:   1 bit
  */
module uart (ex_clk, reset, rx_pin, sd_tx_en, sd_tx_data, tx_pin, software_reset, uart_cmd_en, uart_cmd);
    input ex_clk, reset, rx_pin, sd_tx_en;
    input [7:0] sd_tx_data;
    output tx_pin, software_reset, uart_cmd_en;
    output [5:0] uart_cmd;

    wire state_tx_sending, state_rx_contains_data;
    wire ctrl_tx_en,  ctrl_tx_sending,  ctrl_rx_contains_data;
    
    wire bp_clk, tx_reset, rx_reset, rx_reg_en, tx_reg_en, ctrl_reg_en;
    wire [7:0] uart_ctrl_in, uart_ctrl_out, rx_data_in, rx_data_out, tx_data_in, tx_data_out;


    assign uart_ctrl_in   = {5'b0, state_rx_contains_data, state_tx_sending, uart_tx_en};
    assign uart_ctrl_out  = {5'b0, ctrl_rx_contains_data, ctrl_tx_sending, ctrl_tx_en};

    // registers
    register #(8,0) rx_reg   (ex_clk, rx_reset, rx_data_in,   rx_reg_en,   rx_data_out);
    register #(8,0) tx_reg   (ex_clk, tx_reset, tx_data_in,   tx_reg_en,   tx_data_out);
    register #(8,0) ctrl_reg (ex_clk, reset | software_reset,    uart_ctrl_in, ctrl_reg_en, uart_ctrl_out);

    // clock divider to sample at BAUDRATE
    // 50MHz / 5208 = 9600.6144Hz (0.0064% timing error)
    counter clk_div (ex_clk, reset, 16'd5208, bp_clk);
    
    // transmitter
    uart_tx tx (
        bp_clk, tx_reset, ctrl_tx_en, ctrl_tx_sending, tx_data_out, // inputs
        tx_pin, state_tx_sending);                                  // outputs

    // receiver
    uart_rx rx (
        bp_clk, rx_reset, rx_pin, ctrl_rx_contains_data, // inputs
        rx_data_in, state_rx_contains_data);             // outputs

    // fsm
    uart_fsm fsm (
        ex_clk, reset, sd_tx_en,                 // inputs
        sd_tx_data, rx_data_out, uart_ctrl_out,
        rx_reg_en, tx_reg_en, ctrl_reg_en,       // outputs
        rx_reset, tx_reset, software_reset, uart_tx_en, uart_cmd_en,
        uart_cmd, tx_data_in
    );

endmodule