#!/bin/bash

# Allow the script to continue if a ghdl is interrupted
trap ' ' INT

echo "Compiling iverilog simulation (takes about 1 minute)..."
iverilog -s tb_timing tb_timing.v ../../impl/pnr/AtomFpga_TangNano9K.vo ~/gowin/v1.9.8.11/IDE/simlib/gw1n/prim_tsim.v ../s27kl0642/s27kl0642.v

echo "Running iverilog simulation (takes about 5 minutes)..."
time ./a.out | tee log

echo "Decoding trace file..."
grep "trace" log  | cut -d: -f2 | xxd -r -p | dd conv=swab status=none | decode6502 --machine=atom --cpu=alandc02 -ahiys --phi2= --mem=00f > trace

ls -l log trace

echo Log contains `grep trace log | wc -l` cycles
echo Instruction trace contains `wc -l <trace` instructions

head trace
echo ...
tail trace

echo Instruction trace makes the following calls to OSWRCH
grep "JSR FFF4" trace
