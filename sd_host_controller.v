module sd_host_controller(ex_clk, ex_resetn, rx_pin, tx_pin, sd_dat_pin, sd_cmd_pin, sd_cd_pin, sd_wp_pin);
    input ex_clk, ex_resetn, rx_pin;
    output tx_pin;
    inout sd_cmd_pin, sd_cd_pin, sd_wp_pin;
    inout [3:0] sd_dat_pin;

    // enables for inout ports
    // sd_xx_pin = input
    // sd_xx_out = output
    wire sd_cmd_we, sd_dat_we, sd_cd_we, sd_wp_we;
    wire sd_cmd_out, sd_cd_out, sd_wp_out;
    wire [3:0] sd_dat_out;
    assign sd_cmd_pin = sd_cmd_we ? 1'bz : sd_cmd_out;
    assign sd_cd_pin  = sd_cd_we  ? 1'bz : sd_cd_out;
    assign sd_wp_pin  = sd_wp_we  ? 1'bz : sd_wp_out;
    assign sd_dat_pin = sd_dat_we ? 4'bz : sd_dat_out;

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
    wire send_en, sd_cmd_sending;
    wire [37:0] send_cmd_content;

    // sd_receive
    wire receive_en, R2_response, crc_response_err, sd_receive_finished;
    wire [126:0] response;

    // clock divider for SD_CLK
    // based on TRAN_SPEED in CSD register
    counter clk_div (
        // inputs
        ex_clk, ~ex_resetn | sd_reset, 
        sd_clk_divider_count,
        // outputs 
        sd_clk
    );

    sd_registers registers (
        // inputs
        ex_clk, ~ex_resetn | sd_reset,                       
        cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en,
        cid_in, csd_in, scr_in, ocr_in, rca_in, drs_in,
        // outputs
        cid_out, csd_out, scr_out, ocr_out, rca_out, drs_out
    );

    sd_send send (
        // inputs
        ex_clk, sd_clk, ~ex_resetn | sd_reset,
        send_en, send_cmd_content,
        // outputs
        sd_cmd_out, sd_cmd_sending, sd_dat_out
    );

    sd_receive receive (
        // inputs
        ex_clk, sd_clk, ~ex_resetn | sd_reset,
        receive_en, R2_response, sd_cmd_pin, 
        // outputs
        response, crc_response_err, sd_receive_finished
    );

    sd_fsm fsm (
        // inputs
        ex_clk, ~ex_resetn, software_reset,
        uart_cmd_en, crc_response_err, sd_receive_finished, sd_cmd_sending,
        cid_out, csd_out, response, 
        scr_out, 
        ocr_out,
        rca_out, drs_out,
        uart_cmd,
        // outputs
        sd_reset, cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en, send_en,
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
        // inputs
        ex_clk, ~ex_resetn,
        rx_pin, sd_tx_en, 
        sd_tx_data, 
        // outputs
        tx_pin, software_reset, uart_cmd_en,
        uart_cmd
    );

endmodule
