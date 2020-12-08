module sd_resp_rx(clk, reset, en, R2_response, sd_cmd, response, finished, started);
    input clk, reset, en, sd_cmd, R2_response;
    output reg [133:1] response;
    output reg finished, started;

    reg [7:0] index;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            response <= 132'b0;
            index    <= 8'b0;
            finished <= 1'b0;
            started  <= 1'b0;
        end
        else begin
            // process bits if enabled
            if (en) begin
                // wait until sending
                if (sd_cmd === 1'bz) begin
                    response <= response;
                    index    <= index;
                    finished <= 1'b0;
                    started  <= 1'b0;
                end
                // process start bit
                else if (sd_cmd === 1'b0 && index == 8'd0) begin
                    response <= 132'b0; // reset response
                    index    <= 8'd134;
                    finished <= 1'b0;
                    started  <= 1'b1;
                end
                // process transmission bit
                else if (sd_cmd === 1'b0 && index == 8'd134) begin
                    response <= response; // don't add transmission bit
                    index    <= index - 1'b1;
                    finished <= 1'b0;
                    started  <= 1'b1;
                end
                else begin
                    if (R2_response) begin
                        // process stop bit
                        if (sd_cmd === 1'b1 && index == 8'd0) begin
                            response <= response;
                            index    <= 8'd0;
                            finished <= 1'b1;
                            started  <= 1'b1;
                        end
                        // process internal data
                        else begin
                            response[index] <= sd_cmd;
                            index                <= index - 1'b1;
                            finished             <= 1'b0;
                            started              <= 1'b1;
                        end
                    end
                    // not R2 response
                    else begin
                        // process stop bit
                        if (sd_cmd === 1'b1 && index == 8'd87) begin
                            response <= response;
                            index    <= 8'd0;
                            finished <= 1'b1;
                            started  <= 1'b1;
                        end
                        // process internal data
                        else begin
                            response[index] <= sd_cmd;
                            index                <= index - 1'b1;
                            finished             <= 1'b0;
                            started              <= 1'b1;
                        end
                    end
                end
            end
            // not enabled
            else begin
                response <= response;
                index    <= index;
                finished <= 1'b0;
                started  <= 1'b0;
            end
        end
    end

endmodule
