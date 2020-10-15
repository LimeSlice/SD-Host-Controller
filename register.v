module register
    #(parameter WIDTH=32)
    (clk, resetn, d, en, q);
	 input clk, resetn, en;
     input [WIDTH-1:0] d;
	 output reg [WIDTH-1:0] q;
	 
 always @(posedge clk)
	begin
	if (resetn) q <= 'b0;
	else
		begin			
			if (en) q <= d;
			else    q <= q;
        end
	end
endmodule