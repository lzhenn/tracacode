#!/bin/bash

#-----------------------------------------------
#   This is a shell script for setting up a
# new case of CESM, You should set the basic
# parameters as below. Good Luck!
#
# 2014-08-03 Created
# 2014-08-24 Modified: for PE layers
# 2015-01-08 Modified: for PBS generation
#
#                      A L_Zealot Product
#-----------------------------------------------


#*************************************************************
#--------------Below for user defined part--------------------
#*************************************************************

source ~/.bashrc_cesm

# Name of your case, your name to be prefix, e.g. LZN_HEAT
CASENAME=Convc_eff

# Component set of your case
COMPSET=F_2000

#Resolution of your case
RES=f19_f19

#Stop option of your case, should be nyears, nmonths, ndays, etc.
STOP_OPTION=nyears

#Stop N of your case, when stop_option set to be 'nyear' and stop N
#set to 5, it means the model will run for 5 years
STOP_N=5

#How many processors you will use for your case, sequential only
#Multiple of 16, such as 32, 48, 64, 80, 96, 112, 128, etc#
#CAM4 f19 works fine below  96PEs#
#CAM5 f19 works fine below 384PEs. However, there are not so many 
#CPUs for this kind of work#
NTASKS=32

#Which que you will use for your case, such as 'ys', 'few', 'medium',
#and much
QUENAME=ys


#rm -rf $CASENAME




#*************************************************************
#---------------Above for user defined part-------------------
#*************************************************************


#*************Below to execute the change*********************
# WARNING:
#   If you are willing to change anything below, you need to be
# VERY CAUTIOUS to do so.
#*************************************************************


create_newcase -case $CASENAME -compset $COMPSET -res $RES -mach sigon

cd $CASENAME

#Change compile out and run out roots
./xmlchange EXEROOT=`pwd`/exe
./xmlchange RUNDIR=`pwd`/exe

#Change PE layers
./xmlchange NTASKS_ATM=$NTASKS
./xmlchange NTASKS_LND=$NTASKS
./xmlchange NTASKS_ICE=$NTASKS
./xmlchange NTASKS_OCN=$NTASKS
./xmlchange NTASKS_GLC=$NTASKS
./xmlchange NTASKS_WAV=$NTASKS
./xmlchange NTASKS_ROF=$NTASKS
./xmlchange NTASKS_CPL=$NTASKS

./cesm_setup

#Compile Process, It will take long...
./${CASENAME}.build

#Link the input data to your caseroot,
#NEVER POLLUTE THE ORIGINAL INPUTROOT!!!
#link_dirtree $CSMDATA ./input

#./xmlchange DIN_LOC_ROOT=`pwd`/input

./xmlchange STOP_OPTION=$STOP_OPTION
./xmlchange STOP_N=$STOP_N

#Deal with que and nodes
NNODES=$[NTASKS/16]

if [ $QUENAME = "ys" ]; then
    WALLTIME=999
elif [ $QUENAME = "few" ]; then
    WALLTIME=720
elif [ $QUENAME = "medium" ]; then
    WALLTIME=168
else
    WALLTIME=48
fi

#--------------------------------------
#------Now generate the pbs file-------
#--------------------------------------
cat << EOF > run.pbs
#!/bin/sh
#PBS -N cjx_$CASENAME
#PBS -q $QUENAME
#PBS -l walltime=$WALLTIME:00:00
#PBS -l nodes=$NNODES:ppn=16
#PBS -r n
#PBS -o cesmrun.log
#PBS -e cesmrun.err
#PBS -V 
echo "This jobs is "\$PBS_JOBID@\$PBS_QUEUE
echo running >& \$EXEROOT/../run_status
MPIBIN=/public/mpi/mvapich2-18-intel/bin
cd \$EXEROOT
\$MPIBIN/mpirun -np $NTASKS -hostfile \$PBS_NODEFILE  ./cesm.exe >& ../run.log
echo finished >& \$EXEROOT/../run_status
EOF
