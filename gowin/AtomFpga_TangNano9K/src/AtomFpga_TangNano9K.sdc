//Copyright (C)2014-2023 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.9 Beta
//Created Time: 2023-05-11 21:03:50
create_clock -name sys_clk -period 37.037 -waveform {0 18.518} [get_ports {clock_27}] -add
set_operating_conditions -grade c -model fast -speed 6 -setup
