module tribuffer_1bit(in, en, out);
    input in, en;
    output out;

    assign out = en ? in : 1'b0;

endmodule

module tribuffer
    #(parameter WIDTH=16)
    (in, en, out);
    input [WIDTH-1:0] in;
    input en;
    output [WIDTH-1:0] out;

    assign out = en ? in : 'b0;

endmodule