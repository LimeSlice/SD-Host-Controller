module sd_send (
    input ex_clk, sd_clk, reset, send_en,
    input [37:0] cmd_content,
    output sd_cmd, sending,
    output reg finished
);	 
// not currently writing to sd_dat
// assign sd_dat = 4'b0;

// cmd_token[47]    = 0 (start bit)
// cmd_token[46]    = 1 (transmitter bit: '1'= host command)
// cmd_token[45:9]  = command content: command and address info
// cmd_token[8:1]   = CRC checksum
// cmd_token[0]     = 1 (end bit)
wire [37:0] cmd_content_out;

reg crc_load, tx_reset;
reg [2:1] PS, NS;

wire [6:0] cmd_crc;
wire crc_ready;

parameter [2:1] IDLE = 2'b00, PREP = 2'b01, WAIT_FOR_SENDING = 2'b10, SENDING = 2'b11;

// preserve cmd_content coming in
register #(38,0) cmd_content_reg (ex_clk, reset, cmd_content, send_en, cmd_content_out);

// module crc7 (clk, reset, data_in, crc_ready, crc);
crc7 #(40) crc_gen (.clk(ex_clk), .reset(reset), .load(crc_load), 
    .data_in({1'b0, 1'b1, cmd_content_out}), .crc_ready(crc_ready), .crc(cmd_crc));

sd_cmd_tx transmitter (.clk(sd_clk), .reset(tx_reset),
    .en(crc_ready), .sending(sending), .cmd({1'b0, 1'b1, cmd_content_out, cmd_crc, 1'b1}), .sd_cmd(sd_cmd));

always @(posedge ex_clk, posedge reset) begin
    if (reset) PS <= IDLE;
    else PS <= NS;
end

always @(PS, send_en, crc_ready, sending) begin
    {tx_reset, crc_load, finished} = 0;
    case (PS)
        IDLE: begin
            if (send_en) begin
                crc_load = 1'b1;
                NS = PREP;
            end
            else NS = IDLE;
        end
        PREP: begin
            if (crc_ready) begin
                tx_reset = 1'b1;
                NS = WAIT_FOR_SENDING;
            end
            else NS = PREP;
        end
        WAIT_FOR_SENDING: begin
            if (!sending) begin
                NS = WAIT_FOR_SENDING;
            end
            else begin
                NS = SENDING;
            end
        end
        SENDING: begin
            if (sending) begin
                NS = SENDING;
            end
            else begin
                finished = 1'b1;
                NS = IDLE;
            end
        end
    endcase
end
    
endmodule
