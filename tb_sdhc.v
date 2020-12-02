`timescale 1ps/1ps
module tb_sdhc;

reg clk, resetn, rx_pin, cd_pin, wp_pin;
wire tx_pin;
wire sd_cmd_pin;
wire [3:0] sd_dat_pin;

reg cmd_en, dat_en, cmd_pin;
reg dat_pin;

assign sd_cmd_pin = cmd_en ? cmd_pin : 1'bz;
assign sd_dat_pin = dat_en ? dat_pin : 4'bz;

// Helper registers / variables
reg [47:0] R1_response;
reg [31:0] card_status;
reg [6:0] crc7;

integer i;

sd_host_controller uut (
    clk, resetn, rx_pin,
    cd_pin, wp_pin,
    tx_pin,
    sd_cmd_pin,
    sd_dat_pin
);

always #5 clk = ~clk;

always @(posedge clk) begin
    if (uut.fsm.PS == 10'h240) $stop;
end

task RESETN; 
    begin
        $display("-----System Reset-----\n");
        resetn = 0; #10;
        resetn = 1; #10;
    end
endtask

task SD_CLK_PERIOD;
    begin
        #2520;
    end
endtask

initial begin

    clk = 0;
    resetn = 1;
    cd_pin = 0;
    wp_pin = 0;
    cmd_pin = 0;
    dat_pin = 0;
    cmd_en = 0;
    dat_en = 0;
    rx_pin = 1; 
    R1_response = 0; #5;

    RESETN;

    while (!uut.clk_div_cnt_gen_ok) begin
        #10;
    end

    $display("Clock divider has generated w/o CD @ time = %0d", $time);

    // check if system starts to propogate without CARD DETECT
    if (uut.fsm.PS != 10'h247) begin
        $display("Propogated states without a CARD DETECT\n");
        $stop;
    end

    cd_pin = 1;
    #10;

    while (!uut.clk_div_cnt_gen_ok) begin
        #10;
    end

    $display("Clock divider has generated w/ CD @ time = %0d", $time);

    #10; // change for FSM state takes 1 cycle

    // check if system starts to propogate with CARD DETECT
    if (uut.fsm.PS == 10'h247) begin
        $display("Did not propogated states with CARD DETECT\n");
        $stop;
    end

    // brief pause until it starts to send
    while (!uut.send.sending) begin
        #10;
    end

    $display("SD sending @ time = %0d", $time);

    // wait while sd sending data
    while (uut.send.sending) begin
        #10;
    end

    $display("SD done sending @ time = %0d", $time);

    // loop goes 1 ex_clk cycle past after finished receiving
    // wait 2 cycles to test timeout
    SD_CLK_PERIOD; // 1 sd_clk cycle

    if (uut.fsm.timeout_counter_out != 1) begin
        $display("Did not increment timeout counter\n");
        $stop;
    end

    #2510; // 1 sd_clk cycle - 1 ex_clk cycle 

    $display("Starting CMD55 response @ time = %0d", $time);

    // CRC7 calculator: http://www.ghsi.de/pages/subpages/Online%20CRC%20Calculation/
    // { start bit, transmission bit, 6 bits CMD_INDEX, 32 bits card status, 7 bits CRC7, end bit}
    card_status = 32'b0;
    crc7 = 7'h78;
    R1_response = {1'b0, 1'b0, 6'd55, card_status, crc7, 1'b1};

    for (i = 0; i < 48; i = i + 1) begin
        cmd_pin = R1_response[i]; 
        cmd_en = 1'b1;
        SD_CLK_PERIOD;
    end

    $display("SD received CMD55 response @ time = %0d", $time);

    #1000000;

    $stop;

end

endmodule
