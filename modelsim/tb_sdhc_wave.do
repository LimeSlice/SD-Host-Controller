onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_sdhc/clk
add wave -noupdate /tb_sdhc/uut/sd_clk
add wave -noupdate /tb_sdhc/resetn
add wave -noupdate /tb_sdhc/rx_pin
add wave -noupdate /tb_sdhc/tx_pin
add wave -noupdate /tb_sdhc/sd_cmd_pin
add wave -noupdate /tb_sdhc/sd_cd_pin
add wave -noupdate /tb_sdhc/sd_wp_pin
add wave -noupdate /tb_sdhc/sd_dat_pin
add wave -noupdate -radix hexadecimal /tb_sdhc/uut/fsm/PS
add wave -noupdate /tb_sdhc/uut/sd_cmd_we
add wave -noupdate /tb_sdhc/uut/sd_dat_we
add wave -noupdate /tb_sdhc/uut/send_en
add wave -noupdate /tb_sdhc/uut/send_cmd_content
add wave -noupdate /tb_sdhc/uut/sd_cmd_sending
add wave -noupdate /tb_sdhc/uut/fsm/timeout_counter_out
add wave -noupdate /tb_sdhc/uut/fsm/clock_counter_out
add wave -noupdate /tb_sdhc/uut/clk_div_cnt_gen_start
add wave -noupdate /tb_sdhc/uut/clk_div_cnt_gen_ok
add wave -noupdate /tb_sdhc/uut/clk_div_cnt_gen_err
add wave -noupdate /tb_sdhc/uut/sd_clk_divider_count
add wave -noupdate /tb_sdhc/uut/sd_receive_finished
add wave -noupdate /tb_sdhc/uut/sd_receive_started
add wave -noupdate /tb_sdhc/uut/response
add wave -noupdate /tb_sdhc/uut/receive_en
add wave -noupdate /tb_sdhc/uut/receive_status_en
add wave -noupdate /tb_sdhc/uut/receive_status_in
add wave -noupdate /tb_sdhc/uut/receive_status_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 251
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {56 ps}
