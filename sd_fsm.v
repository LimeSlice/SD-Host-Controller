module sd_fsm (
    input ex_clk, sd_clk, reset, software_reset, sd_cd_pin, sd_wp_pin,
    input uart_cmd_en, crc_response_err, sd_receive_finished, sd_receive_started,
    input sd_sending, sd_send_finished, clk_div_cnt_gen_ok, clk_div_cnt_gen_err,
    input [127:0] cid_out, csd_out, 
    input [126:0] response, 
    input [63:0]  scr_out, receive_status_out,
    input [31:0]  ocr_out,
    input [15:0]  rca_out, dsr_out,
    input [5:0]   uart_cmd,
    input [3:0]   host_cmd,
    output reg sd_reset, cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en, send_en,
    output reg sd_tx_en, receive_en, 
    output reg R2_response, R3_response, received_error, receive_status_en, 
    output reg clk_div_cnt_gen_start, host_reset_clear,
    output reg [127:0] cid_in, csd_in,
    output reg [63:0]  scr_in, receive_status_in,
    output reg [37:0]  send_cmd_content,
    output reg [31:0]  ocr_in,
    output reg [15:0]  rca_in, dsr_in,
    output reg [7:0]   sd_tx_data
);

reg [10:1] PS, NS;
// parameter [4:1] INACTIVE = 4'd0, IDLE = 4'd1, READY = 4'd2,
//                 IDENTIFICATION = 4'd3, STANDBY = 4'd4, TRANSFER = 4'd5, 
//                 SENDING = 4'd6, RECEIVING = 4'd7, PROGRAMMING = 4'd8, 
//                 DISCONNECT = 4'd9;

// Thinking the receive states (at least in data transfer mode) 
// should be apart of the next "state"
// **********************************************************************
parameter [10:1] INACTIVE = {4'd9,6'd0}, ERROR = {4'd9,6'd1}, 
                 IDENT_MODE__CMD0_SEND = {4'd9,6'd2}, IDENT_MODE__CMD0_WAIT = {4'd9,6'd3},
                 TRANS_MODE__CMD0_SEND = {4'd9,6'd4}, TRANS_MODE__CMD0_WAIT = {4'd9,6'd5}, 
                 IDENT_MODE__CLK_ADJ = {4'd9,6'd6}, TRANS_MODE__CLK_ADJ = {4'd9,6'd7},
                 IDLE__CMD55_SEND = {4'd0,6'd0}, IDLE__CMD55_RECEIVE = {4'd0,6'd1}, 
                 IDLE__ACMD41_SEND = {4'd0,6'd2}, IDLE__ACMD41_RECEIVE = {4'd0,6'd3},
                 IDLE__CMD55_WAIT = {4'd0,6'd4}, IDLE__ACMD41_WAIT = {4'd0,6'd5},
                 IDLE__CMD55_PROC = {4'd0,6'd6}, IDLE__ACMD41_PROC = {4'd0,6'd7},
                 READY__CMD2_SEND = {4'd1,6'd1}, READY__CMD2_RECEIVE = {4'd1,6'd2},
                 IDENTIFICATION__CMD3_SEND = {4'd2,6'd1}, IDENTIFICATION__CMD3_RECEIVE = {4'd2,6'd2},
                 STANDBY = {4'd3, 6'd0};

parameter [6:1] CMD0   = 6'd0,   // GO_IDLE_STATE
                CMD2   = 6'd2,   // ALL_SEND_CID
                CMD3   = 6'd3,   // SEND_RELATIVE_ADDR
                CMD4   = 6'd4,   // SET_DSR
                CMD6   = 6'd6,   // SWITCH_FUNC
                CMD7   = 6'd7,   // SELECT/DESELECT CARD
                CMD9   = 6'd9,   // SEND_CSD
                CMD10  = 6'd10,  // SEND_CID
                CMD12  = 6'd12,  // STOP_TRANSMISSION
                CMD13  = 6'd13,  // SEND_STATUS
                CMD15  = 6'd15,  // GO_INACTIVE_STATE
                CMD16  = 6'd16,  // SET_BLOCKLEN
                CMD17  = 6'd17,  // READ_SINGLE_BLOCK
                CMD18  = 6'd18,  // READ_MULTIPLE_BLOCK
                CMD24  = 6'd24,  // WRITE_BLOCK
                CMD25  = 6'd25,  // WRITE_MULTIPLE_BLOCK
                CMD27  = 6'd27,  // PROGRAM_CSD
                CMD28  = 6'd28,  // SET_WRITE_PROT
                CMD29  = 6'd29,  // CLR_WRITE_PROT
                CMD30  = 6'd30,  // SEND_WRITE_PROT
                CMD32  = 6'd32,  // ERASE_WR_BLK_START
                CMD33  = 6'd33,  // ERASE_WR_BLK_END
                CMD38  = 6'd38,  // ERASE
                CMD42  = 6'd42,  // LOCK_UNLOCK
                CMD55  = 6'd55,  // APP_CMD
                CMD56  = 6'd56;  // GEN_CMD
                
