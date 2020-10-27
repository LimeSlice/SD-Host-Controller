module sd_fsm (
    input ex_clk, reset, software_reset, 
    input uart_cmd_en, crc_response_err, sd_receive_finished,
    input [127:0] cid_out, csd_out, response, 
    input [63:0]  scr_out, 
    input [31:0]  ocr_out,
    input [15:0]  rca_out, drs_out,
    input [5:0]   uart_cmd,
    output reg sd_reset, cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en, send_en,
    output reg sd_cmd_we, sd_dat_we, sd_cd_we, sd_wp_we, sd_tx_en, receive_en, 
    output reg R2_response, 
    output reg [127:0] cid_in, csd_in,
    output reg [63:0]  scr_in, 
    output reg [37:0]  send_cmd_content,
    output reg [31:0]  ocr_in,
    output reg [15:0]  rca_in, drs_in, sd_clk_divider_count,
    output reg [7:0]   sd_tx_data
);

    reg [4:1] PS, NS;
    reg [6:1] IS;
    parameter [4:1] INACTIVE = 4'd0, IDLE = 4'd1, READY = 4'd2, IDENTIFICATION = 4'd3,
                    STANDBY = 4'd4, TRANSFER = 4'd5, SENDING = 4'd6,
                    RECEIVING = 4'd7, PROGRAMMING = 4'd8, DISCONNECT = 4'd9;
    
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

    parameter [3:1] CMD0_SEND = 3'd0, 
                    CMD55_SEND = 3'd1, CMD55_RESPONSE


    always @(posedge clk, posedge reset) begin
        if (reset) PS <= IDLE;
        else PS <= NS
    end

    always @(PS) begin
        {sd_reset, cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en, send_en,
        sd_cmd_we, sd_dat_we, sd_cd_we, sd_wp_we, sd_tx_en, receive_en, 
        R2_response, 
        cid_in, csd_in,
        scr_in, 
        send_cmd_content,
        ocr_in,
        rca_in, drs_in, sd_clk_divider_count,
        sd_tx_data} = 0;
        case (PS) 
            INACTIVE: PS = INACTIVE;
            IDLE: begin
                case (IS)
                    CMD55: begin
                        if (sd_receive_finished) begin
                            if (new_response) begin
                                // process response
                                NS = IDLE;
                                IS = ACMD41;
                                sd_responding = 1'b0;
                            end
                        end
                        else begin
                            
                        end
                    end

                    ACMD41: begin
                        
                    end

                    default: begin
                        
                    end
                endcase
                sd_cmd_we = 1'b1;
                sd_dat_we = 1'b1;
                sd_cd_we = 1'b1;
                sd_wp_we = 1'b1;
                // CMD55
                // ACMD41
                if (/*Wait to receive OCR content as response OR 
                    card is busy or host omitted the voltage range*/)
                    NS = IDLE;
                if (/*non-compatible voltage range*/)
                    NS = INACTIVE;
                else 
                    NS = READY;
                
            end
            READY: begin
                // CMD2
                NS = IDENTIFICATION;
            end
            IDENTIFICATION: begin
                // CMD3
                if (/*Wait for SD responds with new RCA*/)
                    NS = IDENTIFICATION;
                else 
                    NS = STANDBY;
            end
            STANDBY: begin
                // CMD4, 9, 10, 3
                NS = STANDBY;
                // CMD7
                NS = TRANSFER;
            end
            TRANSFER: begin
                // CMD7
                NS = STANDBY;
                // CMD16, 32-37, ACMD6, 23, 42
                NS = TRANSFER;
                // CMD24,25,2627,42,56(w) 
                NS = RECEIVE;
                // CMD6,17,18,30,56(r), ACMD13,22,51
                NS = SENDING;
            end
            SENDING: begin
                // CMD12 or "operation complete"
                NS = TRANSFER;
                // CMD7
                NS = STANDBY;
            end
            RECEIVING: begin
                // CMD12 or "transfer end"
                NS = PROGRAMMING;
            end
            PROGRAMMING: begin
                // "operation complete"
                NS = TRANSFER;
                // CMD7
                NS = DISCONNECT;
            end
            DISCONNECT: begin
                // "operation complete"
                NS = STANDBY;
                // CMD7
                NS = PROGRAMMING;
            end
            default: PS <= INACTIVE;
        endcase
    end



endmodule
