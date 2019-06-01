#!/bin/bash

function make_atm_header {
    file=$1
    load=$2
    exec=$3
    len=$4
    echo -n "$file" > $file
    truncate -s 16 $file
    echo -e -n "\x${load:2:2}" >> $file
    echo -e -n "\x${load:0:2}" >> $file
    echo -e -n "\x${exec:2:2}" >> $file
    echo -e -n "\x${exec:0:2}" >> $file
    echo -e -n "\x${len:2:2}" >> $file
    echo -e -n "\x${len:0:2}" >> $file
}

rm -rf build

# Assembler/linker file name base
ASM=sddos3

# Output file name base
NAME=SDDOS3

for ARCH in AVR PIC
do

    for TARGET in A000 E000
    do

        DIR=build/${ARCH}
        FILE=${NAME}${TARGET:0:1}

        mkdir -p ${DIR}

        LINK=${ASM}-${TARGET,,}.lkr

        echo Assembling ${TARGET} ${ARCH}
        ca65 -l ${DIR}/${FILE}.lst -o tmp.o -D${ARCH} -D${TARGET//0/O} ${ASM}.asm

        echo Linking ${TARGET} ${ARCH} using ${LINK}
        ld65 tmp.o -o ${DIR}/${FILE}.rom -C ${LINK}

        rm -f tmp.o

        pushd ${DIR}
        make_atm_header ${FILE} ${TARGET} ${TARGET} 1000
        cat ${FILE}.rom >> ${FILE}
        md5sum ${FILE}
        md5sum ${FILE}.rom
        popd

    done

done
