`timescale 1ps/1ps
module tb_crc7;

    reg clk, reset;
    reg [39:0] data;
    wire [6:0] crc;

    integer i;

    crc7 uut ();

    task RESET;
        begin
            $display("\n-----System Reset-----\n");
            reset = 1; #20;
            reset = 0; #20;
        end
    endtask

    task CHECK_CRC;
        input [6:0] correct_crc;
        begin
            if (crc != correct_crc) begin
                $display("[ERR] CRC incorrect (expected %b)", correct_crc);
                $stop;
            end
            else 
                $display("!!! Successful code translation !!!")
        end
    endtask

    always #10 clk = ~clk;

    initial begin
        $monitor("data: %b, crc: %b, time: %0d", data, crc, $time);
        clk = 0;
        reset = 0;
        data = 0;
        i = 0;
        #5; // Don't want everything changing on edge of clk

        RESET;

        $display("\n-----Testing CMD0-----\n");

        data = 40'b0; #80;

        CHECK_CRC(7'b1001010);

        RESET;

        $display("\n-----TESTING CMD17-----\n");

        data = 40'b0100010000000000000000000000000000000000; #80;

        CHECK_CRC(7'b0101010);

        RESET;

        $display("\n-----TESTING RESPONSE OF CMD17-----\n");

        data = 40'b0100010000000000000000000000100100000000; #80;

        CHECK_CRC(7'b0110011);

        $finish(2);
    end
    


endmodule
