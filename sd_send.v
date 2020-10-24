module sd_send (ex_clk, sd_clk, reset, send_en, cmd_content, sending, sd_cmd, sd_dat);
    input ex_clk, sd_clk, send_en, reset;
    input [37:0] cmd_content;
    output sd_cmd, sending;
    output [3:0] sd_dat;
    
    reg crc_load, tx_en;
    reg [2:1] PS, NS;

    wire [6:0] cmd_crc;
    wire [47:0] cmd_token;

    parameter [2:1] IDLE = 2'b00, LOAD = 2'b01, PREP = 2'b10, SENDING = 2'b11;

    // cmd_token[47]    = 0 (start bit)
    // cmd_token[46]    = 1 (transmitter bit: '1'= host command)
    // cmd_token[45:9]  = command content: command and address info
    // cmd_token[8:1]   = CRC checksum
    // cmd_token[0]     = 1 (end bit)
    assign cmd_token = {2'b01, cmd_content, cmd_crc, 1'b1};

    // module crc7 (clk, reset, data_in, crc_ready, crc);
    crc7 #(40) crc_gen (.clk(ex_clk), .reset(reset), .load(crc_load), 
        .data_in(cmd_token[47:8]), .crc_ready(crc_ready), .crc(cmd_crc));

    sd_cmd_tx transmitter (.clk(sd_clk), .reset(reset),
        .en(tx_en), .sending(sending), .cmd(cmd_token), .sd_cmd(sd_cmd));

    always @(posedge sd_clk, posedge reset) begin
        if (reset) PS <= IDLE;
        else PS <= NS;
    end
    
    always @(PS, send_en, crc_ready, sending) begin
        {crc_load} = 0;
        case (PS)
            IDLE: begin
                if (send_en) begin
                    crc_load = 1'b1;
                    NS = PREP;
                end
                else NS = IDLE;
            end
            LOAD: begin
                NS = PREP;
            end
            PREP: begin
                if (crc_ready) begin
                    NS = SENDING;
                end
                else NS = PREP;
            end
            SENDING: begin
               if (sending) begin
                   tx_en = 1'b1;
                   NS = SENDING;
               end
               else NS = IDLE;
            end
        endcase
    end
    
endmodule
