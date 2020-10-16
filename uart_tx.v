module uart_tx(clk, resetn, pin, data, ctrl, state_tx_sending, state_tx_en);
    input clk, resetn;
    input [7:0] data, ctrl;
    output reg pin, state_tx_en, state_tx_sending;

    reg [3:0] index;
    
    assign ctrl_tx_en      = ctrl[0];
    assign ctrl_tx_sending = ctrl[1];

    always @(posedge clk, posedge resetn) begin
        if (resetn) begin
            pin <= 1'b1;
            index <= 4'b0;
            state_tx_sending <= 1'b0;
            state_tx_en <= 1'b0;
        end
        else begin
            if (ctrl_tx_sending) begin
                // Send indexed bit starting from bit 0
                if (index < 4'b1000) begin
                    pin <= data[index];
                    index <= index + 1'b1;
                    state_tx_sending <= 1'b1;
                    state_tx_en <= 1'b1;
                end
                // Send stop
                else begin
                    pin <= 1'b1;
                    index <= index;
                    state_tx_sending <= 1'b0;
                    state_tx_en <= 1'b0;
                end
            end
            // Send start bit
            else if (ctrl_tx_en) begin
                pin <= 1'b0;
                index <= 4'b0;
                state_tx_sending <= 1'b1;
                state_tx_en <= 1'b1;
            end
            // Keep pin bit high
            else begin
                pin <= 1'b1;
                index <= index;
                state_tx_sending <= 1'b0;
                state_tx_en <= 1'b0;
            end
        end
    end
    
endmodule