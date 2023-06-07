//Copyright (C)2014-2023 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.11 Education
//Created Time: 2023-05-17 13:47:28

create_clock -name sys_clk -period 37.037 -waveform {0 18.518} [get_ports {clock_27}] -add

// Create clock definitions for each of the derived clocks
create_generated_clock -name clock_16 -source [get_ports {clock_27}] -master_clock sys_clk -divide_by 27 -multiply_by 16 [get_nets {clock_main}]
create_generated_clock -name clock_25 -source [get_ports {clock_27}] -master_clock sys_clk -divide_by 15 -multiply_by 14 [get_nets {clock_vga}]
create_generated_clock -name clock_32 -source [get_ports {clock_27}] -master_clock sys_clk -divide_by 27 -multiply_by 32 [get_nets {clock_sid}]
create_generated_clock -name clock_96 -source [get_ports {clock_27}] -master_clock sys_clk -divide_by 27 -multiply_by 96 [get_nets {clock_psram}]

// Ignore any timing paths between the main and video clocks
set_clock_groups -asynchronous -group [get_clocks {clock_16}] -group [get_clocks {clock_25}]
set_clock_groups -asynchronous -group [get_clocks {clock_25}] -group [get_clocks {clock_16}]

// The PSRAM state machine is kicked off by a 0->1 of phi2 which is ~7 16MHz cycles after the CPU is "clocked"
// 4/3 96MHz cycles is the smallest value that allows timing to be met
// TODO: should we treat Phi2 as asynchronous and synchronise it?
set_multicycle_path -from [get_clocks {clock_16}] -to [get_clocks {clock_96}] -setup 4
set_multicycle_path -from [get_clocks {clock_16}] -to [get_clocks {clock_96}] -hold 3
set_multicycle_path -from [get_clocks {clock_32}] -to [get_clocks {clock_96}] -setup 4
set_multicycle_path -from [get_clocks {clock_32}] -to [get_clocks {clock_96}] -hold 3

set_multicycle_path -from [get_clocks {clock_96}] -to [get_clocks {clock_16}] -setup 2
set_multicycle_path -from [get_clocks {clock_96}] -to [get_clocks {clock_16}] -hold 1

// Correct for the part on the Tang Nano 9K
set_operating_conditions -grade c -model slow -speed 6 -setup

set_false_path -from [get_clocks {clock_96}] -through [get_nets {inst_AtomFpga_Core/cpu_din*}] -to [get_clocks {clock_96}]
