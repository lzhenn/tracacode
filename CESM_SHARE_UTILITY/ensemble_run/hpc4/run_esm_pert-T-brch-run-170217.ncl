#!/bin/bash

#-----------------------------------------------
#   This is a shell script for setting up a
# multi-sub ensemble tasks by perturbing the 
# initial T field with white noise. You should 
# set the basic parameters as below. Good Luck!
#
# 2015-11-17 Created
# 2017-01-16 Change to fit HPC4
# 2017-02-17 Change to fit branch pert
#
#                      A L_Zealot Product
#-----------------------------------------------

#=========================================================
# 1. The following namelist variables must be set properly
# in your case env_run.xml
#
#   RUN_TYPE="hybrid" (and relavant configurations)
#
# 2. Please set "ncdata" namelist variable in user_nl_cam,
# which share the same name as BRCH_NAME 
#
# 3. Please check your specific init conditions and restart
# files are in the proper dir, also provide your rpointers 
# in a separate dir
#=========================================================

#*************************************************************
#--------------Below for user defined part--------------------
#*************************************************************
source ~/.bashrc_cesm
alias task="/opt/gridview/pbs/dispatcher/bin/qstat -u yangsong3"

# Workspace Path
WPATH=/users/yangsong3/L_Zealot/B/B20f19-spun-up

# Case Name
CASENAME=`basename $WPATH`

# Storage Path
SPATH=/users/yangsong3/L_Zealot/B/DATA_B20f19-spun-up

# Storage Dir Prefix 
SDPRE=ESMs_

# Init Dir PATH (must be a separate dir)
BRCH_DIR=$WPATH/brch

# Init File Name (same as ncdata in user_nl_cam)
BRCH_NAME=B20f19-spun-up.cam.r.0252-01-01-00000.nc

# Ensemble Members
N_ESM=5

# Standard Divation of Normal Distributed Perturbation in T Field (Kelvin)
T_PURB=0.02


#*************Below to execute the changes*********************
# WARNING:
#   If you are willing to change anything below, you need to be
# VERY CAREFUL to do so.
#*************************************************************
echo "                                                              "
echo "*******************CESM ENSEMBLE RUN SCRIPT*******************"
echo "You may use this script with full access, and any kind of     "
echo "redistribution. It's totally Open-sourced!                    "
echo "                                                              "
echo "     Contact: http://met.sysu.edu.cn/GloCli/Team/?page_id=1008"
echo "                                            A L_Zealot Product"
echo "                                                    2016/12/18"
echo "**************************************************************"
echo "                                                              "

echo "Current working PATH: ${WPATH}"
# Init DIR Validation
if [ $BRCH_DIR == "" ] || [ ! -d $BRCH_DIR ]; then
    echo "PATH: \"${BRCH_DIR}\" NO FOUND! Please check it!"
    exit 1
fi

# Backup rpointer files and initial files 
RP_DIR=${WPATH}/rpoint
if [ ! -d $RP_DIR ]; then
    mkdir $RP_DIR
fi
cp ${WPATH}/exe/rpoint* $RP_DIR

if [ ! -f  $BRCH_DIR/${BRCH_NAME}.org ]; then
    cp $BRCH_DIR/${BRCH_NAME} $BRCH_DIR/${BRCH_NAME}.org
else
    cp $BRCH_DIR/${BRCH_NAME}.org $BRCH_DIR/${BRCH_NAME}
fi


# Clean the cesm.log 
if [ -f  $WPATH/run.log ]; then
    rm $WPATH/run.log
fi


NCL_BRCH_PATH=\"${BRCH_DIR}/${BRCH_NAME}/\"
# Main Loop
for II in `seq 1 $N_ESM`
do
    echo "ESM${II}/${N_ESM}, with restart condition: ${BRCH_NAME}, is processing!"
 
    # Perturb initial filed
    ncl -nQ pre_dir=$NCL_BRCH_PATH  \
        t_purb=$T_PURB              \
        ../ncl/perturb_brch_T-170217.ncl

    # Submit task
    $WPATH/$CASENAME.run 
    echo "ESM${II}/${N_ESM}, with perturbated restart condition: ${BRCH_NAME}, has been submitted!"
    
    #Check status
    while [ ! -f "$WPATH/run.log" ]
    do
        TASK=`task | grep lzn`
        if [ -n "$TASK" ]; then
            echo "Task on but run.log not found, will try another time..."    
            sleep 60
        else
            echo "No task info and no run.log, error may occur..."
            exit
        fi
    done

    # Loop until finished
    while [ "1" == "1" ]
    do
        
        # Check status
        LOG_SIZE0=`ls -l ${WPATH}/run.log | awk '{ print $5 }'`
        echo "run.log with size ${LOG_SIZE0} byte detected."

        sleep 300
        
        LOG_SIZE1=`ls -l ${WPATH}/run.log | awk '{ print $5 }'`
        
        if [ "$LOG_SIZE0" -eq "$LOG_SIZE1" -a $LOG_SIZE1 -gt 102400 ]; then
            
            TASK=`task | grep lzn`
            if [ -n "$TASK" ]; then
                echo "Still found running task, wait next test or interupt.."
            else
                FINISH=$(date)" ESM${II}/${N_ESM} finished!!! "
                echo "                                  "
                echo "**********************************"
                echo $FINISH
                echo "**********************************"
                echo "                                  "
                
                # post process the output
                echo "Post process, moving history files..."
                if [ ! -d $SPATH ]; then
                    mkdir $SPATH
                fi
                mkdir $SPATH/${SDPRE}${II}
                mv $WPATH/exe/*cam.h1* $SPATH/${SDPRE}${II}
                mv $WPATH/exe/*cam.h0* $SPATH/${SDPRE}${II}
                mv $WPATH/exe/*pop.h* $SPATH/${SDPRE}${II}
                mv $WPATH/run.log $SPATH/${SDPRE}${II}
                break

            fi
        else
            if [ "$LOG_SIZE0" -eq "$LOG_SIZE1" ]; then
                echo "Log file size increment stopped, please check if ESM${II}/${N_ESM} failed."
                exit
            else
                DIFF_LOG_SIZ=`expr $LOG_SIZE1 - $LOG_SIZE0`
                TIMER=$(date)" ${CASENAME} ESM${II}/${N_ESM} with size increment $DIFF_LOG_SIZ is still running..."
                echo $TIMER
            fi
        fi
    done
    
    # Move back the init file
    cp  $BRCH_DIR/${BRCH_NAME}.org $BRCH_DIR/$BRCH_NAME
 
    # Move back the rpointers
    cp  $RP_DIR/* ${WPATH}/exe/
    
    if [ $II == $N_ESM ]; then
        echo "                                                              "
        echo "*******************CESM ENSEMBLE RUN SCRIPT*******************"
        echo "                                                              "
        echo "                                                              "
        echo "              CONGRATULATIONS!!! ALL TASKS DONE!!!            "
        echo "                                                              "
        echo "                                                              "
        echo "                                            A L_Zealot Product"
        echo "                                                    2016/12/18"
        echo "**************************************************************"
        echo "                                                              "
    fi
done


