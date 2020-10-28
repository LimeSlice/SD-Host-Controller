module sd_fsm (
    input ex_clk, reset, software_reset, 
    input uart_cmd_en, crc_response_err, sd_receive_finished, sd_cmd_sending
    input [127:0] cid_out, csd_out, 
    input [126:0] response, 
    input [63:0]  scr_out, 
    input [31:0]  ocr_out,
    input [15:0]  rca_out, drs_out,
    input [5:0]   uart_cmd,
    output reg sd_reset, cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en, send_en,
    output reg sd_cmd_we, sd_dat_we, sd_cd_we, sd_wp_we, sd_tx_en, receive_en, 
    output reg R2_response, received_error, 
    output reg [127:0] cid_in, csd_in,
    output reg [63:0]  scr_in, 
    output reg [37:0]  send_cmd_content,
    output reg [31:0]  ocr_in,
    output reg [15:0]  rca_in, drs_in, sd_clk_divider_count,
    output reg [7:0]   sd_tx_data
);

// split response
wire [5:0] response_48bit_command_index;
wire [31:0] response_48bit_card_status
assign {response_48bit_command_index, response_48bit_card_status} = response[125:88]

reg [7:1] PS, NS;
// parameter [4:1] INACTIVE = 4'd0, IDLE = 4'd1, READY = 4'd2,
//                 IDENTIFICATION = 4'd3, STANDBY = 4'd4, TRANSFER = 4'd5, 
//                 SENDING = 4'd6, RECEIVING = 4'd7, PROGRAMMING = 4'd8, 
//                 DISCONNECT = 4'd9;

// Thinking the receive states (at least in data transfer mode) 
// should be apart of the next "state"
// **********************************************************************
parameter [10:1] INACTIVE = {4'd9,6'd0}, ERROR = {4'd9,6'd1},
                 IDLE__CMD55_SEND = {4'd0,6'd0}, IDLE__CMD55_RECEIVE = {4'd0,6'd1},
                 IDLE__ACMD41_SEND = {4'd0,6'd2}, IDLE__ACMD41_RECEIVE = {4'd0,6'd3},
                 READY__CMD0_SEND = {4'd1,6'd0}, 
                 READY__CMD2_SEND = {4'd1,6'd1}, READY__CMD2_RECEIVE = {4'd1,6'd2},
                 IDENTIFICATION__CMD0_SEND = {4'd2,6'd0}, 
                 IDENTIFICATION__CMD3_SEND = {4'd2,6'd1}, IDENTIFICATION__CMD3_RECEIVE = {4'd2,6'd2},
                 STANDBY__CMD0_SEND = {4'd3,6'd0}, 
                 STANDBY__CMD3_SEND = {4'd3,6'd1}, STANDBY__CMD3_RECEIVE = {4'd3,6'd2},
                 STANDBY__CMD4_SEND = {4'd3,6'd3}, STANDBY__CMD4_RECEIVE = {4'd3,6'd4},
                 STANDBY__CMD7_SEND = {4'd3,6'd5}, STANDBY__CMD7_RECEIVE = {4'd3,6'd6},
                 STANDBY__CMD9_SEND = {4'd3,6'd7}, STANDBY__CMD9_RECEIVE = {4'd3,6'd8},
                 STANDBY__CMD10_SEND = {4'd3,6'd9}, STANDBY__CMD10_RECEIVE = {4'd3,6'd10};
