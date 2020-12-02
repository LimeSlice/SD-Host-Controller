`timescale 1ps/1ps
module tb_sdhc;

reg clk, resetn, rx_pin;
wire tx_pin;
wire sd_cmd_pin, sd_cd_pin, sd_wp_pin;
wire [3:0] sd_dat_pin;

integer i;

sd_host_controller uut (
    clk, resetn, rx_pin,
    tx_pin,
    sd_cmd_pin, sd_cd_pin, sd_wp_pin,
    sd_dat_pin
);

always #5 clk = ~clk;

task RESETN; 
    begin
        $display("-----System Reset-----\n");
        resetn = 0; #10;
        resetn = 1; #10;
    end
endtask

initial begin

    clk = 0;
    resetn = 1;
    rx_pin = 1; #3;

    RESETN;

end

endmodule
