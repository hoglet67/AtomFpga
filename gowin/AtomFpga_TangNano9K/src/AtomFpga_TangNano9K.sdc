//Copyright (C)2014-2023 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.11 Education
//Created Time: 2023-05-17 13:47:28
create_clock -name sys_clk -period 37.037 -waveform {0 18.518} [get_ports {clock_27}] -add
create_generated_clock -name clock_16 -source [get_ports {clock_27}] -master_clock sys_clk -divide_by 27 -multiply_by 16 [get_nets {clock_16}]
create_generated_clock -name clock_25 -source [get_ports {clock_27}] -master_clock sys_clk -divide_by 15 -multiply_by 14 [get_nets {clock_25}]
set_clock_groups -asynchronous -group [get_clocks {clock_16}] -group [get_clocks {clock_25}]
set_clock_groups -asynchronous -group [get_clocks {clock_25}] -group [get_clocks {clock_16}]
set_operating_conditions -grade c -model fast -speed 6 -setup
