#!/bin/sh

SOURCE=`pwd`/$1 #for the nc filename
OBJ=`date +%y%m%d`-$2
mv $SOURCE $OBJ
