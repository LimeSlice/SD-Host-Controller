module sd_host_controller(ex_clk, ex_resetn, sd_dat, sd_cmd, sd_cd, sd_wp);
    input ex_clk, ex_resetn, 
    inout sd_cmd, sd_cd, sd_wp;
    inout [3:0] sd_dat;


    datapath dp (ex_clk, ex_resetn);

endmodule