// TRANSFER__CMD0_SEND
// TRANSFER__CMD6_SEND
// TRANSFER__CMD6_RECEIVE
// TRANSFER__CMD7_SEND
// TRANSFER__CMD7_RECEIVE
// TRANSFER__CMD15_SEND
// TRANSFER__CMD16_SEND
// TRANSFER__CMD16_RECEIVE
// TRANSFER__CMD24_SEND
// TRANSFER__CMD24_RECEIVE
// TRANSFER__CMD25_SEND
// TRANSFER__CMD25_RECEIVE
// TRANSFER__CMD26_SEND
// TRANSFER__CMD26_RECEIVE
// TRANSFER__CMD27_SEND
// TRANSFER__CMD27_RECEIVE
// TRANSFER__CMD32_SEND
// TRANSFER__CMD32_RECEIVE
// TRANSFER__CMD33_SEND
// TRANSFER__CMD33_RECEIVE
// TRANSFER__CMD34_SEND
// TRANSFER__CMD34_RECEIVE
// TRANSFER__CMD35_SEND
// TRANSFER__CMD35_RECEIVE
// TRANSFER__CMD36_SEND
// TRANSFER__CMD36_RECEIVE
// TRANSFER__CMD37_SEND
// TRANSFER__CMD37_RECEIVE
// TRANSFER__CMD42_SEND
// TRANSFER__CMD42_RECEIVE
// TRANSFER__CMD55_SEND
// TRANSFER__CMD55_RECEIVE
// TRANSFER__CMD56_SEND
// TRANSFER__CMD56_RECEIVE
// TRANSFER__ACMD6_SEND
// TRANSFER__ACMD6_RECEIVE
// TRANSFER__ACMD13_SEND
// TRANSFER__ACMD13_RECEIVE
// TRANSFER__ACMD22_SEND
// TRANSFER__ACMD22_RECEIVE
// TRANSFER__ACMD23_SEND
// TRANSFER__ACMD23_RECEIVE
// TRANSFER__ACMD42_SEND
// TRANSFER__ACMD42_RECEIVE
// TRANSFER__ACMD51_SEND
// TRANSFER__ACMD51_RECEIVE
// SENDING__CMD0_SEND
// SENDING__CMD7_SEND
// SENDING__CMD7_RECEIVE
// SENDING__CMD12_SEND
// SENDING__CMD12_RECEIVE
// SENDING__CMD15_SEND
// RECEIVING__CMD0_SEND
// RECEIVING__CMD12_SEND
// RECEIVING__CMD12_RECEIVE
// RECEIVING__CMD15_SEND
// PROGRAMMING__CMD0_SEND
// PROGRAMMING__CMD7_SEND
// PROGRAMMING__CMD7_RECEIVE
// PROGRAMMING__CMD15_SEND
// DISCONNECT__CMD0_SEND
// DISCONNECT__CMD7_SEND
// DISCONNECT__CMD7_RECEIVE
// DISCONNECT__CMD15_SEND

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
                CMD56  = 6'd56,  // GEN_CMD
                
parameter [6:1] ACMD6  = 6'd6,  // SET_BUS_WIDTH
                ACMD13 = 6'd13,  // SD_STATUS
                ACMD22 = 6'd22,  // SEND_NUM_WR_BLOCKS
                ACMD23 = 6'd23,  // SET_WR_BLK_ERASE_COUNT
                ACMD41 = 6'd41, // SD_SEND_OP_COND
                ACMD42 = 6'd42, // SET_CLK_CARD_DETECT
                ACMD51 = 6'd51; // SEND_SCR

always @(posedge clk, posedge reset) begin
    if (reset) PS <= IDLE;
    else PS <= NS
end

