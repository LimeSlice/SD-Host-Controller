/**
  * Some registers have specific bits that cannot be written by the user. This mask can help
  * make specific bits ignored
  */
module mask_bits
    #(parameter WIDTH=16)
    (in, mask, out);
    input [WIDTH-1:0] in, mask;
    output [WIDTH-1:0] out;

    assign out = in & mask;

endmodule