`timescale 1ps/1ps
module tb_uart;
    reg clk, reset, rx_pin, uart_in_sel;
    reg [7:0] tx_data, tb_ctrl;
    reg [9:0] data_in;

    wire tx_pin;
    wire [7:0] rx_data, rx_data_reg_out, state, uart_ctrl;

    integer i;

    uart_tx tx (
        .clk(clk), .reset(reset), .pin(tx_pin), .data(tx_data),
        .ctrl(tb_ctrl), .state_tx_sending(state[1]), .state_tx_en(state[0]));
    uart_rx rx (
        .clk(clk), .reset(reset), .pin(rx_pin), .data(rx_data),
        .ctrl_rx_contains_data(tb_ctrl[2]), .state_rx_contains_data(state[2]));
    register #(8,0) uart_status_ctrl (
        .clk(clk), .reset(reset), 
        .d(state), .en(1'b1), .q(uart_ctrl));
    register #(8,0) rx_data_reg (
        .clk(clk), .reset(reset),
        .d(rx_data), .en(state[2]), .q(rx_data_reg_out));
    
    assign state[7:3] = 0;

    always @(negedge clk) 
        tb_ctrl = state;

    always #10 clk = ~clk;

    task RESET; 
        begin
            $display("\n-----System Reset-----\n");
            reset = 1; #20;
            reset = 0; #20;
        end
    endtask

    task CHECK_RX_TRANSMISSION;
        begin
            $display("\n-----Checking Rx Transmission-----");
            $display("rx_data: %b, data_in[8:1]: %b, state[2]; %b",
                        rx_data, data_in[8:1], state[2]);
            if (rx_data != data_in[8:1]) begin
                $display("[ERR] input and output value do not match\n");
                $stop;
            end
            else if (state[2] != 1) begin
                $display("[ERR] rx_contains flag not set for UART status register\n");
                $stop;
            end
            else begin
                $display("!!! Successful transmission !!!");
            end
        end
    endtask

    task CHECK_TX_TRANSMISSION;
        begin
            $display("\n-----Checking Tx Transmission-----");
            for(i = 0; i < 14; i = i+1) begin
                if(i == 0) begin
                    if(tx_pin != 0) begin
                        $display("[ERR] tx_pin did not output proper start bit\n");
                        $stop;
                    end
                end
                else if (i >= 9) begin
                    if(tx_pin != 1) begin
                        $display("[ERR] tx_pin did not output proper stop bit\n");
                        $stop;
                    end
                end
                else if(tx_pin != tx_data[i-1]) begin
                    $display("[ERR] tx_pin does not match indexed output value\n");
                    $stop;
                end
                #20;
            end
            $display("!!! Successful transmission !!!");
        end
    endtask

    initial begin
        $monitor(/*rx_pin: %b, rx_data: %b, */"tx_pin: %b, tx_data: %b, ctrl: %b, state: %b, time: %0d", 
                /*rx_pin, rx_data, */tx_pin, tx_data, tb_ctrl, state, $time);
        clk = 0;
        reset = 0;
        rx_pin = 1'b1;
        tx_data = 0;
        uart_in_sel = 0;
        tb_ctrl = 8'b0;
        i = 0;
        #5; // Don't want everything changing on edge of clk

        RESET;

        $display("\n-----Testing Rx Transmission----\n");

        data_in = 10'b1001101110;
        uart_in_sel = 1;
        #20;

        for(i = 0; i < 10; i = i+1) begin
          rx_pin = data_in[i]; #20;
        end

        #40;

        CHECK_RX_TRANSMISSION;

        RESET;

        data_in = 10'b1000001000;

        for(i = 0; i < 10; i = i+1) begin
          rx_pin = data_in[i]; #20;
        end

        CHECK_RX_TRANSMISSION;

        RESET;

        data_in = 10'b1111100110;

        for(i = 0; i < 10; i = i+1) begin
          rx_pin = data_in[i]; #20;
        end

        CHECK_RX_TRANSMISSION;

        RESET;

        $display("\n-----Testing Tx Transmission----\n");

        tx_data = 8'b10001111;
        uart_in_sel = 0;
        #20;
        tb_ctrl[0] = 1'b1;
        #20;

        CHECK_TX_TRANSMISSION;

        RESET;

        tx_data = 8'b00111001;
        uart_in_sel = 0;
        #20;
        tb_ctrl[0] = 1'b1;
        #20;

        CHECK_TX_TRANSMISSION;

        $finish(2);

    end


endmodule