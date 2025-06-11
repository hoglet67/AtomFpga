// Notes:
//
// Good article on multi cycle paths:
//    https://vlsiuniverse.blogspot.com/2016/07/multicycle-path-sta.html

// Use the slow operating conditions to give a bit of extra margin
set_operating_conditions -grade c -model slow -speed 8 -setup -hold

// Create clock definitions for each of the master clocks
create_clock -name sys_clk   -period 37.037 -waveform {0 18.518} [get_ports {sys_clk  }] -add
create_clock -name audio_clk -period 40.690 -waveform {0 20.345} [get_ports {audio_clk}] -add

// Create clock definitions for each of the derived clocks
create_generated_clock -name clock_vgadac1 -source [get_ports {sys_clk}]   -master_clock sys_clk   -divide_by 15 -multiply_by  42 [get_nets {clock_vgadac1 }]
create_generated_clock -name clock_vga     -source [get_ports {sys_clk}]   -master_clock sys_clk   -divide_by 15 -multiply_by  14 [get_nets {clock_vga     }]
create_generated_clock -name clock_main    -source [get_ports {sys_clk}]   -master_clock sys_clk   -divide_by 27 -multiply_by  32 [get_nets {clock_main    }]
create_generated_clock -name clock_sdram   -source [get_ports {sys_clk}]   -master_clock sys_clk   -divide_by 27 -multiply_by  96 [get_nets {clock_sdram   }]
create_generated_clock -name clock_hdmi    -source [get_ports {sys_clk}]   -master_clock sys_clk   -divide_by 27 -multiply_by 126 [get_nets {clock_hdmi    }]
create_generated_clock -name spdif_clk     -source [get_ports {audio_clk}] -master_clock audio_clk -divide_by 4  -multiply_by   1 [get_nets {spdif_clk     }]

// Ignore any timing paths between the main and video clock domains
set_clock_groups -asynchronous -group [get_clocks {clock_main}] -group [get_clocks {clock_vga}]
set_clock_groups -asynchronous -group [get_clocks {clock_vga}]  -group [get_clocks {clock_main}]

// Ignore any timing paths from the main to the spdif clock domain
set_clock_groups -asynchronous -group [get_clocks {clock_main}] -group [get_clocks {spdif_clk}]

// Define multi cycle paths within the CPU as state has several cycles to propogate
// (32 @ 1MHz, 16 @ 2MHz, 8 @ 4MHz)
set_multicycle_path -from [get_regs {inst_AtomFpga_Core/cpu/*/*}] -to [get_regs {inst_AtomFpga_Core/cpu/*/*}]  -setup -end 4
set_multicycle_path -from [get_regs {inst_AtomFpga_Core/cpu/*/*}] -to [get_regs {inst_AtomFpga_Core/cpu/*/*}]  -hold  -end 3

// Define multicycle paths between the SDRAM controller address/data
// registers and anything in the main clock domain. The SDRAM state
// machine is kicked off by a 0->1 of phi2 which is several main_clock
// cycles after the CPU been clocked (16 @ 1MHz, 8 @ 2MHz, 4 @ 4MHz).
// Note: -start/-end selected so the numbers are always clock_main cycles
// Note: the default for -setup is the -end clock
// Note: the default for -hold is the -start clock

// Main -> SDRAM Address
set_multicycle_path -from [get_clocks {clock_main}] -to [get_regs {e_mem/sdram_ctl/r_A*      }] -setup -start 3
set_multicycle_path -from [get_clocks {clock_main}] -to [get_regs {e_mem/sdram_ctl/r_A*      }] -hold  -start 2
set_multicycle_path -from [get_clocks {clock_main}] -to [get_regs {e_mem/sdram_ctl/sdram_A*  }] -setup -start 3
set_multicycle_path -from [get_clocks {clock_main}] -to [get_regs {e_mem/sdram_ctl/sdram_A*  }] -hold  -start 2
//Current BS is always bank 0 sp these get optimized away
//set_multicycle_path -from [get_clocks {clock_main}] -to [get_regs {e_mem/sdram_ctl/sdram_BS* }] -setup -start 3
//set_multicycle_path -from [get_clocks {clock_main}] -to [get_regs {e_mem/sdram_ctl/sdram_BS* }] -hold  -start 2

// Main -> SDRAM Data
set_multicycle_path -from [get_clocks {clock_main}] -to [get_regs {e_mem/sdram_ctl/r_D_wr*   }] -setup -start 3
set_multicycle_path -from [get_clocks {clock_main}] -to [get_regs {e_mem/sdram_ctl/r_D_wr*   }] -hold  -start 2

// SDRAM Data -> Main
set_multicycle_path -from [get_regs {e_mem/sdram_ctl/ctl_D_rd*}] -to [get_clocks {clock_main }] -setup -end   3
set_multicycle_path -from [get_regs {e_mem/sdram_ctl/ctl_D_rd*}] -to [get_clocks {clock_main }] -hold  -end   2

// Avoid false paths that read and write the SDRAM in the same cycle via the CPU
set_false_path      -from [get_regs {e_mem/sdram_ctl/ctl_D_rd*}] -to [get_regs {e_mem/sdram_ctl/r_D_wr*}]
