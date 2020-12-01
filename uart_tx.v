module uart_tx(
    input clk, reset, ctrl_out_tx_en, ctrl_out_tx_sending,
    input [7:0] data,
    output reg pin, ctrl_in_tx_sending
);

    reg [3:0] index;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            pin <= 1'b1;
            index <= 4'b0;
            ctrl_in_tx_sending <= 1'b0;
        end
        else begin
            if (ctrl_out_tx_sending) begin
                // Send indexed bit starting from bit 0
                if (index < 4'b1000) begin
                    pin <= data[index];
                    index <= index + 1'b1;
                    ctrl_in_tx_sending <= 1'b1;
                end
                // Send stop
                else begin
                    pin <= 1'b1;
                    index <= index;
                    ctrl_in_tx_sending <= 1'b0;
                end
            end
            // Send start bit
            else if (ctrl_out_tx_en) begin
                pin <= 1'b0;
                index <= 4'b0;
                ctrl_in_tx_sending <= 1'b1;
            end
            // Keep pin bit high
            else begin
                pin <= 1'b1;
                index <= index;
                ctrl_in_tx_sending <= 1'b0;
            end
        end
    end

endmodule