parameter [6:1] ACMD6  = 6'd6,  // SET_BUS_WIDTH
                ACMD13 = 6'd13,  // SD_STATUS
                ACMD22 = 6'd22,  // SEND_NUM_WR_BLOCKS
                ACMD23 = 6'd23,  // SET_WR_BLK_ERASE_COUNT
                ACMD41 = 6'd41, // SD_SEND_OP_COND
                ACMD42 = 6'd42, // SET_CLK_CARD_DETECT
                ACMD51 = 6'd51; // SEND_SCR

reg  [5:0] timeout_counter_in, clock_counter_in;
wire [5:0] timeout_counter_out, clock_counter_out;
// timeout clock cycle counter
dflipflop #(6) timout_counter (sd_clk, reset, timeout_counter_in, timeout_counter_out);
// clock cycle counter for sending / receiving data
dflipflop #(6) clock_counter (sd_clk, reset, clock_counter_in, clock_counter_out);

always @(posedge ex_clk, posedge reset) begin
    if (reset)  PS <= TRANS_MODE__CLK_ADJ;
    else        PS <= NS;
end

always @(PS, software_reset, uart_cmd_en, crc_response_err, sd_receive_finished, 
			sd_sending, sd_send_finished, sd_receive_started, 
            clk_div_cnt_gen_ok, clk_div_cnt_gen_err, 
			cid_out, csd_out, response, scr_out, receive_status_out, ocr_out,
			rca_out, dsr_out, uart_cmd, host_cmd, sd_cd_pin, sd_wp_pin, 
			clock_counter_out, timeout_counter_out) 
