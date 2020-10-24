module sd_resp_rx(clk, reset, en, R2_response, sd_cmd, response, finished);
    input clk, reset, en, sd_cmd, R2_response;
    output reg [134:0] response;
    output reg finished;

    reg [7:0] index;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            response <= 134'b0;
            index    <= 8'b0;
            finished <= 1'b0;
        end
        else begin
            // Process responses if enabled
            if (en) begin
                // Process start bit
                if (index == 8'b0 && sd_cmd == 1'b0) begin
                    response <= 134'b0; // reset response
                    index    <= 8'd134;
                    finished <= 1'b0;
                end
                // Process transmission bit
                else if (index == 8'd134 && sd_cmd == 1'b0) begin
                    response <= response; // preserve response 
                    index    <= index - 1'b1;
                    finished <= 1'b0;
                end
                // Process response and stop bit based on type
                else begin
                    if (R2_response) begin
                        // Process stop bit
                        if (index == 0 && sd_cmd == 0) begin
                            response <= response; // preserve response
                            index    <= 8'd0;
                            finished <= 1'b1;
                        end
                        // Preserve data after finished
                        else if (finished) begin
                            response <= response;
                            index    <= index;
                            finished <= finished;
                        end
                        // Process internal data
                        else begin
                            response[index-1'b1] <= sd_cmd;
                            index                <= index - 1'b1;
                            finished             <= 1'b0;
                        end
                    end
                    else begin
                        // Process stop bit
                        if (index == 8'd87 && sd_cmd == 1'b1) begin
                            response <= response; // preserve response
                            index    <= 8'd0;
                            finished <= 1'b1;
                        end
                        // Preserve data after finished
                        else if (finished) begin
                            response <= response;
                            index    <= index;
                            finished <= finished;
                        end
                        // Process internal data
                        else begin
                            response[index-1'b1] <= sd_cmd;
                            index                <= index - 1'b1;
                            finished             <= 1'b0;
                        end
                    end
                end
            end 
            // Not enabled
            else begin
                response <= response;
                index    <= index;
                finished <= finished;
            end
        end
    end

endmodule
