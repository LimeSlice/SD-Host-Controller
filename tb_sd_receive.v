`timescale 1ps/1ps
module tb_sd_receive;
    reg ex_clk, sd_clk, reset, en, R2_response, sd_cmd;
    wire [126:0] response;
    wire crc_err;

    reg error;
    reg [47:0] trasmit_buf_40;
    reg [135:0] trasmit_buf_136;

    integer i;

    sd_receive uut (ex_clk, sd_clk, reset, en, R2_response, sd_cmd, response, crc_err);

    task RESET;
        begin
            $display("\n-----System Reset-----\n");
            R2_response = 0; 
            sd_cmd = 0;
            trasmit_buf_40 = 0;
            trasmit_buf_136 = 0;
            reset = 1; #10;
            reset = 0; #10;
        end
    endtask

    task CHECK_RESP;
        begin
            $display("\n-----Checking Response-----");
            if (!R2_response) begin
                if (uut.rx_resp[94:88] != 7'b0110011) begin
                    $display("[ERR] received CRC invalid");
                    if (!crc_err) 
                        $display("[ERR] crc_err flag low when CRC incorrect");
                    error = 1;
                end
                if (uut.rx_resp[94:88] == 7'b0110011) begin
                    if (crc_err) begin
                        $display("[ERR] crc_err flag high when CRC matches");
                        error = 1;
                    end
                end
                if (uut.rx_resp[134:88] != 47'b00010001000000000000000000001001000000000110011) begin
                    $display("[ERR] did not receive correct response");
                    error = 1;
                end
                if (response != uut.rx_resp[134:8]) begin
                    $display("[ERR] did not partition incoming response correctly");
                    error = 1;
                end
            end
            if (error) $stop;
        end
    endtask

    always begin
        sd_clk = ~sd_clk;
        ex_clk = ~ex_clk; #5;
    end

    always @(negedge sd_clk) begin
        $display("sd_cmd: %b, rx_resp: %b, rx_idx: %0d",
            sd_cmd, uut.rx_resp, uut.receiver.index);
        $display("\tstate: %b, finished: %b, ready_40: %b, ready_120: %b, crc_err: %b",
            uut.PS, uut.finished, uut.crc_ready_40, uut.crc_ready_120, crc_err);
    end 

    initial begin
        ex_clk = 0;
        sd_clk = 0; 
        reset = 0;
        R2_response = 0; 
        sd_cmd = 0;
        trasmit_buf_40 = 0;
        trasmit_buf_136 = 0;
         #2; // Don't want everything changing on edge of clk

        RESET;

        $display("\n-----Testing 40-bit Response-----\n");

        // Simulating CMD17 (READ_SINGLE_BLOCK) response
        trasmit_buf_40 = 48'b000100010000000000000000000010010000000001100111;
        en = 1; #10;
        en = 0;
        for (i=47; i>+0; i=i-1) begin
            sd_cmd = trasmit_buf_40[i];
            #10;
        end
        #1000;

        CHECK_RESP;

        // $display("\n-----Testing 136-bit Response-----\n");

        $finish(2);

    end


endmodule
