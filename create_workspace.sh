#!/bin/sh
#-----------------------------------------------
#   This is a shell script for setting up a
# new workspace of one specific project, You 
# should set the basic parameters as below. 
# Good Luck!
#               Last Modified on  2015-02-05
#               A L_Zealot Product
#-----------------------------------------------

# Name of your workspace
WORKNAME=1911-COAWST

# Now to create the workspace
mkdir $WORKNAME
cd $WORKNAME
mkdir data ncl fig script
cd data
mkdir model obv
cd model
mkdir pre pro
