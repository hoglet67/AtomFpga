#!/bin/bash

# Allow the script to continue if a ghdl is interrupted
trap ' ' INT

OPTIONS="--std=93 --ieee=synopsys -fexplicit --syn-binding -Wno-hide"

# 116ms is enough to Boot the OS, start SDDOS, and get the INTERFACE? error
SIMOPTIONS=" --ieee-asserts=disable --stop-time=116ms"

#SIMOPTIONS="$SIMOPTIONS --vcd=dump.vcd"

echo "Analyzing VHDL..."

# Dummy Modules
ghdl -a $OPTIONS AVR8.vhd
ghdl -a $OPTIONS dvi_tx.vhd

# Note, the simulation has a InternalROM impl in VHDL (the FPGA uses a
# Verilog impl)

ghdl -a $OPTIONS prim_sim.vhd
ghdl -a $OPTIONS InternalROM.vhd
ghdl -a $OPTIONS ../src/dpram_8k/dpram_8k.vhd
ghdl -a $OPTIONS ../src/VideoRam.vhd
ghdl -a $OPTIONS ../src/tmds_encoder.vhd
ghdl -a $OPTIONS ../../../src/common/AlanD/R65Cx2.vhd
ghdl -a $OPTIONS ../../../src/common/T6502/T65_Pack.vhd
ghdl -a $OPTIONS ../../../src/common/T6502/T65_ALU.vhd
ghdl -a $OPTIONS ../../../src/common/T6502/T65_MCode.vhd
ghdl -a $OPTIONS ../../../src/common/T6502/T65.vhd
ghdl -a $OPTIONS ../../../src/common/CpuWrapper.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/MC6847/CharRam.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/MC6847/CharRom.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/MC6847/mc6847.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/MINIUART/Rxunit.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/MINIUART/Txunit.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/MINIUART/utils.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/MINIUART/miniuart.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/mouse/mouse_controller.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/mouse/ps2interface.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/mouse/resolution_mouse_informer.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/mouse/MouseRefComp.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/pointer/PointerRamBlack.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/pointer/PointerRamWhite.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/pointer/Pointer.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/SID/sid_components.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/SID/sid_coeffs.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/SID/sid_filters.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/SID/sid_voice.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/SID/sid_6581.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/VGA80x40/ctrm.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/VGA80x40/losr.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/VGA80x40/vga80x40.vhd
ghdl -a $OPTIONS ../../../src/common/AtomGodilVideo/AtomGodilVideo.vhd
ghdl -a $OPTIONS ../../../src/common/AtomPL8.vhd
ghdl -a $OPTIONS ../../../src/common/i82C55/i82c55.vhd
ghdl -a $OPTIONS ../../../src/common/MC6522/m6522.vhd
ghdl -a $OPTIONS ../../../src/common/ps2kybrd/ps2_intf.vhd
ghdl -a $OPTIONS ../../../src/common/ps2kybrd/keyboard.vhd
#ghdl -a $OPTIONS ../../../src/common/RAM/RAM_2K.vhd
#ghdl -a $OPTIONS ../../../src/common/RAM/RAM_8K.vhd
ghdl -a $OPTIONS ../../../src/common/RAM/RAM_16K.vhd
ghdl -a $OPTIONS ../../../src/common/RamRom_Atom2015.vhd
ghdl -a $OPTIONS ../../../src/common/RamRom_None.vhd
ghdl -a $OPTIONS ../../../src/common/RamRom_Phill.vhd
ghdl -a $OPTIONS ../../../src/common/RamRom_SchakelKaart.vhd
ghdl -a $OPTIONS ../../../src/common/SPI/spi.vhd
ghdl -a $OPTIONS ../../../src/common/AtomFpga_Core.vhd
ghdl -a $OPTIONS ../src/AtomFpga_TangNano9K.vhd
ghdl -a $OPTIONS test_bench.vhd

echo "Elaborating VHDL..."
ghdl -e $OPTIONS $GENERICS test_bench

echo "Running Simulation (takes about 15 minutes)..."
time ghdl -r  $OPTIONS test_bench $SIMOPTIONS | tee log

echo "Decoding trace file..."
grep "trace" log  | cut -d: -f7 | tail +53 | xxd -r -p | dd conv=swab status=none | decode6502 --machine=atom --cpu=6502 -ahiys --phi2= --rst= --sync= --mem=00f > trace

ls -l log trace

echo Log contains `grep trace log | wc -l` cycles
echo Instruction trace contains `wc -l <trace` instructions

head trace
echo ...
tail trace

echo Instruction trace makes the following calls to OSWRCH
grep "JSR FFF4" trace
