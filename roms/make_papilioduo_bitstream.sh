#!/bin/bash

run_data2mem=true

XILINX=/opt/Xilinx/14.7
DATA2MEM=${XILINX}/ISE_DS/ISE/bin/lin/data2mem
PAPILIO_LOADER=/opt/GadgetFactory/papilio-loader/programmer
PROG=${PAPILIO_LOADER}/linux32/papilio-prog
BSCAN=${PAPILIO_LOADER}/bscan_spi_xc6slx9.bit

# Image for Phill's RAM ROM Board
IMAGE=128K_avr.rom

# Image for Atom 2015
#IMAGE=os15-11.rom

mkdir -p tmp

# Build a fresh ROM image
./make_ramrom_phill_image.sh

# Run bitmerge to merge in the ROM images
gcc -o tmp/bitmerge bitmerge.c 
./tmp/bitmerge ../xilinx/working/AtomFpga_PapilioDuo.bit 60000:$IMAGE tmp/merged.bit
rm -f ./tmp/bitmerge

# Run data2mem to merge in the AVR Firmware
if [ $run_data2mem = "true" ]; then
echo Merging AVR firmware
BMM_FILE=../xilinx/AtomFpga_PapilioDuo_bd.bmm
${DATA2MEM} -bm ${BMM_FILE} -bd avr_progmem.mem -bt tmp/merged.bit -o b tmp/merged2.bit
mv tmp/merged2.bit tmp/merged.bit
fi

# Program the Papilo Duo
${PROG} -v -f tmp/merged.bit -b ${BSCAN}  -sa -r

# Reset the Papilio Duo
${PROG} -c
