`timescale 1ps/1ps
module tb_crc7;

    reg clk, reset, load;
    reg [39:0] data;
    wire ready;
    wire [6:0] crc;

    crc7 #(40) uut (.clk(clk), .reset(reset), 
        .load(load), .data_in(data), .crc_ready(ready), .crc(crc));

    task RESET;
        begin
            $display("\n-----Reset-----\n");
            reset = 1; #20;
            reset = 0; #20;
        end
    endtask

    task CHECK_CRC;
        input [6:0] correct_crc;
        begin
            if (crc != correct_crc) begin
                $display("[ERR] CRC (%b) incorrect (expected %b)", crc, correct_crc);
                $stop;
            end
            else if (!ready) begin
                $display("[ERR] CRC ready bit not set high");
                $stop;
            end
            else 
                $display("!!! Successful code translation !!!");
        end
    endtask

    always #10 clk = ~clk;

    initial begin
        $monitor("data: %b, index: %0d, load: %b, crc_ready: %b, time: %0d", 
                 uut.data, uut.index, uut.load, uut.crc_ready, $time);
        clk = 0;
        reset = 0;
        data = 0;
        load = 0;
        #5; // Don't want everything changing on edge of clk

        RESET;

        $display("\n-----Testing CMD0-----\n");

        data = 40'b0100000000000000000000000000000000000000; 
        load = 1; #20;
        load = 0; #20;
        
        #1000;

        CHECK_CRC(7'b1001010);

        $display("\n-----TESTING CMD17-----\n");

        data = 40'b0101000100000000000000000000000000000000;
        load = 1; #20;
        load = 0; #20;
        
        #1000;

        CHECK_CRC(7'b0101010);

        $display("\n-----TESTING RESPONSE OF CMD17-----\n");

        data = 40'b0001000100000000000000000000100100000000; 
        load = 1; #20;
        load = 0; #20;
        
        #1000;

        CHECK_CRC(7'b0110011);

        $finish(2);
    end
    
endmodule


















