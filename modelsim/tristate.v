module tristate (a, e, z);

    input a, e;
    output z;
    tri z;

    tri_3v b1 (a, z, e);

endmodule
