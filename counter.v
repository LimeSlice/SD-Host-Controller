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
            counter <= 1'b0;
        end
        else if (counter == count) begin
            out <= ~out;
            counter <= 1'b0;
        end
        else begin
            out <= out;
            counter <= counter + 1'b1;
        end
    end

endmodule
