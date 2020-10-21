module sd_bus_protocol(ex_clk, sd_clk, sd_cmd, sd_dat);
    input sd_clk;
    inout sd_cmd;
    inout [3:0] sd_dat;

    assign sd_cmd = cmd_we ? 1'bz : send_cmd;
    assign sd_dat = dat_we ? 4'bz : send_dat;

    sd_send    send    (, , , send_cmd);
    sd_receive receive ();

endmodule
