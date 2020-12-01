module regbank (
    input clk, ex_resetn, sys_addr_en, blk_size_en, blk_cnt_en, arg_en, 
          tran_mode_en, cmd_en, resp0_en, resp1_en, resp2_en, resp3_en, 
          buff_data_port_en, ps_en, blk_gap_ctrl_en, wake_ctrl_en, clk_ctrl_en, 
          timeout_ctrl_en, soft_rst_en, norm_int_status_en, err_int_status_en, 
          norm_int_status_en_en, err_int_status_en_en, norm_int_sig_en_en, 
          err_int_sig_en_en, auto_cmd12_err_en, hst_ctrl_ver_en, uart_tx_data_en, 
          uart_rx_data_en, uart_ctrl_status_en,
    
    input [31:0]    sys_addr_in, arg_in, resp0_in, resp1_in, resp2_in, resp3_in,
                    buff_data_port_in, ps_in,
    output [31:0]   sys_addr_out, arg_out, resp0_out, resp1_out, resp2_out, 
                    resp3_out, buff_data_port_out, ps_out,

    input [15:0]    blk_size_in, blk_cnt_in, cmd_in, clk_ctrl_in, 
                    norm_int_status_in, err_int_status_in, norm_int_status_en_in, 
                    err_int_status_en_in, norm_int_sig_en_in, err_int_sig_en_in, 
                    hst_ctrl_ver_in,
    output [15:0]   blk_size_out, blk_cnt_out, cmd_out, clk_ctrl_out, 
                    norm_int_status_out, err_int_status_out, 
                    norm_int_status_en_out, err_int_status_en_out, 
                    norm_int_sig_en_out, err_int_sig_en_out, hst_ctrl_ver_out,   
    
    input [7:0]     tran_mode_in, blk_gap_ctrl_in, wake_ctrl_in, timeout_ctrl_in,
                    soft_rst_in, auto_cmd12_err_in, uart_tx_data_in, 
                    uart_rx_data_in, uart_ctrl_status_in,
    output [7:0]    tran_mode_out, blk_gap_ctrl_out, wake_ctrl_out, 
                    timeout_ctrl_out, soft_rst_out, auto_cmd12_err_out,
                    uart_tx_data_out, uart_rx_data_out, uart_ctrl_status_out
);

    wire soft_reset_dat_line, soft_reset_cmd_line, soft_reset_all;

    assign soft_reset_dat_line = soft_rst_out[2];
    assign soft_reset_cmd_line = soft_rst_out[1];
    assign soft_reset_all =      soft_rst_out[0];
    
    // System Address Register (RW)
    // Contains system memory address for DMA transfer
    register #(32,0) sys_addr_reg (
        .clock(clk),
        .resetn(ex_resetn),
        .d(sys_addr_in),
        .en(sys_addr_en),
        .q(sys_addr_out)
    );

    // Block Size Register (RW)
    // Used to configure number of bytes in a data block
    register #(16,0) blk_size_reg 
        (clk, resetn, blk_size_in, blk_size_en, blk_size_out);

    // Block Counter Register (RW)
    // Used to configure number of data blocks
    register #(16,0) blk_cnt_reg
        (clk, resetn, blk_cnt_in, blk_cnt_en, blk_cnt_out);

    // Argument Register (RW)
    // SD Command Argument
    register #(32) arg_reg
        (clk, resetn, arg_in, arg_en, arg_out);

    // Transfer Mode Register (RW)
    // Control Operation of data transfers
    register #(32) tran_mode_reg
        (clk, resetn, tran_mode_in, tran_mode_en, tran_mode_out);

    // Command Register (RW)
    // Controls for Host to trigger SD command generation
    register #(16) cmd_reg
        (clk, resetn, cmd_in, cmd_en, cmd_out);

    // Response Registers (ROC)
    // Stores responses from SD card
    // 31..0
    register #(32) resp0_reg
        (clk, resetn, resp0_in, resp0_en, resp0_out);
    // 63..32
    register #(32) resp1_reg
        (clk, resetn, resp1_in, resp1_en, resp1_out);
    // 95..64
    register #(32) resp2_reg
        (clk, resetn, resp2_in, resp2_en, resp2_out);
    // 127..96
    register #(32) resp3_reg
        (clk, resetn, resp3_in, resp3_en, resp3_out);

    // Buffer Data Port Register (RW)
    // 32-bit data port register to access internal buffer
    register #(32) buff_data_port_reg
        (clk, resetn, buff_data_port_in, buff_data_port_en, buff_data_port_out);

    // Present State Register (RO)
    // Status of Host Controller
    register #(32) ps_reg
        (clk, resetn, ps_in, ps_en, ps_out);

    // Block Gap Control Register (RW, RWAC)
    // Controls for reading, writing, requesting, etc
    register #(8) blk_gap_ctrl_reg
        (clk, resetn, blk_gap_ctrl_in, blk_gap_ctrl_en, blk_gap_ctrl_out);

    // Wakeup Control Register (RW)
    // Wakeup functionality to begin IC power and clock cycle
    register #(8) wake_ctrl_reg
        (clk, resetn, wake_ctrl_in, wake_ctrl_en, wake_ctrl_out);

    // Clock Control Register (RW, ROC)
    // Clock Control
    // Internal Clock Stable (bit 1) is ROC
    register #(16) clk_ctrl_reg
        (clk, resetn, clk_ctrl_in, clk_ctrl_en, clk_ctrl_out);

    // Timeout Control Register (RW)
    // Timeout counter value according to the capabilities register
    register #(8) timeout_ctrl_reg
        (clk, resetn, timeout_ctrl_in, timeout_ctrl_en, timeout_ctrl_out);

    // Software Reset Register (RWAC)
    register #(8) soft_rst_reg
        (clk, resetn, soft_rst_in, soft_rst_en, soft_rst_out);

    // Normal Interrupt Status Register (ROC, RW1C)
    register #(16) norm_int_status_reg
        (clk, resetn, norm_int_status_in, norm_int_status_en, norm_int_status_out);

    // Error Interrupt Status Register (RW1C)
    register #(16) err_int_status_reg
        (clk, resetn, err_int_status_in, err_int_status_en, err_int_status_out);

    // Normal Interrupt Status Enable Register (RW)
    register #(16) norm_int_status_en_reg
        (clk, resetn, norm_int_status_en_in, norm_int_status_en_en, norm_int_status_en_out);

    // Error Interrupt Status Enable Register (RW)
    register #(16) err_int_status_en_reg
        (clk, resetn, err_int_status_en_in, err_int_status_en_en, err_int_status_en_out);

    // Normal Interrupt Signal Enable Register (RW)
    register #(16) norm_int_sig_en_reg
        (clk, resetn, norm_int_sig_en_in, norm_int_sig_en_en, norm_int_sig_en_out);

    // Error Interrupt Signal Enable Register (RW)
    register #(16) err_int_sig_en_reg
        (clk, resetn, err_int_sig_en_in, err_int_sig_en_en, err_int_sig_en_out);

    // Auto CMD12 Error Status Register
    register #(16) auto_cmd12_err_status_reg
        (clk, resetn, auto_cmd12_err_in, auto_cmd12_err_en, auto_cmd12_err_out);

    // Host Controller Version Register
    register #(16) hst_ctrl_ver_reg
        (clk, resetn, hst_ctrl_ver_in, hst_ctrl_ver_en, hst_ctrl_ver_out);

    // UART Transmitter Data Register
    register #(8) uart_tx_data_reg
        (clk, resetn, uart_tx_data_in, uart_tx_data_en, uart_tx_data_out);
    
    // UART Receiver Data Register
    register #(8) uart_rx_data_reg
        (clk, resetn, uart_rx_data_in, uart_rx_data_en, uart_rx_data_out);
    
    // UART Controller/Status Register
    register #(8) uart_ctrl_status_reg
        (clk, resetn, uart_ctrl_status_in, uart_ctrl_status_en, uart_ctrl_status_out);

endmodule