module sd_host_controller (
    input ex_clk, ex_resetn,
	input sd_cd_pin,
    input sd_cmd_in,
    output sd_cmd_out
);

wire sd_clk, sd_reset, software_reset, clk_div_reset, sd_tx_en, uart_cmd_en;
wire received_error, host_reset_clear;
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
wire sd_receive_started, crc_loaded;
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
    cid_en, rca_en, csd_en, ocr_en, dsr_en, receive_status_en,
    cid_in, csd_in,
    receive_status_in, 
    ocr_in,
    rca_in, dsr_in,
    // outputs
    receive_status_out, 
    ocr_out,
    rca_out
);

sd_send send (
    // inputs
    ex_clk, sd_clk, ~ex_resetn | sd_reset,
    send_en, send_cmd_content,
    // outputs
    sd_cmd_out, sd_sending,
    sd_finished
);

sd_receive receive (
    // inputs
    ex_clk, sd_clk, ~ex_resetn | sd_reset,
    receive_en, R2_response, R3_response, sd_cmd_in, 
    // outputs
    response, 
    sd_receive_started, crc_loaded,
    crc_response_err, sd_receive_finished
);

sd_fsm fsm (
    // inputs
    ex_clk, sd_clk, ~ex_resetn, sd_cd_pin,
    crc_response_err, sd_receive_finished, sd_receive_started,
    sd_sending, sd_finished, clk_div_cnt_gen_ok, clk_div_cnt_gen_err, 
    crc_loaded,
    response, 
    receive_status_out,
    ocr_out,
    rca_out,
    // outputs
    cid_en, rca_en, csd_en, dsr_en, send_en,
    receive_en, 
    R2_response, R3_response, receive_status_en, 
    clk_div_cnt_gen_start,
    cid_in, csd_in,
    receive_status_in,
    send_cmd_content,
    rca_in, dsr_in
);

endmodule
