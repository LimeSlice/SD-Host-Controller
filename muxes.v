module mux2to1 
    #(parameter WIDTH=16)
    (a, b, s, q);
    input [WIDTH-1:0] a, b;
    input s;
    output reg [WIDTH-1:0] q;

    always @(a,b,s) begin
        if (s) q = b;
        else   q = a;
    end

endmodule

module mux4to1
    #(parameter WIDTH=16)
    (a, b, c, d, s, q);
    input [WIDTH-1:0] a, b, c, d;
    input [1:0] s;
    output reg [WIDTH-1:0] q;

    always @(a,b,c,d,s) begin
        case(s)
            0: q = a;
            1: q = b;
            2: q = c;
            3: q = d;
        endcase
    end
    
endmodule