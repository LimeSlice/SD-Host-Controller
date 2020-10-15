module counter
    #(parameter COUNT_BITS=8, COUNT=250)
    (
        input clk, rst,
        output reg out
    );

    wire [COUNT_BITS-1:0] counter = 'b0;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            out <= 1'b0;
            counter <= 'b0;
        end
        else if (counter == COUNT) begin
            out <= 1'b1;
            counter <= counter + 'b1;
        end
        else begin
            out <= 1'b0;
            counter <= counter + 'b1;
        end
    end

endmodule