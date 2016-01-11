#!/bin/bash

#---------------------------------------------------
#   This is a shell script for configuring restart
# files. You should set the basic parameters as 
# below. Good Luck!
#
# 2016-01-11 Created
#
#                      A L_Zealot Product
#---------------------------------------------------

#=========================================================
# 1. Plesase set up the case in "hybrid" run, settle your
# runtime, output fields etc. in advance
#=========================================================

#*************************************************************
#--------------Below for user defined part--------------------
#*************************************************************

# Restart Case Name
CASENAME=CAM5_T

# Rpointer files PATH (must be a separate dir)
RP_DIR=/users/yangsong3/L_Zealot/project/CESM_SHARE_UTILITY

# Restart point (in yyyy-mm-dd format)
RPOINT=0666-01-01


#*************Below to execute the changes*********************
# WARNING:
#   If you are willing to change anything below, you need to be
# VERY CAUTIOUS to do so.
#*************************************************************

echo "                                                              "
echo "*****************CESM RESTART CONGFIGURATION******************"
echo "You may use this script with full access, and any kind of     "
echo "redistribution. It's totally Open-sourced!                    "
echo "                                                              "
echo "     Contact: http://met.sysu.edu.cn/GloCli/Team/?page_id=1008"
echo "                                            A L_Zealot Product"
echo "                                                    2015/01/11"
echo "*****************CESM RESTART CONGFIGURATION******************"
echo "                                                              "

#sleep 10


#--------------------------------------
#-----Now generate the rpoint file-----
#--------------------------------------

# rpointer.atm
cat << EOF > $RP_DIR/rpointer.atm
$CASENAME.cam.r.$RPOINT-00000.nc


# The following lists the other files needed for restarts (cam only reads the first line of this file).
# The files below refer to the files needed for the master restart file:HEAT_SCS_MAM-2015.cam.r.0350-01-01-00000.nc
# 
# 
# 
# 
# 
# 
EOF
echo "atm done!"

# rpointer.drv
cat << EOF > $RP_DIR/rpointer.drv
$CASENAME.cpl.r.$RPOINT-00000.nc                                                                                                                                                                                                                     
EOF
echo "drv done!"


# rpointer.ice
cat << EOF > $RP_DIR/rpointer.ice
$CASENAME.cice.r.$RPOINT-00000.nc                                                                                                                                                                                                                     
EOF
echo "ice done!"


# rpointer.lnd
cat << EOF > $RP_DIR/rpointer.lnd
./$CASENAME.clm2.r.$RPOINT-00000.nc                                                                                                                                                                                                                     
EOF
echo "lnd done!"


# rpointer.ocn.ovf
cat << EOF > $RP_DIR/rpointer.ocn.ovf
./$CASENAME.pop.ro.$RPOINT-00000                                                                                                                                                                                                            
EOF
echo "ocn.ovf done!"


# rpointer.ocn.restart
cat << EOF > $RP_DIR/rpointer.ocn.restart
./$CASENAME.pop.r.$RPOINT-00000.nc
RESTART_FMT=nc
EOF
echo "ocn.restart done!"


# rpointer.rof
cat << EOF > $RP_DIR/rpointer.rof
./$CASENAME.rtm.r.$RPOINT-00000.nc                                                                                                                                                                                                                     
EOF
echo "rof done!"


echo "                                                              "
echo "*****************CESM RESTART COMPLETED!!!!!******************"
echo "                                                              "


