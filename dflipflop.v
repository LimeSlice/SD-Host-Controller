module dflipflop 
#(parameter WIDTH=8) (
    input clk, reset,
    input [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);

always @(posedge clk, posedge reset) begin
    if (reset)  q <= 0;
    else        q <= d;
end

endmodule
