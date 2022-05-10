#!/bin/bash

#-----------------------------------------------
#   This is a shell script for setting up a
# new case of CESM, You should set the basic
# parameters as below. Good Luck!
#
# 2014-08-03 Created
# 2014-08-24 Modified: for PE layers
# 2015-01-08 Modified: for PBS generation
# 2015-03-26 Modeifed: for TH-2A
#                      A L_Zealot Product
#-----------------------------------------------


#*************************************************************
#--------------Below for user defined part--------------------
#*************************************************************

#source ~/.bashrc_sp-cam
# Name of your case, your name to be prefix, e.g. LZN_HEAT
CASENAME=fSSTfCP

# Component set of your case
COMPSET=F_AMIP

#Resolution of your case
RES=f19_f19

#Stop option of your case, should be nyears, nmonths, ndays, etc.
STOP_OPTION=nyears

#Stop N of your case, when stop_option set to be 'nyear' and stop N
#set to 5, it means the model will run for 5 years
STOP_N=30

#How many processors you will use for your case, sequential only
#Multiple of 24, such as 48, 72, 96, 120, 144, etc#
#CAM4 f19 works fine below  96PEs#
#CAM5 f19 works fine below 384PEs. However, there are not so many 
#CPUs for this kind of work#
NTASKS=144

#Which que you will use for your case, such as 'ys', 'few', 'medium',
#and much
QUENAME=work


#rm -rf $CASENAME




#*************************************************************
#---------------Above for user defined part-------------------
#*************************************************************


#*************Below to execute the change*********************
# WARNING:
#   If you are willing to change anything below, you need to be
# VERY CAUTIOUS to do so.
#*************************************************************


create_newcase -case $CASENAME -compset $COMPSET -res $RES -mach th2-lzn

cd $CASENAME

EXEROOT=`pwd`/bld
#Change compile out and run out roots
./xmlchange EXEROOT=`pwd`/bld
./xmlchange RUNDIR=`pwd`/run

#Change PE layers
./xmlchange NTASKS_ATM=$NTASKS
./xmlchange NTASKS_LND=$NTASKS
./xmlchange NTASKS_ICE=$NTASKS
./xmlchange NTASKS_OCN=$NTASKS
./xmlchange NTASKS_GLC=$NTASKS
./xmlchange NTASKS_ROF=$NTASKS
./xmlchange NTASKS_CPL=$NTASKS
./cesm_setup

#Compile Process, It will take long...
#./${CASENAME}.build

#Link the input data to your caseroot,
#NEVER POLLUTE THE ORIGINAL INPUTROOT!!!
#link_dirtree $CSMDATA ./input

#./xmlchange DIN_LOC_ROOT=`pwd`/input

./xmlchange STOP_OPTION=$STOP_OPTION
./xmlchange STOP_N=$STOP_N

