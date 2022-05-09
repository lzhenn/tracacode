#!/bin/bash

#-------------------------------------------------------------
# ***You may search keyword 'User' to specify your options.***
#-------------------------------------------------------------


#------------------------------------------------------------
# Juli's script modified 
# set variables specific to case, change camroot, namelist
# 12/08/09: EXCLUDED several fields using fexcl1
# 13/07/14: EXCLUDED some more fields
#------------------------------------------------------------
#
# Last modified by Zhenning Li to port on SAVIO@Berkely
#
# Major modifications:
#
#   -Remove stop_n/stop_option and add start_ymd/stop_ymd
#   to fit legacy namelist variables
#
#   -Replace the FC 'ifort' by 'mpif90' and CC 'icc' by
#   'mpicc' in configure line
#
#   -Set NetCDF and MPI related environmental variables
#
#   -Comment the data mv commands after running
#
#   -Add and modify some comments
#                                       Nov 4, 2016
#-------------------------------------------------------------
#   Caution: Makefile in $cfgdir has been modified (append 
#   "-lnetcdff" flag to Fortran compiling line to fit NetCDF4
#   requirements)
#-------------------------------------------------------------




# -----***User-defined options***-------
# Set you case name
CASE='test-dom'

# Set the case path, pwd/$case is recommended
WRKDIR=`pwd`/$CASE

# Set the start yyyymmdd
START_YMD=00010101

# Set the stop yyyymmdd
STOP_YMD=00020101

# Set Ocean model (dom|som)
OM_FLAG='dom'

# Set if MPI tasks involved (nospmd|spmd)
SPMD_FLAG='spmd'

# Set the CPUs you hope to use (1 node with 20 CPUs)
NPES=20

# Set Wall Hour
WALL_HOUR=24
# -----***User-defined options***-------

# -------Operation--------


echo "Case is $CASE with start_ymd = '$START_YMD', and stop_ymd='$STOP_YMD'"

echo "Setting netcdf environment variables."

export MPI_ROOT=/global/software/sl-6.x86_64/modules/intel/2013_sp1.4.211/openmpi/1.6.5-intel
export INC_NETCDF=$NETCDF_DIR/include
export LIB_NETCDF=$NETCDF_DIR/lib
export INC_MPI=$MPI_ROOT/include
export LIB_MPI=$MPI_ROOT/lib

echo "done"

echo "Setting root of CAM and CAM data distributions."

export CAMROOT=/global/home/groups/co_aiolos/models/CAM3.1
export CSMDATA=/global/home/groups/co_aiolos/models/CAM3_input

echo "done"

# $BLDDIR is the directory where model will be compiled.
# $CFGDIR is the directory containing the CAM configuration scripts.
echo "Setting directories for configure/build/run."
  BLDDIR=$WRKDIR/bld
  CFGDIR=$CAMROOT/models/atm/cam/bld 
  ARCDIR=$RUNDIR
  if [ ! -d "$ARCDIR" ]; then
    mkdir $ARCDIR
  fi
echo "done"

# Ensure that run and build directories exist
mkdir -p $WRKDIR
mkdir -p $BLDDIR

#check if executable exists, if not build
if [ ! -e "$BLDDIR/cam" ]; then

  cd $BLDDIR

# -----***User-defined options***-------
  $CFGDIR/configure -fc mpif90 -cc mpicc -dyn eul -ocn $OM_FLAG -$SPMD_FLAG -cachedir $BLDDIR -test
# -----***User-defined options***-------
  
  rm -f Depends

  # Compile
  gmake -j 8
else

  echo "executable already exists."

fi


# start_tod: start time of day as sec past midnight, default=0
# nhtfrq: write frequency of history file, default=0 (monthly)
# inithist: frq of initial file output

cd $BLDDIR
# -----***User-defined options***-------
 $CFGDIR/build-namelist -case $CASE -test\
 -namelist  "&camexp start_ymd=$START_YMD start_tod=0 stop_ymd=$STOP_YMD /"
# -----***User-defined options***-------

#move cam executable to run directory
#cd $rundir
#mv $blddir/cam .
#mv $blddir/*in .
#Edited 13/07/01, cp run.slurm instead of run.hadley due to server upgrade to slurm
#cp /clusterfs/hadley/scratch/jchiang/RunDoc/run.hadley .
#cp /clusterfs/hadley/scratch/jchiang/RunDoc/run.slurm .
#cp /clusterfs/hadley/scratch/jchiang/RunDoc/PostRun3.5.sh .

echo "Done building cam"
NNODES=$[NPES/20]

#------------------------------------------------
#------Now generate the sbatch submit file-------
#------------------------------------------------
cat << EOF > $WRKDIR/run_job.sh
#!/bin/sh 

# Job name:
#SBATCH --job-name=cam3.1_$CASE
#
# Account:
#SBATCH --account=co_aiolos
#
# Partition:
#SBATCH --partition=savio
#
# Number of nodes needed for use case (example):
#SBATCH --nodes=$NNODES
#
# Number of MPI tasks needed for use case 
#SBATCH --ntasks=$NPES
#
# Processors per task:
#SBATCH --cpus-per-task=1
#
# Wall clock limit:
#SBATCH --time=$WALL_HOUR:00:00
#
#Minimal runscript
mpirun -np $NPES ./bld/cam < ./bld/namelist 

EOF

