// module sd_registers (
//     clk, reset, cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en,
//     cid_in, csd_in, scr_in, ocr_in, rca_in, drs_in,
//     cid_out, csd_out, scr_out, ocr_out, rca_out, drs_out
// );
module sd_registers (
    input clk, reset,
    input cid_en, rca_en, dsr_en, csd_en, scr_en, ocr_en,
    input [127:0]  cid_in, csd_in,
    input [63:0]   scr_in, 
    input [31:0]   ocr_in,
    input [15:0]   rca_in, drs_in,
    output [127:0] cid_out, csd_out,
    output [63:0]  scr_out, 
    output [31:0]  ocr_out,
    output [15:0]  rca_out, drs_out
);

    // Card identification number
    register #(128,0) CID (clk, reset, cid_in, cid_en, cid_out);
    
    // Relative card address; local address of a card
    // Reset = 0x0000
    register #(16,0) RCA (clk, reset, rca_in, rca_en, rca_out);

    // Driver stage register
    // Reset setting (lowest speed, highest driving current capability)
    register #(16,16'h0404) DSR (clk, reset, dsr_in, dsr_en, dsr_out);

    // Card specific data; info about card operating conditions
    register #(128,0) CSD (clk, reset, csd_in, csd_en, csd_out);

    // SD Config Register; info about SD memory card's special features
    register #(64,0) SCR (clk, reset, scr_in, scr_en, scr_out);

    // Operation condition register
    register #(32,0) OCR (clk, reset, ocr_in, ocr_en, ocr_out);

endmodule
