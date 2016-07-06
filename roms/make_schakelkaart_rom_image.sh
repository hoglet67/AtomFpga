#!/bin/bash


ROM=tmp/schakelkaart.rom

rm -f ${ROM}
touch ${ROM}

cat blank.rom >> ${ROM}
cat gags_v2.3.rom >> ${ROM}
cat pcharme_v1.73.rom >> ${ROM}
cat axr1.rom >> ${ROM}
cat fpgautils.rom >> ${ROM}
cat atomic_windows_v1.1.rom >> ${ROM}
cat we_rom.rom >> ${ROM}
cat pp_toolkit.rom >> ${ROM}

cat blank.rom >> ${ROM}
cat bran_1000.rom >> ${ROM}
cat blank.rom >> ${ROM}
cat blank.rom >> ${ROM}

cat abasic.rom >> ${ROM}
cat afloat_patched_1000.rom >> ${ROM}
cat ../software/sdrom/SDROM.rom >> ${ROM}
cat akernel_patched.rom >> ${ROM}
