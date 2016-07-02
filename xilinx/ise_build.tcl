#!/opt/Xilinx/14.7/ISE_DS/ISE/bin/lin/xtclsh
project open AtomFpga_PapilioDuo.xise
process run "Generate Programming File"
project close
project open AtomFpga_PapilioOne.xise
process run "Generate Programming File"
project close
project open AtomFpga_Hoglet.xise
process run "Generate Programming File"
project close
project open AtomFpga_OlimexModVGA.xise
process run "Generate Programming File"
project close
exit

