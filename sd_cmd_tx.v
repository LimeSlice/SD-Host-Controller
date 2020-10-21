module sd_cmd_tx(clk, reset, en, sending, cmd, sd_cmd);
    input clk, reset, en;
    input [47:0] cmd;
    output reg sd_cmd, sending;

    reg [6:0] index;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            sd_cmd  <= 1'b1;
            index   <= 7'd47;
            sending <= 1'b0;
        end
        else begin
            // Sending
            if (en && index != 6'b0) begin
                sd_cmd  <= cmd[index];
                index   <= index - 1'b1;
                sending <= 1'b1;
            end
            // Keep cmd line high after sent
            else begin
                sd_cmd  <= 1'b1;
                index   <= index;
                sending <= 1'b0;
            end
        end
    end

endmodule
