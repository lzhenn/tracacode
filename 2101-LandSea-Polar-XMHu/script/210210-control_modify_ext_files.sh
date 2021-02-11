#!/bin/sh
#-----------------------------------------------
#    This is a shell script for configuring the
# preprocessing tool for CESM1.2 fully coupled 
# simlations targeting modifying land-sea 
# distribution.
#  
# Good Luck!
#               Last Modified on  Feb 12, 2021
#               Clear Water Bay, HK
#               A L_Zealot Product
#-----------------------------------------------



# Path of the workspace
WRK_DIR=/home/lzhenn/workspace/xmhu-largerAU/

# Land-sea mask bmp file 
BMP_FN=bitmap_drake_closure.bmp



# Execution
echo "POP M1. Get Ocean Grid by BMP..."
#python 210127-pop2-bmp2imask.py $WRK_DIR $BMP_FN 

echo "POP M2. Change Bathymetry..."
#python 210128-pop2-chg-bathy-accord-imask.py $WRK_DIR

echo "POP M3. Change Region Mask..."
#python 210128-pop2-chg-maskid-accord-imask.py $WRK_DIR

echo "POP M4. Change Initial Fields..."
#python 210128-pop2-chg-init-accord-imask.py $WRK_DIR


echo "CPL M1. Generate Domain Files..."
#sh 210211-gen-cpl-domain.sh

echo "CAM M1. Change Topo and LS Fraction..."
python 210202-cam-chg-topo-accord-ifrac.py $WRK_DIR

echo "CLM M1. Change Soil, PFT ..."
python 210202-clm-chg-surfdata.py $WRK_DIR

echo "Setup Model Experiment..."
#sh 210211-setup-experiment.sh


