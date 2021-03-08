#!/bin/bash
#SBATCH -J gba_operational 
#SBATCH -N 2 -c  48 
#SBATCH -o cwstv3.log
TSTMP=`date +%y%m%d%H%M%S`
which mpirun
mpirun -np 48 ./coawstM ./Projects/GBA_operational/coupling_gba.in #>& cwstv3.${TSTMP}.log
#mpirun -np 48 ./coawstM ./Projects/GONI/coupling_goni.in #>& cwstv3.${TSTMP}.log
