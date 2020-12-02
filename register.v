module register
	#(parameter WIDTH=32, 
	  parameter [WIDTH-1:0] RST_VAL=0)
    (clk, reset, d, en, q);
	input clk, reset, en;
	input [WIDTH-1:0] d;
	output reg [WIDTH-1:0] q;
	 
	always @(posedge clk)
		begin
		if (reset) q <= RST_VAL;
		else begin			
			if (en) q <= d;
			else    q <= q;
		end
	end
	
endmodule
