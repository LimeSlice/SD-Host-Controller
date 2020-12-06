// module sd_registers (
//     clk, reset, cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en, stat_en,
//     cid_in, csd_in, scr_in, stat_in, ocr_in, rca_in, drs_in,
//     cid_out, csd_out, scr_out, stat_out, ocr_out, rca_out, drs_out
// );
module sd_registers (
    input clk, reset,
    input cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en, stat_en,
    input [127:0]  cid_in, csd_in,
    input [63:0]   scr_in, stat_in, 
    input [31:0]   ocr_in,
    input [15:0]   rca_in, dsr_in,
    output [127:0] cid_out, csd_out,
    output [63:0]  scr_out, stat_out, 
    output [31:0]  ocr_out,
    output [15:0]  rca_out, dsr_out
);

// Card identification number
register #(128,128'b0) CID (clk, reset, cid_in, cid_en, cid_out);

// Relative card address; local address of a card
// Reset = 0x0000
register #(16,0) RCA (clk, reset, rca_in, rca_en, rca_out);

// Driver stage register
// Reset setting (lowest speed, highest driving current capability)
register #(16,16'h0404) DSR (clk, reset, dsr_in, dsr_en, dsr_out);

// Card specific data; info about card operating conditions
defparam CSD.WIDTH = 128;
defparam CSD.RST_VAL = {24'b0, 8'b00110010, 96'b0};
register CSD (clk, reset, csd_in, csd_en, csd_out);

// SD Config Register; info about SD memory card's special features
register #(64,0) SCR (clk, reset, scr_in, scr_en, scr_out);

// Operation condition register
// default VDD voltage profile of host 3.2-3.4V
defparam OCR.WIDTH = 32;
defparam OCR.RST_VAL = {9'b0, 2'b11, 21'b0};
register OCR (clk, reset, ocr_in, ocr_en, ocr_out);

// Response status
// [31:0]  card status
// [37:32] command_index (not all responses contain -- if none 4'b1111)
register #(64,0) STATUS (clk, reset, stat_in, stat_en, stat_out);

endmodule
