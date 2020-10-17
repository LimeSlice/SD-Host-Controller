module tb_uart;
    reg clk, reset, tx_pin;
    reg [7:0] rx_data;
    reg [9:0] data_in;

    wire rx_pin;
    wire [7:0] tx_data, state, ctrl;

    integer i;

    uart utop(.ex_clk(clk), .resetn(reset), .tx_pin(tx_pin), .rx_pin(rx_pin),
            .tx_data(tx_data), rx_data(rx_data), .ctrl(ctrl), .uart_state(state));
    register usc (.clk(clk), .resetn(reset), .d(state), .en(1), .q(ctrl));


    initial begin
        $monitor("%b %b %0d", rx_data, state, $time);
        $monitor("%b %b %0d", tx_pin, state, $time);
        clk = 0;
        reset = 0;
        ctrl = 8'b0;
    end

    initial begin
        #5; // Don't want everything changing on edge of clk

        // Reset
        reset = 1; #20;
        reset = 0; #20;

        // Test RX
        data_in = 10'b1001101110;

        for(i = 0; i < 10; i = i+1) begin
          rx_data = data_in[i]; #20;
        end

        if(rx_data != data_in[8:1] || state[2] != 1) begin
            $stop;
        end

        reset = 1; #20;
        reset = 0; #20;

        data_in = 10'b1000001000;

        for(i = 0; i < 10; i = i+1) begin
          rx_data = data_in[i]; #20;
        end

        if(rx_data != data_in[8:1] || state[2] != 1) begin
            $stop;
        end

        reset = 1; #20;
        reset = 0; #20;

        data_in = 10'b1111100110;

        for(i = 0; i < 10; i = i+1) begin
          rx_data = data_in[i]; #20;
        end

        if(rx_data != data_in[8:1] || state[2] != 1) begin
            $stop;
        end

        reset = 1; #20;
        reset = 0; #20;

        // Text TX
        tx_data = 8'b10001111;
        #20;
        ctrl[1] = 1'b1;
        #20;

        for(i = 0; i < 10; i = i+1) begin
          if(i == 0) begin
            if(tx_pin != 0) begin
              $stop;
            end
          end
          else if (i == 9) begin
            if(tx_pin != 1) begin
              $stop;
            end
          end
          else if(tx_pin != tx_data[i-1]) begin
            $stop
          end
          #20;
        end

        reset = 1; #20;
        reset = 0; #20;

        // Text TX
        tx_data = 8'b00111001;
        #20;
        ctrl[1] = 1'b1;
        #20;

        for(i = 0; i < 10; i = i+1) begin
          if(i == 0) begin
            if(tx_pin != 0) begin
              $stop;
            end
          end
          else if (i == 9) begin
            if(tx_pin != 1) begin
              $stop;
            end
          end
          else if(tx_pin != tx_data[i-1]) begin
            $stop
          end
          #20;
        end

        reset = 1; #20;
        reset = 0; #20;

    end


endmodule