module uart_rx(clk, resetn, pin, data, ctrl, state);
    input clk, resetn, pin;
    input [7:0] ctrl;
    output [7:0] state;
    output reg [7:0] data;

    reg [3:0] index;

    reg state_rx_contains_data;

    assign state = {ctrl[7:3], state_rx_contains_data, ctrl[1:0]};

    always @(posedge clk, posedge resetn) begin
        if (resetn) begin
            state_rx_contains_data <= 1'b0;
            index <= 4'b1000;
            data <= 8'b0;
        end
        else begin
            // Processing stop bit
            if (index == 4'b1000 && pin == 1'b0) begin
                state_rx_contains_data <= 1'b0;
                index <= 4'b0;
                data <= 8'b0;
            end
            else if
        end
    end
