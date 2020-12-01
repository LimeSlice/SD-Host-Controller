module crc7 
    #(parameter WIDTH=40)
    (clk, reset, load, data_in, crc_ready, crc);
    input clk, reset, load;
    input [WIDTH-1:0] data_in;
    output reg crc_ready;
    output [6:0] crc;
    
    reg [WIDTH+6:0] data;
    reg [6:0] index;
    wire [7:0] divisor;

    // generator polynomial: G(x) = x^7 + x^3 + 1
    assign divisor = 8'b10001001;
    assign crc = data[7:0];

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            crc_ready <= 1'b0;
            index     <= WIDTH + 7'd6;
            data      <= 0;
        end
        else if (load) begin
            crc_ready <= 1'b0;
            index     <= WIDTH + 7'd6;
            data <= {data_in, 7'b0};
        end
        else begin
            // Algorithm stops here
            if (data[WIDTH+6:7] == 0) begin
                crc_ready <= 1'b1;
                index     <= 7'b0;
                data      <= data;
            end
            else begin
                index     <= index - 1'b1;
                crc_ready <= 1'b0;
                if (data[index]) begin
                    data[index -: 8] <= data[index -: 8] ^ divisor;
                end
                else begin
                    data <= data;
                end
            end
        end
    end

endmodule
