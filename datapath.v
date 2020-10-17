module datapath(ex_clk, ex_reset);
    input ex_clk, ex_reset;

    wire internal_clk;

    wire sys_addr_en, blk_size_en, blk_cnt_en, arg_en, tran_mode_en,
         cmd_en, resp0_en, resp1_en, resp2_en, resp3_en, buff_data_port_en,
         ps_en, blk_gap_ctrl_en, wake_ctrl_en, clk_ctrl_en, timeout_ctrl_en,
         soft_rst_en, norm_int_status_en, err_int_status_en, 
         norm_int_status_en_en, err_int_status_en_en, norm_int_sig_en_en, 
         err_int_sig_en_en, auto_cmd12_err_en, hst_ctrl_ver_en, uart_tx_data_en, 
         uart_rx_data_en, uart_ctrl_status_en;
    wire [31:0] sys_addr_in, sys_addr_out, arg_in, arg_out, resp0_in, resp0_out,
                resp1_in, resp1_out, resp2_in, resp2_out, resp3_in, resp3_out,
                buff_data_port_in, buff_data_port_out, ps_in, ps_out; 
    wire [15:0] blk_size_in, blk_size_out, blk_cnt_in, blk_cnt_out, cmd_in, 
                cmd_out, clk_ctrl_in, clk_ctrl_out, norm_int_status_in,
                norm_int_status_out, err_int_status_in, err_int_status_out, 
                norm_int_status_en_in, norm_int_status_en_out, 
                err_int_status_en_in, err_int_status_en_out, 
                norm_int_sig_en_in, norm_int_sig_en_out, err_int_sig_en_in, 
                err_int_sig_en_out, hst_ctrl_ver_in, hst_ctrl_ver_out;
    wire [7:0]  tran_mode_in, tran_mode_out, blk_gap_ctrl_in, blk_gap_ctrl_out,
                wake_ctrl_in, wake_ctrl_out, timeout_ctrl_in, timeout_ctrl_out,
                soft_rst_in, soft_rst_out, auto_cmd12_err_in, auto_cmd12_err_out,
                uart_tx_data_in, uart_tx_data_out, uart_rx_data_in, 
                uart_rx_data_out, uart_ctrl_status_in, uart_ctrl_status_out;

    regbank registers (
        clk, ex_reset, 
        // Enables
        sys_addr_en, blk_size_en, blk_cnt_en, arg_en, 
        tran_mode_en, cmd_en, resp0_en, resp1_en, resp2_en, resp3_en, 
        buff_data_port_en, ps_en, blk_gap_ctrl_en, wake_ctrl_en, clk_ctrl_en, 
        timeout_ctrl_en, soft_rst_en, norm_int_status_en, err_int_status_en, 
        norm_int_status_en_en, err_int_status_en_en, norm_int_sig_en_en, 
        err_int_sig_en_en, auto_cmd12_err_en, hst_ctrl_ver_en, uart_tx_data_en, 
        uart_rx_data_en, uart_ctrl_status_en,
        // 32-bit
        sys_addr_in, arg_in, resp0_in, resp1_in, resp2_in, resp3_in,
        buff_data_port_in, ps_in,
        sys_addr_out, arg_out, resp0_out, resp1_out, resp2_out, 
        resp3_out, buff_data_port_out, ps_out,
        // 16-bit
        blk_size_in, blk_cnt_in, cmd_in, clk_ctrl_in, 
        norm_int_status_in, err_int_status_in, norm_int_status_en_in, 
        err_int_status_en_in, norm_int_sig_en_in, err_int_sig_en_in, 
        hst_ctrl_ver_in,
        blk_size_out, blk_cnt_out, cmd_out, clk_ctrl_out, 
        norm_int_status_out, err_int_status_out, 
        norm_int_status_en_out, err_int_status_en_out, 
        norm_int_sig_en_out, err_int_sig_en_out, hst_ctrl_ver_out,   
        // 8-bit
        tran_mode_in, blk_gap_ctrl_in, wake_ctrl_in, timeout_ctrl_in,
        soft_rst_in, auto_cmd12_err_in, uart_tx_data_in, uart_rx_data_in, 
        uart_ctrl_status_in,
        tran_mode_out, blk_gap_ctrl_out, wake_ctrl_out, 
        timeout_ctrl_out, soft_rst_out, auto_cmd12_err_out, uart_tx_data_out,
        uart_rx_data_out, uart_ctrl_status_out
    );

    // When stopped, internal clock goes low (low-power state)
    // clk_ctrl_out[0] - internal clock enable
    tribuffer_1bit internal_clk (
        .in(ex_clk),
        .en(clk_ctrl_out[0]),
        .out(internal_clk)
    );


endmodule
