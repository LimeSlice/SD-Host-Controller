module regbank(
    input clk, ex_resetn, sys_addr_en, blk_size_en, blk_cnt_en, arg_en, 
          tran_mode_en, cmd_en, resp0_en, resp1_en, resp2_en, resp3_en, 
          buff_data_port_en, ps_en, blk_gap_ctrl_en, wake_ctrl_en, clk_ctrl_en, 
          timeout_ctrl_en, soft_rst_en, norm_int_status_en, err_int_status_en, 
          norm_int_status_en_en, err_int_status_en_en, norm_int_sig_en_en, 
          err_int_sig_en_en, auto_cmd12_err_en, hst_ctrl_ver_en,
    
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
                    soft_rst_in, auto_cmd12_err_in;
    output [7:0]    tran_mode_out, blk_gap_ctrl_out, wake_ctrl_out, 
                    timeout_ctrl_out, soft_rst_out, auto_cmd12_err_out
);
    
    // System Address Register (RW)
    // Contains system memory address for DMA transfer
    register #(32) r0 (
        .clock(clk),
        .resetn(resetn),
        .d(sys_addr_in),
        .en(sys_addr_en),
        .q(sys_addr_out)
    );

    // Block Size Register (RW)
    // Used to configure number of bytes in a data block
    register #(16) r1 (clk, resetn, blk_size_in, blk_size_en, blk_size_out);

    // Block Counter Register (RW)
    // Used to configure number of data blocks
    register #(16) r2 (clk, resetn, blk_cnt_in, blk_cnt_en, blk_cnt_out);

    // Argument Register (RW)
    // SD Command Argument
    register #(32) r3 (clk, resetn, arg_in, arg_en, arg_out);

    // Transfer Mode Register (RW)
    // Control Operation of data transfers
    register #(32) r4 (clk, resetn, tran_mode_in, tran_mode_en, tran_mode_out);

    // Command Register (RW)
    // Controls for Host to trigger SD command generation
    register #(16) r5 (clk, resetn, cmd_in, cmd_en, cmd_out);

    // Response Registers (ROC)
    // Stores responses from SD card
    // 31..0
    register #(32) r6 (clk, resetn, resp0_in, resp0_en, resp0_out);
    // 63..32
    register #(32) r7 (clk, resetn, resp1_in, resp1_en, resp1_out);
    // 95..64
    register #(32) r8 (clk, resetn, resp2_in, resp2_en, resp2_out);
    // 127..96
    register #(32) r9 (clk, resetn, resp3_in, resp3_en, resp3_out);

    // Buffer Data Port Register (RW)
    // 32-bit data port register to access internal buffer
    register #(32) r10 (clk, resetn, buff_data_port_in, buff_data_port_en, buff_data_port_out);

    // Present State Register (RO)
    // Status of Host Controller
    register #(32) r11 (clk, resetn, ps_in, ps_en, ps_out);

    // Block Gap Control Register (RW, RWAC)
    // Controls for reading, writing, requesting, etc
    register #(8) r12 (clk, resetn, blk_gap_ctrl_in, blk_gap_ctrl_en, blk_gap_ctrl_out);

    // Wakeup Control Register (RW)
    // Wakeup functionality to begin IC power and clock cycle
    register #(8) r13 (clk, resetn, wake_ctrl_in, wake_ctrl_en, wake_ctrl_out);

    // Clock Control Register (RW, ROC)
    // Clock Control
    // Internal Clock Stable (bit 1) is ROC
    register #(16) r14 (clk, resetn, clk_ctrl_in, clk_ctrl_en, clk_ctrl_out);

    // Timeout Control Register (RW)
    // Timeout counter value according to the capabilities register
    register #(8) r15 (clk, resetn, timeout_ctrl_in, timeout_ctrl_en, timeout_ctrl_out);

    // Software Reset Register (RWAC)
    register #(8) r16 (clk, resetn, soft_rst_in, soft_rst_en, soft_rst_out);

    // Normal Interrupt Status Register (ROC, RW1C)
    register #(16) r17 (clk, resetn, norm_int_status_in, norm_int_status_en, norm_int_status_out);

    // Error Interrupt Status Register (RW1C)
    register #(16) r18 (clk, resetn, err_int_status_in, err_int_status_en, err_int_status_out);

    // Normal Interrupt Status Enable Register (RW)
    register #(16) r19 (clk, resetn, norm_int_status_en_in, norm_int_status_en_en, norm_int_status_en_out);

    // Error Interrupt Status Enable Register (RW)
    register #(16) r20 (clk, resetn, err_int_status_en_in, err_int_status_en_en, err_int_status_en_out);

    // Normal Interrupt Signal Enable Register (RW)
    register #(16) r21 (clk, resetn, norm_int_sig_en_in, norm_int_sig_en_en, norm_int_sig_en_out);

    // Error Interrupt Signal Enable Register (RW)
    register #(16) r22 (clk, resetn, err_int_sig_en_in, err_int_sig_en_en, err_int_sig_en_out);

    // Auto CMD12 Error Status Register
    register #(16) r23 (clk, resetn, auto_cmd12_err_in, auto_cmd12_err_en, auto_cmd12_err_out);

    // Host Controller Version Register
    register #(16) r25 (clk, resetn, hst_ctrl_ver_in, hst_ctrl_ver_en, hst_ctrl_ver_out);

endmodule