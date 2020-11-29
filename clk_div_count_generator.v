module clk_div_count_generator (clk, reset, tran_speed, start, ok, err, count);
    input clk, reset, start;
    input [7:0] tran_speed;
    output ok, err;
    output [15:0] count;

    reg [31:0] rate_unit, rate, bigCount;
    wire [31:0] R; // don't know what it does...don't care
	assign count = bigCount[15:0];

    divider gen (
        // inputs
        clk, reset, start, 
        32'd50_000_000, rate, 
        // outputs
        bigCount, R,
        ok, err
    );

    always @(tran_speed) begin
        rate_unit = 2 ** ((4 + $unsigned(tran_speed[2:0]))*3/10);
        case (tran_speed[6:3])
            4'h1: rate = 10 * rate_unit;
            4'h2: rate = 12 * rate_unit;
            4'h3: rate = 13 * rate_unit;
            4'h4: rate = 15 * rate_unit;
            4'h5: rate = 20 * rate_unit;
            4'h6: rate = 25 * rate_unit; 
            4'h7: rate = 30 * rate_unit;
            4'h8: rate = 35 * rate_unit;
            4'h9: rate = 40 * rate_unit;
            4'hA: rate = 45 * rate_unit;
            4'hB: rate = 50 * rate_unit;
            4'hC: rate = 55 * rate_unit;
            4'hD: rate = 60 * rate_unit;
            4'hE: rate = 70 * rate_unit;
            4'hF: rate = 80 * rate_unit;
            default: rate = 0;
        endcase
    end

endmodule
