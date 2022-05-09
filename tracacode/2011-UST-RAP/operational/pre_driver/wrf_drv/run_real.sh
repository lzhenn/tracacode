#!/bin/bash

LID_NLS=$1
LID_NLE=$2
WRFDIR=$3
WPSDIR=$4

echo ">>>>WRF-REAL:Clean Pre-existed Files..."
CURRDIR=`pwd`
cd $WRFDIR

YYYY_NLS=${LID_NLS:0:4}
YYYY_NLE=${LID_NLE:0:4}

MM_NLS=${LID_NLS:4:2}
MM_NLE=${LID_NLE:4:2}

DD_NLS=${LID_NLS:6:2}
DD_NLE=${LID_NLE:6:2}


sed -i "/start_year/s/^.*$/ start_year                          = ${YYYY_NLS}, ${YYYY_NLS}, ${YYYY_NLS}, ${YYYY_NLS},/g" namelist.input
sed -i "/end_year/s/^.*$/ end_year                            = ${YYYY_NLE}, ${YYYY_NLE}, ${YYYY_NLE}, ${YYYY_NLE},/g" namelist.input
sed -i "/start_month/s/^.*$/ start_month                          = ${MM_NLS}, ${MM_NLS}, ${MM_NLS}, ${MM_NLS},/g" namelist.input
sed -i "/end_month/s/^.*$/ end_month                          = ${MM_NLE}, ${MM_NLE}, ${MM_NLE}, ${MM_NLE},/g" namelist.input
sed -i "/start_day/s/^.*$/ start_day                          = ${DD_NLS}, ${DD_NLS}, ${DD_NLS}, ${DD_NLS},/g" namelist.input
sed -i "/end_day/s/^.*$/ end_day                          = ${DD_NLE}, ${DD_NLE}, ${DD_NLE}, ${DD_NLE},/g" namelist.input

rm -f met_em.d0*
rm -f wrfout_d0*
rm -f wrfinput_d0*
rm -f wrflowinp_d0*
rm -f wrfbdy_d0*
rm -f wrffda*

echo ">>>>WRF-REAL: Run real.exe..."
ln -sf $WPSDIR/met_em.d0* ./
mpirun -np 16 ./real.exe 

cd $CURRDIR
