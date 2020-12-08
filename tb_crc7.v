`timescale 1ps/1ps
module tb_crc7;

    reg clk, reset;
    reg load_40, load_120;
    reg [119:0] data_120;
    reg [39:0] data_40;
    wire ready_40, ready_120;
    wire [6:0] crc_40, crc_120;

    reg which_crc;  // 0 - uut40    1 - uut120

    crc7 #(40) uut_40 (.clk(clk), .reset(reset), 
        .load(load_40), .data_in(data_40), .crc_ready(ready_40), .crc(crc_40));
    crc7 #(120) uut_120 (.clk(clk), .reset(reset),
        .load(load_120), .data_in(data_120), .crc_ready(ready_120), .crc(crc_120));

    task RESET;
        begin
            $display("\n-----Reset-----\n");
            reset = 1; #20;
            reset = 0; #20;
        end
    endtask

    task CHECK_CRC_40;
        input [6:0] correct_crc;
        begin
            if (crc_40 != correct_crc) begin
                $display("\n[ERR] CRC (%b) incorrect (expected %b)\n", crc_40, correct_crc);
                $stop;
            end
            else if (!ready_40) begin
                $display("\n[ERR] CRC ready bit not set high\n");
                $stop;
            end
            else 
                $display("\n!!! Successful code translation !!!\n");
        end
    endtask

    task CHECK_CRC_120;
        input [6:0] correct_crc;
        begin
            if (crc_120 != correct_crc) begin
                $display("\n[ERR] CRC (%b) incorrect (expected %b)\n", crc_120, correct_crc);
                $stop;
            end
            else if (!ready_120) begin
                $display("\n[ERR] CRC ready bit not set high\n");
                $stop;
            end
            else 
                $display("\n!!! Successful code translation !!!\n");
        end
    endtask

    always #10 clk = ~clk;

    always @(posedge clk) begin
        if (!which_crc)
            $display("data: %b, index: %02d, load: %b, crc_ready: %b, time: %0d",
                    uut_40.data, uut_40.index, uut_40.load, uut_40.crc_ready, $time);
        else 
            $display("data: %b, index: %03d, load: %b, crc_ready: %b, time: %0d",
                    uut_120.data, uut_120.index, uut_120.load, uut_120.crc_ready, $time);
    end

    initial begin
        clk = 0;
        reset = 0;
        data_40 = 0;
        data_120 = 0;
        load_40 = 0;
        load_120 = 0;
        which_crc = 0; 
        #5; // Don't want everything changing on edge of clk

        RESET;

        $display("\n-----Testing CMD0-----\n");

        data_40 = 40'b0100000000000000000000000000000000000000; 
        load_40 = 1; #20;
        load_40 = 0; #20;
        
        while (!ready_40) #20;

        CHECK_CRC_40(7'b1001010);

        $display("\n-----TESTING CMD17-----\n");

        data_40 = 40'b0101000100000000000000000000000000000000;
        load_40 = 1; #20;
        load_40 = 0; #20;
        
        while (!ready_40) #20;

        CHECK_CRC_40(7'b0101010);

        $display("\n-----TESTING RESPONSE OF CMD17-----\n");

        data_40 = 40'b0001000100000000000000000000100100000000; 
        load_40 = 1; #20;
        load_40 = 0; #20;
        
        while (!ready_40) #20;

        CHECK_CRC_40(7'b0110011);

        which_crc = 1;
        data_120 = 120'h7E4456BFAFE53C7AB12900000ECD;
        load_120 = 1; #20;
        load_120 = 0; #20;

        while (!ready_120) #20;

        CHECK_CRC_120(7'h59);

        $finish(2);
    end
    
endmodule


















