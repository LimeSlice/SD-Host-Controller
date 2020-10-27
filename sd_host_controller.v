module sd_host_controller(ex_clk, ex_resetn, rx_pin, tx_pin, sd_dat, sd_cmd, sd_cd, sd_wp);
    input ex_clk, ex_resetn, rx_pin;
    output tx_pin;
    inout sd_cmd, sd_cd, sd_wp;
    inout [3:0] sd_dat;

    // enables for inout ports
    wire sd_cmd_we, sd_dat_we, sd_cd_we, sd_wp_we;
    assign sd_cmd = sd_cmd_we ? 1'bz : send_cmd;
    assign sd_cd  = sd_cd_we  ? 1'bz : send_cd;
    assign sd_wp  = sd_wp_we  ? 1'bz : send_wp;
    assign sd_dat = sd_dat_we ? 4'bz : send_dat;

    wire sd_clk, sd_reset, software_reset, sd_tx_en, uart_cmd_en;
    wire [5:0] uart_cmd;
    wire [7:0] sd_tx_data;
    wire [15:0] sd_clk_divider_count;

    // sd_registers
    wire cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en;
    wire [15:0] rca_in, drs_in, rca_out, drs_out;
    wire [31:0] ocr_in, ocr_out;
    wire [63:0] scr_in, scr_out;
    wire [127:0] cid_in, csd_in, cid_out, csd_out;

    // sd_send
    wire send_en, sending;
    wire [37:0] send_cmd_content;

    // sd_receive
    wire receive_en, R2_response, crc_response_err, sd_receive_finished;
    wire [126:0] response;

    // clock divider for SD_CLK
    // based on TRAN_SPEED in CSD register
    counter clk_div (
        ex_clk, ~ex_resetn | sd_reset, 
        sd_clk_divider_count, 
        sd_clk
    );

    sd_registers registers (
        ex_clk, ~ex_resetn | sd_reset,                       // inputs
        cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en,
        cid_in, csd_in, scr_in, ocr_in, rca_in, drs_in,
        cid_out, csd_out, scr_out, ocr_out, rca_out, drs_out // outputs
    );

    sd_send send (
        ex_clk, sd_clk, ~ex_resetn | sd_reset, // inputs
        send_en, send_cmd_content,
        sd_cmd, sending, sd_dat                // outputs
    );

    sd_receive   receive (
        ex_clk, sd_clk, ~ex_resetn | sd_reset,           // inputs
        receive_en, R2_response, sd_cmd, 
        response, crc_response_err, sd_receive_finished  // outputs
    );

    sd_fsm fsm (
        ex_clk, ~ex_resetn, software_reset,                                 // inputs
        uart_cmd_en, crc_response_err, sd_receive_finished
        cid_out, csd_out, response, 
        scr_out, 
        ocr_out,
        rca_out, drs_out,
        uart_cmd,
        sd_reset, cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en, send_en,  // outputs
        sd_cmd_we, sd_dat_we, sd_cd_we, sd_wp_we, sd_tx_en, receive_en, 
        R2_response, 
        cid_in, csd_in,
        scr_in, 
        send_cmd_content,
        ocr_in,
        rca_in, drs_in, sd_clk_divider_count,
        sd_tx_data
    );

    uart user_comm (
        ex_clk, ~ex_resetn,                  // inputs
        rx_pin, sd_tx_en, 
        sd_tx_data, 
        tx_pin, software_reset, uart_cmd_en, // outputs 
        uart_cmd
    );

endmodule
