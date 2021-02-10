#!/bin/sh
#-----------------------------------------------
#    This is a shell script for configuring the
# basic post processing tool for WRF model, 
# targeting the tropical cyclone simulations. You 
# should set the basic parameters as below. 
# Good Luck!
#               Last Modified on  Apr 06, 2020
#               A L_Zealot Product
#-----------------------------------------------



# Path of the workspace
WRK_DIR=/home/lzhenn/workspace/xmhu-largerAU/

# Land-sea mask bmp file 
BMP_FN=bitmap_drake_closure.bmp



# Execution
echo "M1. Get Ocean Grid by BMP..."
python 210127-pop2-bmp2imask.py $WRK_DIR $BMP_FN 

echo "M2. Change Bathymetry..."
python 210128-pop2-chg-bathy-accord-imask.py $WRK_DIR
