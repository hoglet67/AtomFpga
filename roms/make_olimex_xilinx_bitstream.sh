#!/bin/bash

run_data2mem=true

XILINX=/opt/Xilinx/14.7
DATA2MEM=${XILINX}/ISE_DS/ISE/bin/lin/data2mem

IMAGE=tmp/olimex.rom

mkdir -p tmp

# Build the Olimex ROM image
cat blank.rom blank.rom fpgautils.rom blank.rom abasic.rom afloat.rom ../software/sdrom/SDROM.rom akernel_patched.rom  > $IMAGE

# Run bitmerge to merge in the ROM images

# For some reason, the image is offset in the .MCS file by 0x26 bytes
# so we correct for this by passing in 2FFDA rather than 30000
gcc -o tmp/bitmerge bitmerge.c 
./tmp/bitmerge ../xilinx/working/AtomFpga_OlimexModVGA.bit 2FFDA:$IMAGE tmp/AtomFpga_OlimexModVGA.bit

rm -f ./tmp/bitmerge
