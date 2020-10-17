module tb_card_detection;

    reg ex_clk, ex_resetn, sd_cmd, sd_cd, sd_wp;
    reg [3:0] sd_dat;

    specparam ENABLE = 1'b1, DISABLE = 1'b0;

    sd_host_controller uut(ex_clk, ex_resetn, sd_dat, sd_cmd, sd_cd, sd_wp);

    initial begin
        {ex_clk, ex_resetn, sd_dat, sd_cmd, sd_cd, sd_wp} = 'b0; #5;

        // Reset
        ex_resetn = 1'b1; #10;
        ex_resetn = 1'b0; #10;

        // To enable interrupt for card detection, write 1 to the following bits
        // Card Insertion Status Enable in the Normal Interrupt Status Enable register
        // Card Insertion Status Enable in the Normal Interrupt Signal Enable register
        // Card Removal Status Enable in the Normal Interrupt Status Enable register
        // Card Removal Status Enable in the Normal Interrupt Signal Enable register
        uut.datapath.regbank.norm_int_status_reg[6] = ENABLE;
        uut.datapath.regbank.norm_int_sig_en_reg[6] = ENABLE;
        uut.datapath.regbank.norm_int_status_reg[7] = ENABLE;
        uut.datapath.regbank.norm_int_sig_en_reg[7] = ENABLE; #100;

        //  
        
        
    end

    always #5 clk = ~clk;

endmodule