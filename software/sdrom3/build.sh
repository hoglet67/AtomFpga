#!/bin/bash

rm -f *.rom

BASE=sddos3

AVR_A000_ROM=${BASE}-a000-avr.rom
AVR_E000_ROM=${BASE}-e000-avr.rom
PIC_A000_ROM=${BASE}-a000-pic.rom
PIC_E000_ROM=${BASE}-e000-pic.rom


echo Assembling AVR
ca65 -l sddos3.a000.lst -o a000.o -DAVR sddos3.asm
ca65 -l sddos3.e000.lst -o e000.o -DAVR -D EOOO sddos3.asm

echo Linking AVR
ld65 a000.o -o ${AVR_A000_ROM} -C sddos3-a000.lkr
ld65 e000.o -o ${AVR_E000_ROM} -C sddos3-e000.lkr

echo Removing AVR object files
rm -f *.o

echo Assembling PIC
ca65 -l sddos3.a000.lst -o a000.o sddos3.asm
ca65 -l sddos3.e000.lst -o e000.o -D EOOO sddos3.asm

echo Linking PIC
ld65 a000.o -o ${PIC_A000_ROM} -C sddos3-a000.lkr
ld65 e000.o -o ${PIC_E000_ROM} -C sddos3-e000.lkr

echo Removing PIC object files
rm -f *.o

for i in ${AVR_A000_ROM} ${AVR_E000_ROM} ${PIC_A000_ROM} ${PIC_E000_ROM}
do
    truncate -s 4096 $i
done

mkdir -p AVR
mkdir -p PIC
rm -f AVR/*
rm -f PIC/*

xxd -r > AVR/SDDOS3A <<EOF
00: 41 54 4d 4d 43 33 41 00 00 00 00 00 00 00 00 00
10: 00 A0 00 A0 00 10
EOF
cat ${AVR_A000_ROM} >> AVR/SDDOS3A
mv  ${AVR_A000_ROM} AVR/SDDOS3A.rom
md5sum AVR/SDDOS3A.rom

xxd -r > AVR/SDDOS3E <<EOF
00: 41 54 4d 4d 43 33 45 00 00 00 00 00 00 00 00 00
10: 00 E0 00 E0 00 10
EOF
cat ${AVR_E000_ROM} >> AVR/SDDOS3E
mv  ${AVR_E000_ROM} AVR/SDDOS3E.rom
md5sum AVR/SDDOS3E.rom

xxd -r > PIC/SDDOS3A <<EOF
00: 41 54 4d 4d 43 33 41 00 00 00 00 00 00 00 00 00
10: 00 A0 00 A0 00 10
EOF
cat ${PIC_A000_ROM} >> PIC/SDDOS3A
mv  ${PIC_A000_ROM} PIC/SDDOS3A.rom
md5sum PIC/SDDOS3A.rom

xxd -r > PIC/SDDOS3E <<EOF
00: 41 54 4d 4d 43 33 45 00 00 00 00 00 00 00 00 00
10: 00 E0 00 E0 00 10
EOF
cat ${PIC_E000_ROM} >> PIC/SDDOS3E
mv  ${PIC_E000_ROM} PIC/SDDOS3E.rom
md5sum PIC/SDDOS3E.rom