always @(PS) begin
    {sd_reset, cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en, send_en,
    sd_cmd_we, sd_dat_we, sd_cd_we, sd_wp_we, sd_tx_en, receive_en, 
    R2_response, received_error,
    cid_in, csd_in,
    scr_in, 
    send_cmd_content,
    ocr_in,
    rca_in, drs_in, sd_clk_divider_count,
    sd_tx_data} = 0;

    case (PS) 

        INACTIVE: NS = INACTIVE;

        // send error message -- UART
        // once done (for future), NS = {card_status_reg_out[12:9],6'd0}
        ERROR: begin
            NS = INACTIVE;
        end

        IDLE__CMD55_SEND: begin
            // SD_CLK = 400KHz for all of card-identfication-mode
            // 50M / 400K = 125
            sd_clk_divider_counter = 16'd125;

            // CMD line in input mode
            sd_cmd_we = 1'b1;
            
            // send CMD55 -- [37:32] command index, [31:16] RCA, [15:0] stuff bits
            send_cmd_content = {CMD55, 16'h0000, 16'b0};
            send_en = 1'b1;
            
            // initialized with default default card address -- RCA=0x0000
            rca_in = 16'h0000;
            rca_en  = 1'b1;
            
            // default DSR w/ lowest speed, highest driving current capability            
            dsr_in = 16'h0404;
            dsr_en  = 1'b1;
            
            NS = IDLE__CMD55_RECEIVE;
        end

        IDLE__CMD55_RECEIVE: begin
            // SD_CLK = 400KHz for all of card-identfication-mode
            // 50M / 400K = 125
            sd_clk_divider_counter = 16'd125;

            // received response
            if (sd_receive_finished) begin
                
                // crc error in response
                if (crc_response_err) begin
                    // if error -> go to ERROR (temporary, need to update)
                    NS = ERROR;
                end
                
                // valid response
                else begin
                    
                    // cmd line not responding to CMD55 
                    if (response_48bit_command_index != CMD55) begin
                        // go to ERROR (temporary, need to update)
                        NS = ERROR;
                    end

                    // check status field
                    else if ({response_48bit_card_status[27:9],
                              response_48bit_card_status[5]} == ~19'b0) begin
                        received_error = 1'b1;
                        // if error -> go to ERROR (temporary, need to update)
                        NS = ERROR;
                    end

                    // no errors
                    else begin
                        NS = IDLE__ACMD41_SEND;
                    end
                    
                    card_status_reg_in = response_48bit_card_status;
                    card_status_reg_en = 1'b1;
                end
            end

            // not finished receiving response
            else begin
                NS = IDLE__CMD55_RECEIVE;
            end
        end

        IDLE__ACMD41_SEND: begin
            // SD_CLK = 400KHz for all of card-identfication-mode
            // 50M / 400K = 125
            sd_clk_divider_counter = 16'd125;
            
             // CMD line in input mode
            sd_cmd_we = 1'b1;

            // send ACMD41 -- OCR w/o busy bit
            send_cmd_content = {1'b0, ocr_out[30:0]};
            send_en = 1'b1;

            NS = IDLE__ACMD41_RECEIVE;
        end

        IDLE__ACMD41_RECEIVE: begin
            // SD_CLK = 400KHz for all of card-identfication-mode
            // 50M / 400K = 125
            sd_clk_divider_counter = 16'd125;
            
            // received response
            if (sd_receive_finished) begin
                
                // crc error in response
                if (crc_response_err) begin
                    // if error -> go to ERROR (temporary, need to update)
                    NS = ERROR;
                end
                
                // valid response
                else begin
                    

                    // check status field
                    if ({response_48bit_card_status[27:9],
                              response_48bit_card_status[5]} == ~19'b0) begin
                        received_error = 1'b1;
                        // if error -> go to ERROR (temporary, need to update)
                        NS = ERROR;
                    end

                    // no errors
                    else begin
                        NS = IDLE__ACMD41_SEND;
                    end
                    
                    ocr_in = response_48bit_card_status;
                    ocr_en = 1'b1;
                end
            end

            // not finished receiving response
            else begin
                NS = IDLE__CMD55_RECEIVE;
            end
        end

            




        READY: begin

        // READY__CMD0_SEND
        // READY__CMD2_SEND
        // READY__CMD2_RECEIVE

            // CMD2
            NS = IDENTIFICATION;
        end
        IDENTIFICATION: begin

        // IDENTIFICATION__CMD0_SEND
        // IDENTIFICATION__CMD3_SEND
        // IDENTIFICATION__CMD3_RECEIVE

            // CMD3
            if (/*Wait for SD responds with new RCA*/)
                NS = IDENTIFICATION;
            else 
                NS = STANDBY;
        end
        STANDBY: begin

        // STANDBY__CMD0_SEND
        // STANDBY__CMD3_SEND
        // STANDBY__CMD3_RECEIVE
        // STANDBY__CMD4_SEND
        // STANDBY__CMD4_RECEIVE
        // STANDBY__CMD7_SEND
        // STANDBY__CMD7_RECEIVE
        // STANDBY__CMD9_SEND
        // STANDBY__CMD9_RECEIVE
        // STANDBY__CMD10_SEND
        // STANDBY__CMD10_RECEIVE
        // STANDBY__CMD15_SEND

            // CMD4, 9, 10, 3
            NS = STANDBY;
            // CMD7
            NS = TRANSFER;
        end
        TRANSFER: begin
        
        // TRANSFER__CMD0_SEND
        // TRANSFER__CMD6_SEND
        // TRANSFER__CMD6_RECEIVE
        // TRANSFER__CMD7_SEND
        // TRANSFER__CMD7_RECEIVE

        // TRANSFER__CMD15_SEND
        // TRANSFER__CMD16_SEND
        // TRANSFER__CMD16_RECEIVE

        // TRANSFER__CMD24_SEND
        // TRANSFER__CMD24_RECEIVE
        // TRANSFER__CMD25_SEND
        // TRANSFER__CMD25_RECEIVE
        // TRANSFER__CMD26_SEND
        // TRANSFER__CMD26_RECEIVE
        // TRANSFER__CMD27_SEND
        // TRANSFER__CMD27_RECEIVE
        
        // TRANSFER__CMD32_SEND
        // TRANSFER__CMD32_RECEIVE
        // TRANSFER__CMD33_SEND
        // TRANSFER__CMD33_RECEIVE
        // TRANSFER__CMD34_SEND
        // TRANSFER__CMD34_RECEIVE
        // TRANSFER__CMD35_SEND
        // TRANSFER__CMD35_RECEIVE
        // TRANSFER__CMD36_SEND
        // TRANSFER__CMD36_RECEIVE
        // TRANSFER__CMD37_SEND
        // TRANSFER__CMD37_RECEIVE

        // TRANSFER__CMD42_SEND
        // TRANSFER__CMD42_RECEIVE

        // TRANSFER__CMD55_SEND
        // TRANSFER__CMD55_RECEIVE
        // TRANSFER__CMD56_SEND
        // TRANSFER__CMD56_RECEIVE
        
        // TRANSFER__ACMD6_SEND
        // TRANSFER__ACMD6_RECEIVE
        // TRANSFER__ACMD13_SEND
        // TRANSFER__ACMD13_RECEIVE
        // TRANSFER__ACMD22_SEND
        // TRANSFER__ACMD22_RECEIVE
        // TRANSFER__ACMD23_SEND
        // TRANSFER__ACMD23_RECEIVE
        // TRANSFER__ACMD42_SEND
        // TRANSFER__ACMD42_RECEIVE
        // TRANSFER__ACMD51_SEND
        // TRANSFER__ACMD51_RECEIVE

            // CMD7
            NS = STANDBY;
            // CMD16, 32-37, ACMD6, 23, 42
            NS = TRANSFER;
            // CMD24,25,26,27,42,56(w) 
            NS = RECEIVE;
            // CMD6,17,18,30,56(r), ACMD13,22,51
            NS = SENDING;
        end
        SENDING: begin
        
        // SENDING__CMD0_SEND
        // SENDING__CMD7_SEND
        // SENDING__CMD7_RECEIVE
        // SENDING__CMD12_SEND
        // SENDING__CMD12_RECEIVE
        // SENDING__CMD15_SEND

            // CMD12 or "operation complete"
            NS = TRANSFER;
            // CMD7
            NS = STANDBY;
        end
        RECEIVING: begin

        // RECEIVING__CMD0_SEND
        // RECEIVING__CMD12_SEND
        // RECEIVING__CMD12_RECEIVE
        // RECEIVING__CMD15_SEND

            // CMD12 or "transfer end"
            NS = PROGRAMMING;
        end
        PROGRAMMING: begin

        // PROGRAMMING__CMD0_SEND
        // PROGRAMMING__CMD7_SEND
        // PROGRAMMING__CMD7_RECEIVE
        // PROGRAMMING__CMD15_SEND

            // "operation complete"
            NS = TRANSFER;
            // CMD7
            NS = DISCONNECT;
        end
        DISCONNECT: begin

        // DISCONNECT__CMD0_SEND
        // DISCONNECT__CMD7_SEND
        // DISCONNECT__CMD7_RECEIVE
        // DISCONNECT__CMD15_SEND
        
            // "operation complete"
            NS = STANDBY;
            // CMD7
            NS = PROGRAMMING;
        end
        default: PS <= INACTIVE;
    endcase
end

endmodule
