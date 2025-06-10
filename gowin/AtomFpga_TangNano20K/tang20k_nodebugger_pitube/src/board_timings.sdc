create_clock -name sys_clk -period 37.037 -waveform {0 18.518} [get_ports {sys_clk}] -add
create_clock -name audio_clk -period 40.690 -waveform {0 20.345} [get_ports {audio_clk}] -add

// Create clock definitions for each of the derived clocks
create_generated_clock -name clock_16 -source [get_ports {sys_clk}] -master_clock sys_clk -divide_by 27 -multiply_by 16 [get_nets {clock_main}]
create_generated_clock -name clock_25 -source [get_ports {sys_clk}] -master_clock sys_clk -divide_by 15 -multiply_by 14 [get_nets {clock_vga}]
create_generated_clock -name clock_32 -source [get_ports {sys_clk}] -master_clock sys_clk -divide_by 27 -multiply_by 32 [get_nets {clock_sid}]
create_generated_clock -name clock_96 -source [get_ports {sys_clk}] -master_clock sys_clk -divide_by 27 -multiply_by 96 [get_nets {clock_sdram}]
create_generated_clock -name spdif_clk -source [get_ports {audio_clk}] -master_clock audio_clk -divide_by 4 -multiply_by 1 [get_nets {spdif_clk}]

// Ignore any timing paths between the main and video clocks
set_clock_groups -asynchronous -group [get_clocks {clock_16}] -group [get_clocks {clock_25}]
set_clock_groups -asynchronous -group [get_clocks {clock_25}] -group [get_clocks {clock_16}]

// The SDRAM state machine is kicked off by a 0->1 of phi2 which is ~7 16MHz cycles after the CPU is "clocked"
// 3/2 96MHz cycles is the smallest value that allows timing to be met
// TODO: should we treat Phi2 as asynchronous and synchronise it?
set_multicycle_path -from [get_clocks {clock_16}] -to [get_clocks {clock_96}] -setup 3
set_multicycle_path -from [get_clocks {clock_16}] -to [get_clocks {clock_96}] -hold 2

set_multicycle_path -from [get_clocks {clock_96}] -to [get_clocks {clock_16}] -setup 2
set_multicycle_path -from [get_clocks {clock_96}] -to [get_clocks {clock_16}] -hold 1

set_false_path -from [get_clocks {clock_96}] -through [get_nets {inst_AtomFpga_Core/cpu_din*}] -to [get_clocks {clock_96}]

//set_false_path -from [get_clocks {clock_96}] -through [get_nets {cimplbootstrap*/*}] -to [get_clocks {clock_96}]

// Ignore any timing paths from main to spdif clocks
set_clock_groups -asynchronous -group [get_clocks {clock_16}] -group [get_clocks {spdif_clk}]
set_clock_groups -asynchronous -group [get_clocks {clock_32}] -group [get_clocks {spdif_clk}]

set_operating_conditions -grade c -model slow -speed 8 -setup -hold
