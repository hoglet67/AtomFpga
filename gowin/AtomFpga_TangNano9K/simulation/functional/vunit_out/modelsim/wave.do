onerror {resume}
quietly virtual signal -install /test_tb/uut { /test_tb/uut/IO_psram_dq(7 downto 0)} IO_psram_data
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /test_tb/uut/powerup_reset_n
add wave -noupdate -radix hexadecimal /test_tb/uut/delayed_reset_n
add wave -noupdate -radix hexadecimal /test_tb/uut/hard_reset_n
add wave -noupdate -radix hexadecimal /test_tb/uut/RamCE
add wave -noupdate -radix hexadecimal /test_tb/uut/RomCE
add wave -noupdate -radix hexadecimal /test_tb/uut/ExternCE
add wave -noupdate -radix hexadecimal /test_tb/uut/ExternWE
add wave -noupdate -radix hexadecimal /test_tb/uut/ExternA
add wave -noupdate -radix hexadecimal /test_tb/uut/ExternDin
add wave -noupdate -radix hexadecimal /test_tb/uut/ExternDout
add wave -noupdate -radix hexadecimal /test_tb/uut/phi2
add wave -noupdate /test_tb/uut/clock_main
add wave -noupdate /test_tb/uut/clock_vga
add wave -noupdate /test_tb/uut/clock_hdmi
add wave -noupdate /test_tb/uut/clock_sid
add wave -noupdate /test_tb/uut/inst_AtomFpga_Core/clk_counter
add wave -noupdate /test_tb/uut/inst_AtomFpga_Core/cpu_cycle
add wave -noupdate /test_tb/uut/inst_AtomFpga_Core/cpu_clken
add wave -noupdate -radix hexadecimal /test_tb/uut/sync
add wave -noupdate -radix hexadecimal /test_tb/uut/rnw
add wave -noupdate -radix hexadecimal /test_tb/uut/data
add wave -noupdate -radix hexadecimal /test_tb/uut/bootstrap_busy
add wave -noupdate -radix hexadecimal /test_tb/uut/RomDout
add wave -noupdate -radix hexadecimal /test_tb/uut/psram_phi2
add wave -noupdate -radix hexadecimal /test_tb/uut/psram_phi2d
add wave -noupdate -radix hexadecimal /test_tb/uut/psram_ce
add wave -noupdate -radix hexadecimal /test_tb/uut/psram_we
add wave -noupdate -radix hexadecimal /test_tb/uut/psram_read
add wave -noupdate -radix hexadecimal /test_tb/uut/psram_write
add wave -noupdate -radix hexadecimal /test_tb/uut/psram_busy
add wave -noupdate -radix hexadecimal /test_tb/uut/psram_addr
add wave -noupdate -radix hexadecimal /test_tb/uut/psram_din
add wave -noupdate -radix hexadecimal /test_tb/uut/psram_dout
add wave -noupdate -radix hexadecimal /test_tb/uut/psram_din8
add wave -noupdate -radix hexadecimal /test_tb/uut/psram_dout8
add wave -noupdate -radix hexadecimal /test_tb/uut/O_psram_ck(0)
add wave -noupdate -radix hexadecimal /test_tb/uut/IO_psram_rwds(0)
add wave -noupdate -radix hexadecimal /test_tb/uut/O_psram_reset_n(0)
add wave -noupdate -radix hexadecimal /test_tb/uut/O_psram_cs_n(0)
add wave -noupdate -radix hexadecimal /test_tb/uut/IO_psram_data
add wave -noupdate -radix hexadecimal /test_tb/uut/IO_psram_dq(7)
add wave -noupdate -radix hexadecimal /test_tb/uut/IO_psram_dq(6)
add wave -noupdate -radix hexadecimal /test_tb/uut/IO_psram_dq(5)
add wave -noupdate -radix hexadecimal /test_tb/uut/IO_psram_dq(4)
add wave -noupdate -radix hexadecimal /test_tb/uut/IO_psram_dq(3)
add wave -noupdate -radix hexadecimal /test_tb/uut/IO_psram_dq(2)
add wave -noupdate -radix hexadecimal /test_tb/uut/IO_psram_dq(1)
add wave -noupdate -radix hexadecimal /test_tb/uut/IO_psram_dq(0)
add wave -noupdate -radix hexadecimal /test_tb/uut/inst_AtomFpga_Core/cpu/nmos/cpu/ABC
add wave -noupdate -radix hexadecimal /test_tb/uut/inst_AtomFpga_Core/cpu/nmos/cpu/X
add wave -noupdate -radix hexadecimal /test_tb/uut/inst_AtomFpga_Core/cpu/nmos/cpu/Y
add wave -noupdate -radix hexadecimal /test_tb/uut/inst_AtomFpga_Core/cpu/nmos/cpu/P
add wave -noupdate -radix hexadecimal /test_tb/uut/inst_AtomFpga_Core/cpu/nmos/cpu/PC
add wave -noupdate -radix hexadecimal /test_tb/uut/inst_AtomFpga_Core/cpu/nmos/cpu/S
add wave -noupdate -radix hexadecimal /test_tb/uut/reset_counter
add wave -noupdate /test_tb/phi2
add wave -noupdate /test_tb/uut/btn1_n
add wave -noupdate /test_tb/uut/btn2_n
add wave -noupdate -radix hexadecimal -childformat {{/test_tb/uut/ram/rst_cnt(13) -radix hexadecimal} {/test_tb/uut/ram/rst_cnt(12) -radix hexadecimal} {/test_tb/uut/ram/rst_cnt(11) -radix hexadecimal} {/test_tb/uut/ram/rst_cnt(10) -radix hexadecimal} {/test_tb/uut/ram/rst_cnt(9) -radix hexadecimal} {/test_tb/uut/ram/rst_cnt(8) -radix hexadecimal} {/test_tb/uut/ram/rst_cnt(7) -radix hexadecimal} {/test_tb/uut/ram/rst_cnt(6) -radix hexadecimal} {/test_tb/uut/ram/rst_cnt(5) -radix hexadecimal} {/test_tb/uut/ram/rst_cnt(4) -radix hexadecimal} {/test_tb/uut/ram/rst_cnt(3) -radix hexadecimal} {/test_tb/uut/ram/rst_cnt(2) -radix hexadecimal} {/test_tb/uut/ram/rst_cnt(1) -radix hexadecimal} {/test_tb/uut/ram/rst_cnt(0) -radix hexadecimal}} -subitemconfig {/test_tb/uut/ram/rst_cnt(13) {-height 17 -radix hexadecimal} /test_tb/uut/ram/rst_cnt(12) {-height 17 -radix hexadecimal} /test_tb/uut/ram/rst_cnt(11) {-height 17 -radix hexadecimal} /test_tb/uut/ram/rst_cnt(10) {-height 17 -radix hexadecimal} /test_tb/uut/ram/rst_cnt(9) {-height 17 -radix hexadecimal} /test_tb/uut/ram/rst_cnt(8) {-height 17 -radix hexadecimal} /test_tb/uut/ram/rst_cnt(7) {-height 17 -radix hexadecimal} /test_tb/uut/ram/rst_cnt(6) {-height 17 -radix hexadecimal} /test_tb/uut/ram/rst_cnt(5) {-height 17 -radix hexadecimal} /test_tb/uut/ram/rst_cnt(4) {-height 17 -radix hexadecimal} /test_tb/uut/ram/rst_cnt(3) {-height 17 -radix hexadecimal} /test_tb/uut/ram/rst_cnt(2) {-height 17 -radix hexadecimal} /test_tb/uut/ram/rst_cnt(1) {-height 17 -radix hexadecimal} /test_tb/uut/ram/rst_cnt(0) {-height 17 -radix hexadecimal}} /test_tb/uut/ram/rst_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {438491248 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 368
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
WaveRestoreZoom {438437567 ps} {439598641 ps}
