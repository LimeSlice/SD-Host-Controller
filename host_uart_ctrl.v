/**
  * No payloads are implemented, but would
  * need to be for STATUS, READ and WRITE commands.
  */
module host_uart_ctrl (
    input clk, reset,
    input [7:0] rx_data, uart_ctrl,
    output [3:0] host_cmd
);

reg PS, NS;

// uart_ctrl register bit names
parameter [4:1] RX_CONTAINS_DATA = 2'd2, TX_SENDING = 2'd1, TX_EN = 2'd0; 

// states
parameter [5:1] IDLE = 5'h00, GET_CMD = 5'h01, 
                EXEC_INIT = 5'h11, EXEC_STATUS = 5'h12, EXEC_READ = 5'h13, EXEC_WRITE = 5'h14;

// incoming bytes
parameter [8:1] START_BYTE = 8'hA5, 
                STATUS = 8'h50, READ = 8'h20, WRITE = 8'h40;

always @(posedge clk, posedge reset) begin
    if (reset)  PS <= IDLE;
    else        PS <= NS;
end 

always @* begin

    case (PS)
        IDLE: begin
            if (uart_ctrl[RX_CONTAINS_DATA] && rx_data == START_BYTE) begin
                NS = GET_CMD;
            end
        end

        GET_CMD: begin
            if (uart_ctrl[RX_CONTAINS_DATA]) begin
                case (rx_data)
                    // INIT:    NS = EXEC_INIT;
                    // STATUS:  NS = EXEC_STATUS;
                    // READ:    NS = EXEC_READ;
                    // WRITE:   NS = EXEC_WRITE;
                    default: NS = IDLE;
                endcase
            end
        end

        // EXEC_STATUS: begin
            
        // end

        // EXEC_READ: begin
            
        // end

        // EXEC_WRITE: begin
            
        // end

        default: begin
            NS = IDLE;
        end
    endcase


end

endmodule
