#!/bin/bash

ROM=extrom2

ca65 -l${ROM}.lst  -o ${ROM}.o ${ROM}.asm 
ld65 ${ROM}.o -o ${ROM}.rom  -C atom.cfg 
