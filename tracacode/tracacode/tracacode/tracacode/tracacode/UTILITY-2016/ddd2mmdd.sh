#!/bin/sh

DDD=$1
SCRIPT_DIR=$HOME_PROJECT/UTILITY-2016/ncl

# -n no line number
# -Q no copyright info
ncl -nQ ddd=$DDD $SCRIPT_DIR/yyyydddtoyyyymmdd-20170807.ncl
