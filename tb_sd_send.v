`timescale 1ps/1ps
module tb_sd_send;
    reg ex_clk, sd_clk, reset, send_en;
    reg [37:0] cmd_content;
    reg [47:0] correct_send;
    wire sd_cmd, sending;
    wire [3:0] sd_dat;

    integer index;

    sd_send uut (ex_clk, sd_clk, reset, send_en, cmd_content, sending, sd_cmd, sd_dat);

    task RESET;
        begin
            $display("\n-----System Reset-----\n");
            reset = 1; #10;
            reset = 0; #10;
        end
    endtask

    task CHECK_SEND;
        begin
            if (sending) begin
                if (correct_send[index] != sd_cmd) begin
                    $display("[ERR] SD_CMD (%b) does not match expected value (%b)",
                                sd_cmd, correct_send[index]);
                    $stop;
                end
                else index = index - 1;
            end
            else index = 47;
        end
    endtask

    always begin
        sd_clk = ~sd_clk;
        ex_clk = ~ex_clk; #5;
    end

    always @(posedge sd_clk) CHECK_SEND;

    always @(negedge sd_clk) 
        $display("state: %b, crc_load: %b, crc: %b, crc_ready: %b, crc_index: %0d, index: %0d, tx_index: %0d, sd_cmd: %0b, uut.cmd_token: %b, time: %0d", 
                uut.PS, uut.crc_load, uut.cmd_crc, uut.crc_ready, uut.crc_gen.index, index, uut.transmitter.index, sd_cmd, uut.cmd_token, $time);
        

    initial begin
        // $monitor("state: %b, crc_prep: %b, crc: %b, crc_ready: %b, crc_index: %0d, index: %0d, tx_index: %0d, sd_cmd: %0b, uut.cmd_token: %b, time: %0d", 
        //         uut.PS, uut.crc_prep, uut.cmd_crc, uut.crc_ready, uut.crc_gen.index, index, uut.transmitter.index, sd_cmd, uut.cmd_token, $time);
        sd_clk = 0;
        ex_clk = 0;
        reset = 0;
        send_en = 0;
        cmd_content = 0;
        correct_send = 0;
        #2; // Don't want everything changing on edge of clk

        RESET;

        $display("\n-----Testing CMD0-----\n");

        cmd_content = 38'b0;
        correct_send = 48'b010000000000000000000000000000000000000010010101;
        send_en = 1'b1;
        #20;
        send_en = 1'b0;
        #1000;

        RESET;

        $display("\n-----TESTING CMD17-----\n");

        cmd_content = 38'b01000100000000000000000000000000000000;
        correct_send = 48'b010101000100000000000000000000000000000001010101;
        send_en = 1'b1;
        #20;
        send_en = 1'b0;
        #1000;

        $finish(2);
    end

endmodule
