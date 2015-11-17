#!/bin/bash

#-----------------------------------------------
#   This is a shell script for setting up a
# multi-sub ensemble tasks, especially for daily 
# output experiments. You should set the basic
# parameters as below. Good Luck!
#
# 2015-11-17 Created
#
#                      A L_Zealot Product
#-----------------------------------------------

#=========================================================
# 1. Plesase set up the case in "hybrid" run, settle your
# runtime, output fields etc. in advance
#
# 2. Please set "ncdata" namelist variable in user_nl_cam,
# which share the same name as NC_INIT_F
#
# 3. Please check your specific init conditions and restart
# files are in the proper dir, also provide your rpointers 
# in a separate dir
#=========================================================

#*************************************************************
#--------------Below for user defined part--------------------
#*************************************************************

# Case Name
CASENAME=PRD-Trans-2015

# Init Dir PATH (must be a separate dir)
INIT_DIR=init-pmctrl

# Init File Name (same as ncdata in user_nl_cam)
NC_INIT_F=PRD-Trans-2015.cam.i.0006-01-01-00000.nc

# Rpointer Dir (must be a separate dir)
RP_DIR=rpoint



#*************Below to execute the changes*********************
# WARNING:
#   If you are willing to change anything below, you need to be
# VERY CAUTIOUS to do so.
#*************************************************************
echo "                                                              "
echo "*****************CESM CAM ENSEMBLE RUN SCRIPT*****************"
echo "You may use this script with full access, and any kind of     "
echo "redistribution. It's totally Open-sourced!                    "
echo "                                                              "
echo "     Contact: http://met.sysu.edu.cn/GloCli/Team/?page_id=1008"
echo "                                            A L_Zealot Product"
echo "                                                    2015/11/17"
echo "*****************CESM CAM ENSEMBLE RUN SCRIPT*****************"
echo "                                                              "
sleep 10
WPATH=`pwd`

echo "Current working PATH: ${WPATH}"
# DIR Validation
if [ $INIT_DIR == "" ] || [ ! -d $WPATH/$INIT_DIR ]; then
    echo "PATH: \"${INIT_DIR}\" NO FOUND! Please check it!"
    exit 1
fi
if [ $RP_DIR == "" ] || [ ! -d $WPATH/$RP_DIR ]; then
    echo "PATH: \"${RP_DIR}\" NO FOUND! Please check it!"
    exit 1
fi

# N_ESM Validation
N_ESM=$(ls -l ${WPATH}/${INIT_DIR} | wc -l)
N_ESM=$(($N_ESM-1))
II=1
INIT_FILES=$(ls ${WPATH}/${INIT_DIR})


echo "Total number of ensemble experiments: ${N_ESM}"
for INIT_NAME in $INIT_FILES
do
    if [ ! -f "run_status" ]; then
        echo "Initial run..."
        
        cp $WPATH/$RP_DIR/* $WPATH/exe/
        cp $WPATH/$INIT_DIR/$INIT_NAME $WPATH/exe/$NC_INIT_F
        # submit the task
        echo "ESM${II}, with init condition: ${INIT_NAME}, is processing!"
        $WPATH/$CASENAME.run >& /dev/null
        echo "ESM${II}, with init condition: ${INIT_NAME}, has been submitted!"
        sleep 20
        continue
    fi

    STATUS=$(cat ./run_status)
    
    if [ $STATUS == "running" ] ; then
        while [ "1" == "1" ]
        do
            TIME=$(date)" ESM${II} is still running..."
            echo $TIME
            sleep 300 
            STATUS=$(cat ./run_status)
            if [ $STATUS == "finished" ] ; then

                FINISH=$(date)" ESM${II} is finished!!! "
                echo "                                  "
                echo "**********************************"
                echo $FINISH
                echo "**********************************"
                echo "                                  "
                
                # post process the output
                echo "Post process, moving history files..."
                mkdir $WPATH/exe/esm_$II
                mv $WPATH/exe/*cam.h1* $WPATH/exe/esm_$II

                # renew rpointer and initial data
                echo "Post process, moving rpointer and initial files"
                cp $WPATH/$RP_DIR/* $WPATH/exe/
                cp $WPATH/$INIT_DIR/$INIT_NAME $WPATH/exe/$NC_INIT_F
            
                II=$(($II+1))
                
                # submit the task
                echo "ESM${II}, with init condition: ${INIT_NAME}, is processing!"
                $WPATH/$CASENAME.run >& /dev/null
                echo "ESM${II}, with init condition: ${INIT_NAME}, has been submitted!"
                sleep 20
                break
            fi
        done
    else
        echo "Job may successfully finished before, please check the status"
        exit 0
    fi
done

