module register
    #(parameter WIDTH=32)
    (clock, resetn, d, en, q);
	 input clock, resetn, en;
     input [WIDTH-1:0] d;
	 output reg [WIDTH-1:0] q;
	 
 always @(posedge clock)
	begin
	if (resetn) q <= 'b0;
	else
		begin			
			if (en) q <= d;
			else    q <= q;
        end
	end
endmodule