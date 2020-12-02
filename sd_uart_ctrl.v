module sd_uart_ctrl(
    input clk, reset, 
    input [7:0] rx_data_out, uart_ctrl_out,
    input [127:0] cid_reg_out,
    output reg sd_tx_en, uart_cmd_en,
    output [5:0] uart_cmd,
    output reg [7:0] sd_tx_data
);

reg send_bit_count_en;
reg [31:0] send_bit_count_in;
wire [31:0] send_bit_count_out;

reg send_cmd_en;
reg [7:0] send_cmd_in;
wire [7:0] send_cmd_out;

reg bytes_en;
reg [11:0] bytes_in;
wire [11:0] bytes_out;

reg [3:0] PS, NS;

// states
parameter [3:1] CHECK = 3'd0;

// Command bytes
parameter [5:1] RESET = 8'h20, STOP = 8'h25, WRITE = 8'h4A, READ = 8'h7A, 
                ERASE = 8'hF0, GET_SD_INFO = 8'h15, GET_CTRL_INFO = 8'h1B;

register #(8,0)  send_cmd        (clk, reset, send_cmd_in, send_cmd_en, send_cmd_out);
register #(12,0) received_bytes  (clk, reset, bytes_in, bytes_en, bytes_out);
register #(32,0) send_bit_count  (clk, reset, send_bit_count_in, send_bit_count_en, send_bit_count_out);




RECEIVED_DATA: begin
            case (bytes_out)
                // start byte = 0xA5
                0: begin
                    if (rx_data == 8'hA5) begin
                        bytes_en = 1'b1;
                        bytes_in = 12'd1;
                    end
                    else begin // invalid start byte
                        bytes_en = 1'b1;
                        bytes_in = 12'd0;
                    end
                    NS = CHECK;
                end

                // command byte
                1: begin
                    case (rx_data)
                        RESET: begin
                            // // send SD CMD0 to go to idle state
                            // uart_cmd = 6'd0;
                            // uart_cmd_en = 1'b1;
                            if (host_reset_clear) begin
                                software_reset = 1'b0;
                                rx_reset = 1'b0;
                                tx_reset = 1'b0;
                                bytes_in = 12'd0;
                                bytes_en = 1'b1;
                            end
                            else begin
                                // reset SDHC and registers and SD
                                software_reset = 1'b1;
                                rx_reset = 1'b1;
                                tx_reset = 1'b1; 
                            end
                            NS = CHECK;
                        end

                        // STOP: begin
                        //     // send SD to STANDBY state -- depends on current state of SD
                        // end

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
                            send_bit_count_in = 32'd128;
                            send_bit_count_en = 1'b1;
                            send_cmd_in = rx_data;
                            NS = SEND_CMD_BYTE;
                        end

                        // GET_CTRL_INFO: begin
                        //     // send SDHC health info
                        //     // send SDHC version number
                        //     // any other SDHC info that we would be able to send
                        // end

                        default: begin // invalid command byte
                            bytes_en = 1'b1;
                            bytes_in = 12'd0;
                            rx_reset = 1'b1;
                            NS = CHECK;
                        end
                    endcase
                end
                default: begin
                    NS = CHECK;
                end
            endcase
        end

        SEND_CMD_BYTE: begin
            case (send_cmd_out)
                GET_SD_INFO: begin
                    tx_data = cid_reg[send_bit_count_out-1 -: 8];
                    send_bit_count_in = send_bit_count_out - 8;
                    send_bit_count_en = 1'b1;
                    tx_reg_en = 1'b1;
                end
                default: begin
                    tx_data = 8'b0;
                    tx_reg_en = 1'b0;
                    send_bit_count_in = 8'b0;
                    send_bit_count_en = 1'b1;
                end
            endcase
            NS = CHECK;

endmodule
