#!/bin/bash

ROM=fpgautils

ca65 -l${ROM}.lst  -o ${ROM}.o ${ROM}.asm 
ld65 ${ROM}.o -o ${ROM}.rom  -C atom.cfg 
