module uart_tx (clk, resetn, pin, data, ctrl, state);
    input clk, resetn;
    input [7:0] data, ctrl;
    output reg pin;
    output [7:0] state;

    reg [3:0] index;
    reg state_tx_en, state_tx_sending;

    assign ctrl_en      = ctrl[0];
    assign ctrl_sending = ctrl[1];

    assign state = {ctrl[7:2], state_tx_sending, state_tx_en};

    always @(posedge clk, posedge resetn) begin
        if (resetn) begin
            pin <= 1'b1;
            index <= 4'b0;
            state_tx_sending <= 1'b0;
            state_tx_en <= 1'b0;
        end
        else begin
            // Send start bit
            if (tx_en) begin
                pin <= 1'b0;
                index <= 4'b0;
                state_tx_sending <= 1'b1;
                state_tx_en <= 1'b0;
            end
            else if (tx_sending) begin
                // Send indexed bit starting from bit 0
                if (index < 4'b1000) begin
                    pin <= data[index];
                    index <= index + 1'b1;
                    state_tx_sending <= 1'b1;
                    state_tx_en <= 1'b0;
                end
            end
            // Keep pin bit high (also encompasses a stop bit)
            else begin
                pin <= 1'b1;
                index <= index;
                state_tx_sending <= 1'b0;
                state_tx_en <= 1'b0;
            end
        end
    end
    
endmodule