module sd_host_controller(clk, resetn, sd_dat, sd_cmd, sd_cd, sd_wp);
    input clk, resetn, sd_cmd, sd_cd, sd_wp;
    input [3:0] sd_dat;


    


    // 0F-00 SD Command Generation
    // 1F-10 Response
    // 23-20 Data Port
    // 2F-24 Host Controls
    // 3D-30 Interrupt Controls
    // 4F-40 Capabilities
    // FF-F0 Common Area
    register #(256) standard_register_set (
        .clock(clock),
        .resetn(resetn),
        .d(reg_in),
        .en(reg_en),
        .q(reg_out)
    );

endmodule
