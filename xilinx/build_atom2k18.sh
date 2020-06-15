#!/bin/bash

if [ -z "$1" ]; then
    RELEASE=$(date +"%Y%m%d_%H%M")
else
    RELEASE=$1
fi

DESIGN=AtomFpga_Atom2K18

NAME=$DESIGN_$RELEASE

DIR=../releases/$NAME

echo "Release name: $NAME"

rm -rf $DIR
mkdir -p $DIR

# Build each of the Xilinx designs (different resolutions)

source /opt/Xilinx/14.7/ISE_DS/settings64.sh

#       Design    0  1  2  3  4  5
# CImplCpu65c02   0  1  0  1  0  1
# CImplAtoMMC2    1  1  1  1  0  0
# CImplDebugger   0  0  1  1  1  1

for i in 0 1 2 3 4 5
do

case $i in
    0)
        CImplCpu65c02="false"
         CImplAtoMMC2="true"
        CImplDebugger="false"
        ;;
    1)
        CImplCpu65c02="true"
         CImplAtoMMC2="true"
        CImplDebugger="false"
        ;;
    2)
        CImplCpu65c02="false"
         CImplAtoMMC2="true"
        CImplDebugger="true"
        ;;
    3)
        CImplCpu65c02="true"
         CImplAtoMMC2="true"
        CImplDebugger="true"
        ;;
    4)
        CImplCpu65c02="false"
         CImplAtoMMC2="false"
        CImplDebugger="true"
        ;;
    5)
        CImplCpu65c02="true"
         CImplAtoMMC2="false"
        CImplDebugger="true"
        ;;
esac

echo "   DESIGN_NUM = $i"
echo "CImplCpu65c02 = $CImplCpu65c02"
echo " CImplAtoMMC2 = $CImplAtoMMC2"
echo "CImplDebugger = $CImplDebugger"

mkdir -p working/$i

cat ${DESIGN}.xise | sed "s#working#working/$i#" |
    sed "s#DESIGN_NUM=0#DESIGN_NUM=$i CImplCpu65c02=$CImplCpu65c02 CImplAtoMMC2=$CImplAtoMMC2 CImplDebugger=$CImplDebugger#" > ${DESIGN}_tmp.xise

grep Generics ${DESIGN}_tmp.xise

if [ ! -f working/$i/${DESIGN}.bit ]; then
xtclsh > working/$i.log 2>&1 <<EOF
project open AtomFpga_Atom2K18_tmp.xise
project clean
process run "Generate Programming File"
project close
exit
EOF
fi

promgen -u 0 working/$i/${DESIGN}.bit -o working/$i/${DESIGN}.mcs -p mcs -w -spi -s 512

# Cleanup
rm -f ${DESIGN}_tmp.xise

cp working/$i/${DESIGN}.bit ${DIR}/${DESIGN}_${i}.bit
cp working/$i/${DESIGN}.mcs ${DIR}/${DESIGN}_${i}.mcs

done

# -u 2A0000 working/spare/${DESIGN}.bit          \
# -u 2F4000 working/spare/${DESIGN}.bit          \
# -u 248000 working/spare/${DESIGN}.bit          \
# -u 39C000 working/spare/${DESIGN}.bit          \

promgen                                          \
 -u      0 working/0/${DESIGN}.bit               \
 -u  54000 working/1/${DESIGN}.bit               \
 -u  A8000 working/2/${DESIGN}.bit               \
 -u  FC000 working/3/${DESIGN}.bit               \
 -u 150000 working/4/${DESIGN}.bit               \
 -u 1A4000 working/5/${DESIGN}.bit               \
 -u 1F8000 working/0/${DESIGN}.bit               \
 -u 24C000 working/1/${DESIGN}.bit               \
 -o ${DIR}/${DESIGN}.mcs  -p mcs -w -spi -s 4096


# Zip everything up
cd ../releases
zip -qr $NAME.zip `find $NAME -type f | sort`
echo
unzip -l $NAME.zip
cd ..
