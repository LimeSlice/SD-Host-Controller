module sd_receive (
    input ex_clk, sd_clk, reset, receive_en, R2_response, R3_response, sd_cmd,
    output [126:0] response,
    output reg crc_err, sd_receive_finished, sd_receive_started
);

    wire finished, crc_ready_40, crc_ready_120;
    wire [6:0] resp_crc, check_crc_40, check_crc_120;
    wire [134:0] rx_resp;

    reg rx_en, crc_load_40, crc_load_120;
    reg [2:1] PS, NS;

    parameter [2:1] IDLE = 2'b00, RECEIVING = 2'b01, LOAD = 2'b10, CHECKING = 2'b11;

    assign response = R2_response ? rx_resp[126:0] : rx_resp[134:8];

    // Computes from start bit to CRC segment [47:7]
    crc7 #(40) crc_40bit (.clk(ex_clk), .reset(reset), .load(crc_load_40),
        .data_in(rx_resp[134:95]), .crc_ready(crc_ready_40), .crc(check_crc_40));
    
    // ignores start, transmit, and 6 command bits. Computes next 120 bits. [127:7]
    crc7 #(120) crc_120bit (.clk(ex_clk), .reset(reset), .load(crc_load_120),
        .data_in(rx_resp[126:7]), .crc_ready(crc_ready_120), .crc(check_crc_120));

    sd_resp_rx receiver (.clk(sd_clk), .reset(reset), .en(rx_en), 
        .R2_response(R2_response), .sd_cmd(sd_cmd), .response(rx_resp), 
        .finished(finished), .started(sd_receive_started));
    
    always @(posedge sd_clk, posedge reset) begin
        if (reset) PS <= IDLE;
        else PS <= NS;
    end

    always @(PS, receive_en, finished, crc_ready_40, crc_ready_120) begin
        crc_err = 0;
        case (PS)
            IDLE: begin
                crc_load_40 = 1'b0;
                crc_load_120 = 1'b0;
                rx_en = 1'b0;
                sd_receive_finished = 1'b0;
                if (receive_en) NS = RECEIVING;
                else    NS = IDLE;
            end
            RECEIVING: begin
                if (finished) begin
                    if (R2_response) begin
                        crc_load_40 = 1'b0;
                        crc_load_120 = 1'b1;
                        rx_en = 1'b0;
                        sd_receive_finished = 1'b0;
                        NS = LOAD;
                    end
                    // no checksum -- done
                    else if (R3_response) begin
                        crc_load_40 = 1'b0;
                        crc_load_120 = 1'b0;
                        rx_en = 1'b0;
                        sd_receive_finished = 1'b1;
                        NS = IDLE;
                    end
                    else begin
                        crc_load_40 = 1'b1;
                        crc_load_120 = 1'b0;
                        rx_en = 1'b0;
                        sd_receive_finished = 1'b0;
                        NS = LOAD;
                    end
                end
                else begin
                    crc_load_40 = 1'b0;
                    crc_load_120 = 1'b0;
                    rx_en = 1'b1;
                    sd_receive_finished = 1'b0;
                    NS = RECEIVING;
                end
            end
            LOAD: begin
                rx_en = 1'b0;
                crc_load_40 = 1'b0;
                crc_load_120 = 1'b0;
                sd_receive_finished = 1'b0;
                NS = CHECKING;
            end
            CHECKING: begin
                rx_en = 1'b0;
                crc_load_40 = 1'b0;
                crc_load_120 = 1'b0;
                if (R2_response) begin
                    if (crc_ready_120) begin
                        if (check_crc_120 != rx_resp[6:0])
                            crc_err = 1'b1;
                        else
                            crc_err = 1'b0;
                        sd_receive_finished = 1'b1;
                        NS = IDLE;
                    end
                    else begin
                        sd_receive_finished = 1'b0;
                        crc_err = 1'b0;
                        NS = CHECKING;
                    end
                end
                else begin
                    if (crc_ready_40) begin
                        if (check_crc_40 != rx_resp[94:88])
                            crc_err = 1;
                        else 
                            crc_err = 0;
                        sd_receive_finished = 1'b1;
                        NS = IDLE;
                    end
                    else begin
                        crc_err = 0;
                        sd_receive_finished = 1'b0;
                        NS = CHECKING;
                    end
                end
            end
        endcase 
    end


endmodule
