parameter [3:0] SD_CMD_GEN = 4'd0,
                RESPONSE = 4'd1,

parameter ENABLE = 1'b1, DISABLE = 1'b0;

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
