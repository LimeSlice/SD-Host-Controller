module uart_rx(clk, reset, pin, data, ctrl_rx_contains_data, state_rx_contains_data);
    input clk, reset, pin, ctrl_rx_contains_data;
    output reg [7:0] data;
    output reg state_rx_contains_data;

    reg [3:0] index;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state_rx_contains_data <= 1'b0;
            index <= 4'b1111;
            data <= 8'b0;
        end
        else begin
            // Fill data register until all data is filled
            if (index < 4'b1000) begin
                state_rx_contains_data <= 1'b0;
                index <= index + 1'b1;
                data[index] <= pin;
            end
            // Process start bit
            else if (index == 4'b1111 && pin == 1'b0) begin
                state_rx_contains_data <= 1'b0;
                index <= 4'b0;
                data <= 8'b0;
            end
            // Process stop bit
            else if (index == 4'b1000 && pin == 1'b1) begin
                state_rx_contains_data <= 1'b1;
                index <= index + 1'b1;
                data <= data;
            end
            // Preserve values when not receiving
            else begin
                state_rx_contains_data <= ctrl_rx_contains_data;
                index <= index;
                data <= data;
            end
        end
    end

endmodule
