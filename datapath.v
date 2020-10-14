module datapath(ex_clk, ex_resetn);


    // When stopped, internal clock goes low (low-power state)
    tribuffer_1bit internal_clk (
        .in(ex_clk),
        .en(clk_en),
        .out(clk)
    );

    // Registers

    // System Address Register (RW)
    // Contains system memory address for DMA transfer
    register #(32) r0 (
        .clock(clk),
        .resetn(resetn),
        .d(),
        .en(),
        .q()
    );

    // Block Size Register (RW)
    // Used to configure number of bytes in a data block
    register #(16) r1 (clk, resetn, , , );

    // Block Counter Register (RW)
    // Used to configure number of data blocks
    register #(16) r2 (clk, resetn, , , );

    // Argument Register (RW)
    // SD Command Argument
    register #(32) r3 (clk, resetn, , , );

    // Transfer Mode Register (RW)
    // Control Operation of data transfers
    register #(32) r4 (clk, resetn, , , );

    // Command Register (RW)
    // Controls for Host to trigger SD command generation
    register #(16) r5 (clk, resetn, , , );

    // Response Registers (ROC)
    // Stores responses from SD card
    // 31..0
    register #(32) r6 (clk, resetn, , , );
    // 63..32
    register #(32) r7 (clk, resetn, , , );
    // 95..64
    register #(32) r8 (clk, resetn, , , );
    // 127..96
    register #(32) r9 (clk, resetn, , , );

    // Buffer Data Port Register (RW)
    // 32-bit data port register to access internal buffer
    register #(32) r10 (clk, resetn, , , );

    // Present State Register (RO)
    // Status of Host Controller
    register #(32) r11 (clk, 0, , , );

    // Block Gap Control Register (RW, RWAC)
    // Controls for reading, writing, requesting, etc
    // Continue Request (bit 1) is RWAC - controlled through FSM
    register #(8) r12 (clk, resetn, , , );

    // Wakeup Control Register (RW)
    // Wakeup functionality to begin IC power and clock cycle
    register #(8) r13 (clk, resetn, , , );

    // Clock Control Register (RW, ROC)
    // Clock Control
    // Internal Clock Stable (bit 1) is ROC
    register #(16) r14 (clk, resetn, , , );

    // Timeout Control Register (RW)
    // Timeout counter value according to the capabilities register
    register #(8) r15 (clk, resetn, , , );

    // Software Reset Register (RWAC)
    register #(8) r16 (clk, resetn, , , );

    // Normal Interrupt Status Register (ROC, RW1C)
    register #(16) r17 (clk, resetn, , , );

    // Error Interrupt Status Register (RW1C)
    register #(16) r18 (clk, resetn, , ,);

    // Normal Interrupt Status Enable Register (RW)
    register #(16) r19 (clk, resetn, , ,);

    // Error Interrupt Status Enable Register (RW)
    register #(16) r20 (clk, resetn, , , );

    // Normal Interrupt Signal Enable Register (RW)
    // ************** LOOK INTO MORE ****************
    register #(16) r21 (clk, resetn, , ,);

    // Error Interrupt Signal Enable Register (RW)
    // ************** LOOK INTO MORE ****************
    register #(16) r22 (clk, resetn, , , );

    // Auto CMD12 Error Status Register
    register #(16) r23 (clk, resetn, , , );

    // Capabilities Register
    // Hardware predetermined values about voltage, current, clock, etc
    register #(32) r24 (clk, resetn, , , );

    // Host Controller Version Register
    register #(16) r25 (clk, resetn, , , );



endmodule
