module sd_host_controller (
    input ex_clk, ex_resetn, rx_pin,
	 input sd_cd_pin, sd_wp_pin,
    output tx_pin,
    inout sd_cmd_pin,
    inout [3:0] sd_dat_pin
);

// enables for inout ports
// sd_xx_pin = input
// sd_xx_out = output
wire sd_cmd_we, sd_dat_we, sd_cmd_out;
wire [3:0] sd_dat_out;
assign sd_cmd_pin = sd_cmd_we ? sd_cmd_out : 1'bz;
assign sd_dat_pin = sd_dat_we ? sd_dat_out: 4'bz;

wire sd_clk, sd_reset, software_reset, sd_tx_en, uart_cmd_en, host_reset_clear;
wire received_error;
wire [3:0] host_cmd;
wire [5:0] uart_cmd;
wire [7:0] sd_tx_data;

wire clk_div_cnt_gen_start, clk_div_cnt_gen_ok, clk_div_cnt_gen_err;
wire [15:0] sd_clk_divider_count;

// sd_registers
wire cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en, receive_status_en;
wire [15:0] rca_in, dsr_in, rca_out, dsr_out;
wire [31:0] ocr_in, ocr_out;
wire [63:0] scr_in, scr_out, receive_status_in, receive_status_out;
wire [127:0] cid_in, csd_in, cid_out, csd_out;

// sd_send
wire send_en, sd_sending, sd_finished;
wire [37:0] send_cmd_content;

// sd_receive
wire receive_en, R2_response, R3_response, crc_response_err, sd_receive_finished;
wire sd_receive_started;
wire [126:0] response;

// uart
wire [7:0] uart_rx_data, uart_ctrl;

// clock divider for SD_CLK
// based on TRAN_SPEED in CSD register
counter clk_div (
    // inputs
    ex_clk, ~ex_resetn | sd_reset | clk_div_reset, 
    sd_clk_divider_count,
    // outputs 
    sd_clk
);

clk_div_count_generator clk_div_cnt_gen (
    // inputs
    ex_clk, ~ex_resetn | sd_reset, clk_div_cnt_gen_start,
    csd_out[103:96],
    // outputs
    clk_div_cnt_gen_ok, clk_div_cnt_gen_err, clk_div_reset,
    sd_clk_divider_count
);

sd_registers registers (
    // inputs
    ex_clk, ~ex_resetn,
    cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en, receive_status_en,
    cid_in, csd_in,
    scr_in, receive_status_in, 
    ocr_in,
    rca_in, dsr_in,
    // outputs
    cid_out, csd_out,
    scr_out, receive_status_out, 
    ocr_out,
    rca_out, dsr_out
);

sd_send send (
    // inputs
    ex_clk, sd_clk, ~ex_resetn | sd_reset,
    send_en, send_cmd_content,
    // outputs
    sd_cmd_out, sd_sending,
    sd_cmd_we, sd_dat_we, sd_finished,
    sd_dat_out
);

sd_receive receive (
    // inputs
    ex_clk, sd_clk, ~ex_resetn | sd_reset,
    receive_en, R2_response, R3_response, sd_cmd_pin, 
    // outputs
    response, 
    sd_receive_started,
    crc_response_err, sd_receive_finished
);

sd_fsm fsm (
    // inputs
    ex_clk, sd_clk, ~ex_resetn, software_reset, sd_cd_pin, sd_wp_pin,
    uart_cmd_en, crc_response_err, sd_receive_finished, sd_receive_started,
    sd_sending, sd_finished, clk_div_cnt_gen_ok, clk_div_cnt_gen_err,
    cid_out, csd_out, response, 
    scr_out, receive_status_out,
    ocr_out,
    rca_out, dsr_out,
    uart_cmd,
    host_cmd,
    // outputs
    sd_reset, cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en, send_en,
    sd_tx_en, receive_en, 
    R2_response, R3_response, received_error, receive_status_en, 
    clk_div_cnt_gen_start, host_reset_clear,
    cid_in, csd_in,
    scr_in, receive_status_in,
    send_cmd_content,
    ocr_in,
    rca_in, dsr_in,
    sd_tx_data
);

uart host_uart (
    // inputs
    ex_clk, ~ex_resetn, rx_pin, sd_tx_en,
    sd_tx_data,
    // outputs
    tx_pin,
    uart_rx_data, uart_ctrl
);

// host_uart_ctrl host_uart_controller (
//     // inputs
//     ex_clk, ~ex_resetn,
//     uart_rx_data, uart_ctrl,
//     // outputs
//     host_cmd
// );

endmodule
