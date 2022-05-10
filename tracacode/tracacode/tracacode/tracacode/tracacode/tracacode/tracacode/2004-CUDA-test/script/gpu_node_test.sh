#!/bin/bash
#SBATCH -J gpu_test 
#SBATCH -N 1
#SBATCH --gres=gpu:GTX1080Ti:1
sleep 3600
