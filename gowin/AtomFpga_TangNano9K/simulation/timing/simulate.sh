#!/bin/bash

# This script uses iverilog to do a post-layout simulation of
# AtomFpga_TangNano9K. It is not really a timing simulation, as SDF is
# not well enough supported in iverilog
#
# A custom version of AtomFpga_TangNano9K must be built with the
# following generics:
#   CImplUserFlash   := false;
#   CImplBootstrap   := false;
#   ResetCounterSize := 6;
#
# The simulation test bench pre-loads ../roms/InternalROM.hex into the
# PSRAM model.
#
# The simulation log outputs 6502 trace information which is
# post-processed by 6502decoder (which needs to be on the path).
#
#

# Change this to where your Gowin EDA IDE installation is:
GOWIN_PRIMS=~/gowin/v1.9.8.11/IDE/simlib/gw1n/prim_tsim.v

# CPU used by 6502 decoder
#CPU=alandc02
CPU=6502

# Allow the script to continue if a ghdl is interrupted
trap ' ' INT

echo "Compiling iverilog simulation (takes about 1 minute)..."
iverilog -s tb_timing tb_timing.v ../../impl/pnr/AtomFpga_TangNano9K.vo ${GOWIN_PRIMS} ../s27kl0642/s27kl0642.v

echo "Running iverilog simulation (takes about 5 minutes)..."
unbuffer ./a.out | tee log

echo "Decoding trace file..."
grep "trace" log  | cut -d: -f2 | xxd -r -p | dd conv=swab status=none | decode6502 --machine=atom --cpu=${CPU} -ahiys --phi2= --mem=00f > trace

ls -l log trace

echo Log contains `grep trace log | wc -l` cycles
echo Instruction trace contains `wc -l <trace` instructions

head trace
echo ...
tail trace

echo Instruction trace makes the following calls to OSWRCH
grep "JSR FFF4" trace
