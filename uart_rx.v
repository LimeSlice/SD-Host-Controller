module uart_rx(clk, resetn, pin, data, ctrl_rx_contains_data, state_rx_contains_data);
    input clk, resetn, pin, ctrl_rx_contains_data;
    output reg [7:0] data;
    output reg state_rx_contains_data;

    reg [3:0] index;

    always @(posedge clk, posedge resetn) begin
        if (resetn) begin
            state_rx_contains_data <= 1'b0;
            index <= 4'b1000;
            data <= 8'b0;
        end
        else begin
            // Processing start bit
            if (index == 4'b1000 && pin == 1'b0) begin
                state_rx_contains_data <= 1'b0;
                index <= 4'b0;
                data <= 8'b0;
            end
            // Fill data register until all data is filled
            else if (index < 4'b1000) begin
                state_rx_contains_data <= 1'b0;
                index <= index + 1'b1;
                data[index] <= pin;
            end
            // Process stop bit
            else if (index == 4'b100 && pin == 1'b1) begin
                state_rx_contains_data <= 1'b1;
                index <= index;
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
