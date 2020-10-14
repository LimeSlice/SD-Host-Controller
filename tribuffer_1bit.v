module tribuffer_1bit(in, en, out);
    input in, en;
    output out;

    assign out = en ? in : 1'b0;

endmodule
