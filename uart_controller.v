module uart_controller(
    input sd_tx_en,
    input [7:0] sd_tx_data, rx_data, uart_ctrl_in, uart_ctrl_out,
    output reg rx_reg_en, tx_reg_en, ctrl_reg_en, uart_tx_en,
    output reg [7:0] tx_data
);

// uart_ctrl register bit names
parameter [4:1] RX_CONTAINS_DATA = 2'd2, TX_SENDING = 2'd1, TX_EN = 2'd0; 


always @(sd_tx_en, sd_tx_data, rx_data, uart_ctrl_in, uart_ctrl_out) begin
    {rx_reg_en, tx_reg_en, ctrl_reg_en, uart_tx_en, tx_data} = 0;

    if (sd_tx_en && !uart_ctrl_out[TX_EN] && !uart_ctrl_out[TX_SENDING]) begin
        uart_tx_en = 1'b1;      // uart_ctrl_in[0]
        tx_data = sd_tx_data;   // store new tx_data from sd card
        tx_reg_en = 1'b1;       // enable tx_reg to store new tx_data
        ctrl_reg_en = 1'b1;     //enable ctrl_reg to store en
    end
    else if (uart_ctrl_in[TX_SENDING]) begin
        ctrl_reg_en = 1'b1;
    end
    else if (!uart_ctrl_in[TX_SENDING] && uart_ctrl_out[TX_SENDING]) begin
        ctrl_reg_en = 1'b1;
    end
    else if (uart_ctrl_in[RX_CONTAINS_DATA]) begin
        ctrl_reg_en = 1'b1;     //enable ctrl_reg to store rx_contains_data
    end 
end

endmodule
