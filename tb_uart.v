`timescale 1ps/1ps
module tb_uart;
    
reg clk, reset, rx_pin, tx_en;
reg [7:0] tx_data;
wire tx_pin;
wire [7:0] rx_data_out, uart_ctrl_out;

reg [9:0] data_in;
integer i, multirun;

initial multirun = 0;

// uart_ctrl register bit names
parameter [4:1] RX_CONTAINS_DATA = 2'd2, TX_SENDING = 2'd1, TX_EN = 2'd0; 

// uart_small_clk_divider uut (
//     clk, reset, rx_pin, tx_en,
//     tx_data,
//     tx_pin,
//     rx_data_out, uart_ctrl_out
// );

uart uut (
    clk, reset, rx_pin, tx_en,
    tx_data,
    tx_pin,
    rx_data_out, uart_ctrl_out
);

always #10 clk = ~clk;

always @(posedge uut.bp_clk) begin
    // $display("rx_pin: %b, rx_data_in: %b, rx_data_out: %b, rx_index: %0d, time: %0d", 
    //             rx_pin, uut.rx_data_in, rx_data_out, uut.rx.index, $time);
    // $display("tx_pin: %b, tx_data: %b", 
    //             tx_pin, tx_data);
    // $display("ctrl: %b, i: %0d\n", uut.uart_ctrl_out, i);
    if ($time > (10416000 * (multirun + 1))) begin  // assuming max time takes 20*5208*(100 cycles) for each run
        $stop; 
    end
end

task RESET; 
    begin
        $display("-----System Reset-----\n");
        reset = 1; #20;
        reset = 0; #20;
    end
endtask

task UART_WAIT;
    begin
        #104160;    // 20 * 5208 
    end
endtask

task CHECK_RX_TRANSMISSION;
    begin
        // $display("-----Checking Rx Transmission-----\n");
        
        if (uut.state_rx_contains_data != 1'b1) begin
            $display("[ERR@%0d] rx_contains_data bit for ctrl reg not raised\n", $time);
            // $stop;
        end
        else if (uut.rx_data_in != data_in[8:1]) begin
            $display("[ERR@%0d] incorrect data received\n", $time);
            // $stop;
        end
        else begin
            // $display("!!! Successful transmission !!!\n");
        end
    end
endtask

task CHECK_FSM_SORTING;
    begin
        // $display("-----Checking FSM Sorting-----\n");

        if (uut.ctrl_rx_contains_data != 1'b1) begin
            $display("[ERR@%0d] rx_contains_data bit in ctrl reg not raised\n", $time);
            // $stop;
        end
        else if (rx_data_out != data_in[8:1]) begin
            $display("[ERR@%0d] incorrect data set\n", $time);
            // $stop;
        end
        else begin
            // $display("!!! Successful FSM Sorting !!!\n");
        end 
    end
endtask

task CHECK_TX_TRANSMISSION;
    begin
        i = 0;
        while (!uart_ctrl_out[TX_SENDING]) begin 
            UART_WAIT;
        end
        // $display("-----Checking Tx Transmission-----\n");
        while (uart_ctrl_out[TX_SENDING]) begin
            if (i == 0) begin
                if (tx_pin != 1'b0) begin 
                    $display("[ERR@%0d] tx_pin did not output proper start bit\n", $time);
                    // $stop;
                end
            end
            else begin
                if (tx_pin != tx_data[i-1]) begin
                    $display("[ERR@%0d] tx_pin does not match indexed output value\n", $time);
                end
            end
             UART_WAIT;
            i = i + 1;
        end
        if (tx_pin != 1'b1) begin
            $display("[ERR@%0d] tx_pin did not output proper stop bit\n", $time);
            // $stop;
        end
        // $display("!!! Successful Transmission !!!\n");
    end
endtask

initial begin
    clk = 0;
    reset = 0;
    rx_pin = 1; 
    tx_en = 0;
    tx_data = 8'd0;
    i = 0;
    #5; // Don't want everything changing on edge of clk

    RESET;

    for (multirun = 0; multirun < 500; multirun = multirun + 1) begin
        
        $display("Testing run %0d", multirun + 1);

        // $display("-----Testing Rx Transmission----\n");

        data_in = $random;
        data_in = {1'b1, data_in[8:1], 1'b0};
        for(i = 0; i < 10; i = i+1) begin
            rx_pin = data_in[i]; 
            UART_WAIT;
        end
        CHECK_RX_TRANSMISSION;
        CHECK_FSM_SORTING;

        data_in = $random;
        data_in = {1'b1, data_in[8:1], 1'b0};
        for (i = 0; i < 10; i = i+1) begin
            rx_pin = data_in[i]; 
            UART_WAIT;
        end
        CHECK_RX_TRANSMISSION;
        CHECK_FSM_SORTING;

        data_in = $random;
        data_in = {1'b1, data_in[8:1], 1'b0};
        for (i = 0; i < 10; i = i+1) begin
            rx_pin = data_in[i]; 
            UART_WAIT;
        end
        CHECK_RX_TRANSMISSION;
        CHECK_FSM_SORTING;

        // $display("-----Testing Tx Transmission----\n");

        tx_data = $random; 
        tx_en = 1'b1; UART_WAIT;
        tx_en = 1'b0;
        CHECK_TX_TRANSMISSION;

        tx_data = $random; 
        tx_en = 1'b1; UART_WAIT;
        tx_en = 1'b0;
        CHECK_TX_TRANSMISSION;
    end

    $finish(2);

end

endmodule