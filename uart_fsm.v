module uart_fsm(
    input clk, reset, sd_tx_en,
    input [7:0] sd_tx_data, rx_data, uart_ctrl_out, 
    output reg rx_reg_en, tx_reg_en, ctrl_reg_en,
    output reg rx_reset, tx_reset, software_reset, uart_tx_en, uart_cmd_en,
    output reg [5:0] uart_cmd,
    output reg [7:0] tx_data
);

reg bytes_en;
reg [11:0] bytes_in;
wire [11:0] bytes_out;

reg [3:1] PS, NS;

parameter [3:1] CHECK = 3'd0, RECEIVED_DATA = 3'd1, RESPOND_BYTE = 3'd2;

// Command bytes
parameter [8:1] RESET = 8'h20, STOP = 8'h25, WRITE = 8'h4A, READ = 8'h7A, 
                ERASE = 8'hF0, GET_SD_INFO = 8'h15, GET_CTRL_INFO = 8'h1B;

// uart_ctrl register bit names
parameter [4:1] RX_CONTAINS_DATA = 2'd2, TX_SENDING = 2'd1, TX_EN = 2'd0; 

register #(12,0) received_bytes (clk, reset | software_reset, bytes_in, bytes_en, bytes_out);

always @(posedge clk, posedge reset) begin
    if (reset) PS <= CHECK;
    else       PS <= NS;
end

always @(PS, rx_data, uart_ctrl_out, bytes_out, sd_tx_en, sd_tx_data) begin
    {bytes_en, bytes_in, rx_reg_en, tx_reg_en, ctrl_reg_en, rx_reset, tx_reset, 
     uart_tx_en, uart_cmd_en, uart_cmd, tx_data} = 0;
    case (PS)
        CHECK: begin
            if (sd_tx_en) begin
                tx_reset = 1'b1;        // reset transmitter to start new transmission
                uart_tx_en = 1'b1;      // uart_ctrl_in[0]
                ctrl_reg_en = 1'b1;     // enable ctrl_reg to store en
                tx_data = sd_tx_data;   // store new tx_data from sd card
                tx_reg_en = 1'b1;       // enable tx_reg to store new tx_data
            end
            else if (uart_ctrl_out[TX_EN] & uart_ctrl_out[TX_SENDING]) begin
                uart_tx_en = 1'b1;
                ctrl_reg_en = 1'b1;
            end
            else begin
                uart_tx_en = 1'b0;
                ctrl_reg_en = 1'b0;
            end
            
            if (uart_ctrl_out[RX_CONTAINS_DATA]) begin
                NS <= RECEIVED_DATA;
            end
            else begin
                NS <= CHECK;
            end
        end

        RECEIVED_DATA: begin
            case (bytes_out)
                // start byte = 0xA5
                0: begin
                    if (rx_data == 8'hA5) begin
                        bytes_en = 1'b1;
                        bytes_in = 12'd1;
                        rx_reset = 1'b1; // reset rx to allow new data
                    end
                    else begin // invalid start byte
                        bytes_en = 1'b1;
                        bytes_in = 12'd0;
                        rx_reset = 1'b1;
                    end
                end

                // command byte
                1: begin
                    case (rx_data)
                        RESET: begin
                            // reset SDHC and registers and SD
                            software_reset = 1'b1;
                            rx_reset = 1'b1;
                            tx_reset = 1'b1;
                            // send SD CMD0 to go to idle state
                            uart_cmd = 6'd0;
                            uart_cmd_en = 1'b1;
                        end

                        STOP: begin
                            // send SD to STANDBY state -- depends on current state of SD
                        end

                        // WRITE: begin
                        //     // multiple responses
                        //     // multiple commands
                        // end

                        // READ: begin
                        //     // multiple responses
                        //     // multiple commands
                        // end

                        // ERASE: begin
                        //     // multiple responses
                        //     // multiple commands
                        // end

                        GET_SD_INFO: begin
                            // send SD card info
                            // CMD2/CMD10 (should have CID register from initialization step already), 
                            //   CMD9, ACMD41
                        end

                        GET_CTRL_INFO: begin
                            // send SDHC health info
                            // send SDHC version number
                            // any other SDHC info that we would be abld to send
                        end

                        default: begin // invalid command byte
                            bytes_en = 1'b1;
                            bytes_in = 12'd0;
                            rx_reset = 1'b1;
                        end
                    endcase
                end
                default: begin
                    
                end
            endcase
            NS = CHECK;
        end

        default: begin
            
        end
    endcase 
end

endmodule
