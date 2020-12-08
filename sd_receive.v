module sd_receive (
    input ex_clk, sd_clk, reset, receive_en, R2_response, R3_response, sd_cmd,
    output [126:0] response,
    output sd_receive_started, crc_loaded,
    output reg crc_err, sd_receive_finished 
);

    wire finished, crc_ready_40, crc_ready_120;
    wire [6:0] resp_crc, check_crc_40, check_crc_120;
    wire [133:1] rx_resp;

    reg r2_resp, save_r2, rx_en, crc_load_40, crc_load_120;
    reg [2:1] PS, NS;

    parameter [2:1] IDLE = 2'b00, RECEIVING = 2'b01, LOAD = 2'b10, CHECKING = 2'b11;

    assign crc_loaded = crc_load_120 | crc_load_40;
    assign response = R2_response ? rx_resp[133:7] : rx_resp[133:96];

    // preserve R2 response variable as receives don't for crc7 checks
    always @(posedge ex_clk, posedge reset) begin
        if (reset) r2_resp <= 0;
        else if (save_r2) r2_resp <= R2_response;
        else r2_resp <= r2_resp;
    end


    // Computes from start bit to CRC segment [47:7]
    crc7 #(38) crc_40bit (.clk(ex_clk), .reset(reset), .load(crc_load_40),
        .data_in(rx_resp[133:96]), .crc_ready(crc_ready_40), .crc(check_crc_40));
    
    // ignores start, transmit, and 6 command bits. Computes next 120 bits. [127:7]
    crc7 #(120) crc_120bit (.clk(ex_clk), .reset(reset), .load(crc_load_120),
        .data_in(rx_resp[127:8]), .crc_ready(crc_ready_120), .crc(check_crc_120));

    sd_resp_rx receiver (.clk(sd_clk), .reset(reset), .en(rx_en), 
        .R2_response(R2_response), .sd_cmd(sd_cmd), .response(rx_resp), 
        .finished(finished), .started(sd_receive_started));
    
    always @(posedge ex_clk, posedge reset) begin
        if (reset) PS <= IDLE;
        else PS <= NS;
    end

    always @(PS, receive_en, finished, crc_ready_40, crc_ready_120, 
				 R2_response, R3_response, check_crc_120, rx_resp, 
				 crc_ready_40, check_crc_40) 
	 begin

        {crc_err, save_r2, rx_en, sd_receive_finished, crc_load_40, crc_load_120} = 0;
        
        case (PS)
            IDLE: begin
                if (receive_en) NS = RECEIVING;
                else    NS = IDLE;
            end
            RECEIVING: begin
                if (finished) begin
                    save_r2 = 1'b1;
                    if (R2_response) begin
                        crc_load_120 = 1'b1;
                        NS = LOAD;
                    end
                    // no checksum -- done
                    else if (R3_response) begin
                        sd_receive_finished = 1'b1;
                        NS = IDLE;
                    end
                    else begin
                        crc_load_40 = 1'b1;
                        NS = LOAD;
                    end
                end
                else begin
                    rx_en = 1'b1;
                    NS = RECEIVING;
                end
            end
            LOAD: begin
                NS = CHECKING;
            end
            CHECKING: begin
                if (r2_resp) begin
                    if (crc_ready_120) begin
                        if (check_crc_120 != rx_resp[7:1])
                            crc_err = 1'b1;
                        sd_receive_finished = 1'b1;
                        NS = IDLE;
                    end
                    else begin
                        NS = CHECKING;
                    end
                end
                else begin
                    if (crc_ready_40) begin
                        if (check_crc_40 != rx_resp[95:89])
                            crc_err = 1;
                        sd_receive_finished = 1'b1;
                        NS = IDLE;
                    end
                    else begin
                        NS = CHECKING;
                    end
                end
            end
        endcase 
    end


endmodule
