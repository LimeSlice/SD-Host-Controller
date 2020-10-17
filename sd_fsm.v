module sd_comm_fsm (clk, reset, cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en);
    input clk, reset;
    input cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en;

    reg [4:1] PS, NS;
    parameter [4:1] INACTIVE = 4'd0, IDLE = 4'd1, READY = 4'd2, IDENTIFICATION = 4'd3,
                    STANDBY = 4'd4, TRANSFER = 4'd5, SENDING = 4'd6,
                    RECEIVING = 4'd7, PROGRAMMING = 4'd8, DISCONNECT = 4'd9;

    always @(posedge clk, posedge resetn) begin
        if (reset) PS <= IDLE;
        else PS <= NS
    end

    always @(PS) begin
        {cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en} = 0;
        case (PS)
                INACTIVE: PS <= INACTIVE;
                IDLE: begin
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
