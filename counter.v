module counter
    (
        input clk, reset,
        input [15:0] count,
        output reg out
    );

    reg [15:0] counter = 16'b0;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            out <= 1'b0;
            counter <= 'b0;
        end
        else if (counter == count) begin
            out <= 1'b1;
            counter <= counter + 'b1;
        end
        else begin
            out <= 1'b0;
            counter <= counter + 'b1;
        end
    end

endmodule