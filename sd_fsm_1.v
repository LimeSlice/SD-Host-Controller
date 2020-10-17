module sd_comm_fsm (clk, reset, cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en);
    input clk, reset;
    input cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en;

    reg [6:1] state;
    parameter [6:1] CMD0   = 6'd0,      // GO_IDLE_STATE -- Basic (mandatory)
                    CMD2   = 6'd2,      // ALL_SEND_CID -- Basic (mandatory)
                    CMD3   = 6'd3,      // SEND_RELATIVE_ADDR -- Basic (mandatory)
                    CMD4   = 6'd4,      // SET_DSR -- Basic (mandatory)
                    CMD5   = 6'd5,      // I/O Mode (Optional)
                    CMD6   = 6'd6,      // Switch (Mandatory)
                    CMD7   = 6'd7,      // Basic (mandatory)
                    CMD9   = 6'd9,      // Basic (mandatory)
                    CMD10  = 6'd10,     // Basic (mandatory)
                    CMD12  = 6'd12,     // Basic (mandatory)
                    CMD13  = 6'd13,     // Basic (mandatory)
                    CMD15  = 6'd15,     // GO_INACTIVE_STATE -- Basic (mandatory)
                    CMD16  = 6'd16,     // Block read/write, lock card (mandatory)
                    CMD17  = 6'd17,     // Block read (mandatory)
                    CMD18  = 6'd18,     // Block read (mandatory)
                    CMD24  = 6'd24,     // Block write (mandatory)
                    CMD25  = 6'd25,     // Block write (mandatory)
                    CMD27  = 6'd27,     // Block write (mandatory)
                    CMD28  = 6'd28,     // Write protection (optional)
                    CMD29  = 6'd29,     // Write protection (optional)
                    CMD30  = 6'd30,     // Write protection (optional) 
                    CMD32  = 6'd32,     // Erase (mandatory)
                    CMD33  = 6'd33,     // Erase (mandatory)
                    CMD34  = 6'd34,     // Switch (optional)
                    CMD35  = 6'd35,     // Switch (optional)
                    CMD36  = 6'd36,     // Switch (optional)
                    CMD37  = 6'd37,     // Switch (optional)
                    CMD38  = 6'd38,     // Erase (mandatory)
                    CMD42  = 6'd42,     // Lock card (optional)
                    CMD50  = 6'd50,     // Switch (optional)
                    CMD52  = 6'd52,     // I/O mode (optional)
                    CMD53  = 6'd53,     // I/O mode (optional)
                    CMD55  = 6'd55,     // Application specific (mandatory)
                    CMD56  = 6'd56,     // Application specific (mandatory)
                    CMD57  = 6'd57,     // Switch (optional)
                    // ACMD0 would start at 7'd64
                    ACMD6  = 6'd70,     // Application specific (mandatory)
                    ACMD13 = 6'd77,     // Application specific (mandatory)
                    ACMD22 = 6'd86,     // Application specific (mandatory)
                    ACMD23 = 6'd87,     // Application specific (mandatory)
                    ACMD41 = 6'd105,    // SD_SEND_OP_COND -- Application specific (mandatory)
                    ACMD42 = 6'd106,    // Application specific (mandatory)
                    ACMD51 = 6'd115;    // Application specific (mandatory)

    always @(posedge clk, posedge resetn) begin
        if (reset) state <= CMD0;
        else begin
            casex (state)
                CMD0: state <= ACMD41;
                CMD2: begin
                end
                CMD3: begin
                end
                CMD4: begin
                end
                CMD5: begin
                end
                CMD6: begin
                end
                CMD7: begin
                end
                CMD9: begin
                end
                CMD10: begin
                end
                CMD12: begin
                end
                CMD13: begin
                end
                CMD15: begin
                end
                CMD16: begin
                end
                CMD17: begin
                end
                CMD18: begin
                end
                CMD24: begin
                end
                CMD25: begin
                end
                CMD27: begin
                end
                CMD28: begin
                end
                CMD29: begin
                end
                CMD30: begin
                end
                CMD32: begin
                end
                CMD33: begin
                end
                CMD34: begin
                end
                CMD35: begin
                end
                CMD36: begin
                end
                CMD37: begin
                end
                CMD38: begin
                end
                CMD42: begin
                end
                CMD50: begin
                end
                CMD52: begin
                end
                CMD53: begin
                end
                CMD55: begin
                end
                CMD56: begin
                end
                CMD57: begin
                end
                ACMD6: begin
                end
                ACMD13: begin
                end
                ACMD22: begin
                end
                ACMD23: begin
                end
                ACMD41: begin
                    // Send request to receive OCR
                    // Waits to receive OCR content as response (card is busy or host omitted voltage range) -- state <= ACMD41
                    // If card non compatible voltage range -- state <= CMD15
                end
                ACMD42: begin
                end
                ACMD51: begin
                end
            endcase
        end
    end

    always @(state) begin
        {cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en} = 0;
        casex (state)

            // SD_CMD in input mode
            CMD0: begin
            end
            CMD2: begin
            end
            CMD3: begin
            end
            CMD4: begin
            end
            CMD5: begin
            end
            CMD6: begin
            end
            CMD7: begin
            end
            CMD9: begin
            end
            CMD10: begin
            end
            CMD12: begin
            end
            CMD13: begin
            end
            CMD15: begin
            end
            CMD16: begin
            end
            CMD17: begin
            end
            CMD18: begin
            end
            CMD24: begin
            end
            CMD25: begin
            end
            CMD27: begin
            end
            CMD28: begin
            end
            CMD29: begin
            end
            CMD30: begin
            end
            CMD32: begin
            end
            CMD33: begin
            end
            CMD34: begin
            end
            CMD35: begin
            end
            CMD36: begin
            end
            CMD37: begin
            end
            CMD38: begin
            end
            CMD42: begin
            end
            CMD50: begin
            end
            CMD52: begin
            end
            CMD53: begin
            end
            CMD55: begin
            end
            CMD56: begin
            end
            CMD57: begin
            end
            ACMD6: begin
            end
            ACMD13: begin
            end
            ACMD22: begin
            end
            ACMD23: begin
            end
            ACMD41: begin
            end
            ACMD42: begin
            end
            ACMD51: begin
            end
        endcase
    end



endmodule
