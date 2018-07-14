#!/bin/sh
EC2_ID=../diggler.pem
EC2_PATH=/home/ec2-user/project
TARGET=2018-DD_CUHK/ncl/180205-plot-precip.ncl

scp -i ${EC2_ID} ec2-user@54.251.184.29:${EC2_PATH}/${TARGET} ./${TARGET}
ncl ./${TARGET}


