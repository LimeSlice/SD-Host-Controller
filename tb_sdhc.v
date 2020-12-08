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
reg [135:0] R2_response;
reg [126:0] cid;
reg [47:0] R1_response, R3_response, R6_response;
reg [31:0] card_status, ocr;
reg [15:0] rca;
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
    #20;
end
endtask

task CMD55;
begin
    // brief pause until it starts to send
    while (!uut.send.sending) begin
        #10;
    end

    $display("SD sending CMD55 @ time = %0d", $time);

    // wait while sd sending data
    while (uut.send.sending) begin
        #10;
    end

    $display("SD done sending @ time = %0d", $time);

    #40;

    $display("Starting CMD55 response @ time = %0d", $time);

    // CRC7 calculator: http://www.ghsi.de/pages/subpages/Online%20CRC%20Calculation/
    // { start bit, transmission bit, 6 bits CMD_INDEX, 32 bits card status, 7 bits CRC7, end bit}
    card_status = 32'd0;
    crc7 = 7'h78;
    cmd_en = 1'b1;
    R1_response = {1'b0, 1'b0, 6'd55, card_status, crc7, 1'b1};

    for (i = 47; i >= 0; i = i - 1) begin
        cmd_pin = R1_response[i]; 
        SD_CLK_PERIOD;
    end

    SD_CLK_PERIOD;

    $display("SD received CMD55 response @ time = %0d", $time);

    cmd_en = 1'b0; SD_CLK_PERIOD;
end
endtask

task ACMD41;
begin
    // brief pause until it starts to send
    while (!uut.send.sending) begin
        #10;
    end

    $display("SD sending ACMD41 @ time = %0d", $time);

    while (uut.send.sending) begin
        #10;
    end

    $display("SD done sending @ time = %0d", $time);

    #40;

    $display("Starting ACMD41 response @ time = %0d", $time);

    // OCR[31] - busy flag
    // OCR defines what voltages ranges SD card can handle
    ocr = {1'b0, 31'b1};
    cmd_en = 1'b1;
    R3_response = {1'b0, 1'b0, 6'h3F, ocr, 7'h7F, 1'b1};

    for (i = 47; i >= 0; i = i - 1) begin
        cmd_pin = R3_response[i];
        SD_CLK_PERIOD;
    end

    SD_CLK_PERIOD;

    $display("SD received ACMD41 response @ time = %0d", $time);

    cmd_en = 1'b0; SD_CLK_PERIOD;   
end
endtask

task CMD2;
begin
    // brief pause until it starts to send
    while (!uut.send.sending) begin
        #10;
    end

    $display("SD sending CMD2 @ time = %0d", $time);

    while (uut.send.sending) begin
        #10;
    end

    $display("SD done sending @ time = %0d", $time);

    #40;

    $display("Starting CMD2 response @ time = %0d", $time);

    // cid is info about the SD card. random values can be used, but internal
    // CRC must be valid
    crc7 = 7'h59;
    cid = {120'h7E4456BFAFE53C7AB12900000ECD, crc7};
    cmd_en = 1'b1;
    R2_response = {1'b0, 1'b0, 6'h3F, cid, 1'b1};

    for (i = 135; i >= 0; i = i - 1) begin
        cmd_pin = R2_response[i];
        SD_CLK_PERIOD;
    end

    SD_CLK_PERIOD;

    $display("SD received CMD2 response @ time = %0d", $time);

    cmd_en = 1'b0; SD_CLK_PERIOD; 
end
endtask

task CMD3;
begin
    // brief pause until it starts to send
    while (!uut.send.sending) begin
        #10;
    end

    $display("SD sending CMD3 @ time = %0d", $time);

    while (uut.send.sending) begin
        #10;
    end

    $display("SD done sending @ time = %0d", $time);

    #40;

    $display("Starting CMD3 response @ time = %0d", $time);

    rca = 16'hF792;
    card_status = 16'd0;
    crc7 = 7'h17;
    cmd_en = 1'b1;
    R6_response = {1'b0, 1'b0, 6'd3, rca, card_status[15:0], crc7, 1'b1};

    for (i = 47; i >= 0; i = i - 1) begin
        cmd_pin = R6_response[i];
        SD_CLK_PERIOD;
    end

    SD_CLK_PERIOD;

    $display("SD received CMD3 response @ time = %0d", $time);

    cmd_en = 1'b0; SD_CLK_PERIOD; 
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

    CMD55;

    ACMD41;

    CMD2;

    CMD3;    

    while (!uut.receive.crc_ready_40) #10;

    $stop;
end

endmodule
