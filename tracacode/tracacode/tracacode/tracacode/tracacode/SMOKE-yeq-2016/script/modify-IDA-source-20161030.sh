#!/bin/sh
#-----------------------------------------------
#   This is a shell script for modifying SMOKE
# inventory of IDA formatted pollutant sources,
# you should set the basic parameters as below. 
# Good Luck!
#               Last Modified on  2016-10-30
#               A L_Zealot Product
#-----------------------------------------------

# UNFINISHED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# I HATE SHELL!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#--------------------------------User defiend parameters------------------------------------
# Inventory type (options: ARINV/MBINV/PTINV)
INV_TYPE=ARINV

# Inventory file path
INV_PATH=../data/obv/2005/mobile/pathv1_hk_mobile.txt

# Pollutant ID
PT_ID=1

# Headlines
HDL=6

# Output file path
OPT_PATH=../data/obv/2005/mobile/pathv1_hk_mobile-reduced-50pt.txt

# Scaling factor
SCAL_F=0.5

#----------WARNING: Operation below, DO NOT modify unless you know what you are doing-------
if [ -f "$OPT_PATH" ]; then
    rm -rf $OPT_PATH
fi

cat $INV_PATH | head -$HDL > $OPT_PATH # Write the output file head record

if [ "$INV_TYPE" = ARINV ]; then
    BODY=`cat $INV_PATH | tail -n +$(($HDL+1))` # Extract the body of the inventory
    echo $BODY | cut -c 0-62 >> $OPT_PATH
    VALUE=`echo $BODY | cut -c 63-72` # Extract specific pollutant emission value
fi

VALUE_ARR=($VALUE) 
VAL_LEN=${#VALUE_ARR[@]}

for ((II=0; II<$VAL_LEN; II++))
do
    VALUE_ARR[$II]=`echo "${VALUE_ARR[$II]}*$SCAL_F"|bc` # Calculate reduced/amplified emission value
    echo ${VALUE_ARR[$II]}
done