begin
	{	sd_reset, cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en, send_en,
		sd_tx_en, receive_en, 
		R2_response, R3_response, received_error, receive_status_en, 
		clk_div_cnt_gen_start, host_reset_clear,
		cid_in, csd_in,
		scr_in, receive_status_in,
		send_cmd_content,
		ocr_in,
		rca_in, dsr_in,
		sd_tx_data,
		timeout_counter_in, clock_counter_in
	  } = 0;

    case (PS) 

        INACTIVE: NS = INACTIVE;

        // send error message -- UART
        // once done (for future), NS = {receive_status_out[12:9],6'd0}
        ERROR: begin
            NS = INACTIVE;
        end

        IDENT_MODE__CMD0_SEND: begin
            // send CMD0 -- [37:32] command index, [31:0] stuff bits
            send_cmd_content = {CMD0, 32'h0};
            send_en = 1'b1;

            NS = IDENT_MODE__CMD0_WAIT;
        end

        IDENT_MODE__CMD0_WAIT: begin

            // wait 8 clock cycles before send next command
            if (clock_counter_out == 6'd8) begin
                NS = IDLE__CMD55_SEND;
            end
            else begin
                clock_counter_in = clock_counter_out + 1'b1;
                NS = IDENT_MODE__CMD0_WAIT;
            end
        end

        TRANS_MODE__CMD0_SEND: begin
            // send CMD0 -- [37:32] command index, [31:0] stuff bits
            send_cmd_content = {CMD0, 32'h0};
            send_en = 1'b1;

            // adjust tran_speed in local CSD to adjust clock to 400KHz
            csd_in[103:96] = 8'b0_1001_000;
            csd_en = 1'b1;
            clk_div_cnt_gen_start = 1'b1;

            NS = TRANS_MODE__CLK_ADJ;
        end

        IDENT_MODE__CLK_ADJ: begin
            clk_div_cnt_gen_start = 1'b1;
            if (clk_div_cnt_gen_ok) NS = STANDBY;
            else if (clk_div_cnt_gen_err) NS = ERROR;
            else NS = IDENT_MODE__CLK_ADJ;
        end

        TRANS_MODE__CLK_ADJ: begin
            clk_div_cnt_gen_start = 1'b1;
            if (clk_div_cnt_gen_ok && sd_cd_pin) NS = IDLE__CMD55_SEND;
            else if (clk_div_cnt_gen_err) NS = ERROR;
            else NS = TRANS_MODE__CLK_ADJ;
        end

        IDLE__CMD55_SEND: begin
            // check for software reset
            if (software_reset) begin
                host_reset_clear = 1'b1;
                NS = IDENT_MODE__CMD0_SEND;
            end
            
            else if (sd_sending) begin
                NS = IDLE__CMD55_WAIT;
            end

            else begin
                // send CMD55 -- [37:32] command index, [31:16] RCA, [15:0] stuff bits
                send_cmd_content = {CMD55, 16'h0000, 16'b0};
                send_en = 1'b1;
                NS = IDLE__CMD55_SEND;
            end
                        
            // initialized with default default card address -- RCA=0x0000
            rca_in = 16'h0000;
            rca_en  = 1'b1;
            
            // default DSR w/ lowest speed, highest driving current capability            
            dsr_in = 16'h0404;
            dsr_en  = 1'b1; 
        end

        IDLE__CMD55_WAIT: begin
            if (sd_send_finished) begin
                receive_en = 1'b1;
                NS = IDLE__CMD55_RECEIVE;
            end
            else begin
                NS = IDLE__CMD55_WAIT;
            end
        end

        IDLE__CMD55_RECEIVE: begin
            // received response
            if (sd_receive_finished) begin
                
                // crc error in response
                if (crc_response_err) begin
                    // if error -> go to ERROR (temporary, need to update)
                    NS = ERROR;
                end
                
                // valid response
                else begin
                    NS = IDLE__CMD55_PROC;
                end
            end

            // not finished receiving response
            else begin
                // received response
                if (sd_receive_started) begin
                    timeout_counter_in = 6'd0;
                    NS = IDLE__CMD55_RECEIVE;
                end
                // timeout occurred in receiving response
                else if (timeout_counter_out == 6'd5) begin
                    NS = ERROR;
                end 
                else begin
                    timeout_counter_in = timeout_counter_out + 1'b1;
                    NS = IDLE__CMD55_RECEIVE;
                end
            end
        end

        IDLE__CMD55_PROC: begin
            // load register
            if (clock_counter_out == 6'd0) begin
                receive_status_in[37:0] = response[125:87];
                receive_status_en = 1'b1;
                clock_counter_in = 6'd1; // increment clock cycle once
                NS = IDLE__CMD55_PROC;
            end
            
            // cmd line not responding to CMD55 
            else if (receive_status_out[37:32] != CMD55) begin
                // go to ERROR (temporary, need to update)
                NS = ERROR;
            end

            // check status field
            else if ({receive_status_out[27:9],
                        receive_status_out[5]} & ~19'b0 > 19'b0) begin
                // if error -> go to ERROR (temporary, need to update)
                NS = ERROR;
            end

            // no errors -- wait 8 clock cycles before send next command
            else if (clock_counter_out == 6'd8) begin
                NS = IDLE__ACMD41_SEND;
            end
            
            // clock_counter 1-7 -- delay before next send 
            else begin
                clock_counter_in = clock_counter_out + 1'b1;
                NS = IDLE__CMD55_PROC;
            end
        end

        IDLE__ACMD41_SEND: begin
            if (sd_sending) begin
                NS = IDLE__ACMD41_WAIT;
            end
            // send ACMD41 -- OCR w/o busy bit
            else begin
                send_cmd_content = {1'b0, ocr_out[30:0]};
                send_en = 1'b1;
                NS = IDLE__ACMD41_SEND; 
            end
        end

        IDLE__ACMD41_WAIT: begin
            if (sd_send_finished) begin
                receive_en = 1'b1;
                NS = IDLE__ACMD41_RECEIVE;
            end
            else begin
                NS = IDLE__ACMD41_WAIT;
            end
        end

        IDLE__ACMD41_RECEIVE: begin

            R3_response = 1'b1;

            // received response
            if (sd_receive_finished) begin
                
                // no crc -- no crc_response_err
                NS = IDLE__ACMD41_PROC;
                
            end

            // not finished receiving response
            else begin
                // received response
                if (sd_receive_started) begin
                    timeout_counter_in = 6'd0;
                    NS = IDLE__ACMD41_RECEIVE;
                end
                // timeout occurred in receiving response
                else if (timeout_counter_out == 6'd5) begin
                    NS = ERROR;
                end 
                else begin
                    timeout_counter_in = timeout_counter_out + 1'b1;
                    NS = IDLE__ACMD41_RECEIVE;
                end
            end
        end

        IDLE__ACMD41_PROC: begin
            // wait 8 clock cycles before send next command
            if (clock_counter_out == 6'd8) begin
                NS = READY__CMD2_SEND;
            end
            // initial checks
            else if (clock_counter_out == 6'd0) begin
                // check OCR reg
                // OCR[31] -- card is busy
                if (response[118]) begin
                    NS = IDLE__CMD55_SEND;
                end
                // check SD voltage range to check compatibility
                else if (response[108:107] & 2'b11 == 2'b0) begin
                    NS = INACTIVE;
                end
                // load receive_status reg
                else begin
                    receive_status_in = response[124:119];
                    receive_status_en = 1'b1;
                    clock_counter_in = 6'd1;
                    NS = IDLE__ACMD41_PROC;
                end
            end
            // clock_counter 1-7 -- delay before next send
            else begin
                clock_counter_in = clock_counter_out + 1'b1;
                NS = IDLE__ACMD41_PROC;
            end
        end

        READY__CMD2_SEND: begin
            // check for software reset
            if (software_reset) begin
                NS = IDENT_MODE__CMD0_SEND;
            end
            else begin
                // send CMD2 -- [37:32] command index, [31:0] stuff bits
                send_cmd_content = {CMD2, 32'b0};
                send_en = 1'b1;
                NS = READY__CMD2_RECEIVE;
            end
        end

        READY__CMD2_RECEIVE: begin
            
            R2_response = 1'b1;

            // received response
            if (sd_receive_finished) begin
                
                // crc error in response
                if (crc_response_err) begin
                    // if error -> go to ERROR (temporary, need to update)
                    NS = ERROR;
                end
                
                // valid response
                else begin

                    // wait 8 clock cycles before send next command
                    if (clock_counter_out == 6'd8) begin
                        NS = IDENTIFICATION__CMD3_SEND;
                    end

                    // load cid reg
                    else if (clock_counter_out == 6'd0) begin
                        cid_in = response[126:0];
                        cid_en = 1'b1;
                        clock_counter_in = 1'd1;
                        NS = READY__CMD2_RECEIVE;
                    end
                    
                    // clock_counter 1-7 -- delay before next send
                    else begin
                        clock_counter_in = clock_counter_out + 1'b1;
                        NS = READY__CMD2_RECEIVE;
                    end
                end
            end

            // not finished receiving response
            else begin
                // timeout occurred in receiving response
					 if (timeout_counter_out == 6'd5) begin
					     NS = ERROR;
					 end 
					 else begin
					     timeout_counter_in = timeout_counter_out + 1'b1;
						  NS = READY__CMD2_RECEIVE;
					 end
            end
        end

        IDENTIFICATION__CMD3_SEND: begin
            // check for software reset
            if (software_reset) begin
                NS = IDENT_MODE__CMD0_SEND;
            end
            else begin
                // send CMD3 -- [37:32] command index, [31:0] stuff bits
                send_cmd_content = {CMD3, 32'b0};
                send_en = 1'b1;
                NS = IDENTIFICATION__CMD3_RECEIVE;
            end
        end

        IDENTIFICATION__CMD3_RECEIVE: begin
            // received response
            if (sd_receive_finished) begin

                // crc error in response
                if (crc_response_err) begin
                    // if error -> go to ERROR (temporary, need to update)
                    NS = ERROR;
                end
                
                // valid response
                else begin

                    // load data -- R6 response
                    // [124:119] command index
                    // [118:103] new RCA
                    // [102:87]  card status
                    receive_status_in[37:32] = response[124:119];
                    {receive_status_in[23:22],
                     receive_status_in[19],
                     receive_status_in[12:0]} = response[102:87];
                    receive_status_en = 1'b1; 
                    
                    rca_in = response[118:103];
                    rca_en = 1'b1;

                    // check status field bits
                    if (response[102:96] & ~7'b0 > 0) NS = ERROR;
                    else begin
                        // give default value of 25MHz
                        csd_in[103:96] = 8'b0_0110_010;
                        csd_en = 1'b1;
                        clk_div_cnt_gen_start = 1'b1;
                        NS = IDENT_MODE__CLK_ADJ;
                    end
                end
            end

            // not finished receiving response
            else begin
					  // timeout occurred in receiving response
					  if (timeout_counter_out == 6'd5) begin
							NS = ERROR;
					  end 
					  else begin
							timeout_counter_in = timeout_counter_out + 1'b1;
							NS = IDENTIFICATION__CMD3_RECEIVE;
					  end
            end
        end

        STANDBY: begin
            NS = STANDBY;
        end

        default: NS = INACTIVE;
    endcase
end

endmodule
