#!/bin/bash

function build_64k_rom {

ROM=$1
AVR=$2

echo Building ${ROM}

rm -f ${ROM}
touch ${ROM}

cat sddos-v3.27${AVR}.rom >> ${ROM}
cat gags_v2.3.rom >> ${ROM}
cat pcharme_v1.73.rom >> ${ROM}
cat axr1.rom >> ${ROM}
cat fpgautils.rom >> ${ROM}
cat atomic_windows_v1.1.rom >> ${ROM}
cat we_rom.rom >> ${ROM}
cat pp_toolkit.rom >> ${ROM}

cat abasic.rom >> ${ROM}
cat afloat_patched.rom >> ${ROM}
cat atommc3${AVR}.rom >> ${ROM}
#cat ../software/sdrom/SDROM.rom >> ${ROM}
cat akernel_patched.rom >> ${ROM}

cat abasic.rom >> ${ROM}
cat afloat_patched.rom >> ${ROM}
cat atommc3${AVR}.rom >> ${ROM}
#cat ../software/sdrom/SDROM.rom >> ${ROM}
cat akernel_patched.rom >> ${ROM}

}

function build_16k_rom {

ROM=$1
AVR=$2

echo Building ${ROM}

rm -f ${ROM}
touch ${ROM}

cat abasic.rom >> ${ROM}
cat afloat_patched.rom >> ${ROM}
cat atommc3${AVR}.rom >> ${ROM}
#cat ../software/sdrom/SDROM.rom >> ${ROM}
cat akernel_patched.rom >> ${ROM}

}

build_64k_rom "64K_avr.bin" "_avr"

build_16k_rom "16K_avr.bin" "_avr"

for file in 16K_avr 64K_avr
do
    echo "Building $file.bit"
    echo "ibase=16" > tmp.hex
    echo "obase=2" >> tmp.hex
    od -An -tx1 -w1 -v $file.bin | tr -d " " | tr "a-f" "A-F" >> tmp.hex
    bc < tmp.hex > $file.bit
    rm tmp.hex
done
