#!/bin/sh

LID=`date +%y%m%d`

PRO_DIR=`pwd`

#--------------------------
# Mission1: project
#--------------------------
echo "Mission1: project..."
cd $PRO_DIR 

find . -name "*.ncl" | xargs git add
find . -name "*.sh" | xargs git add
find . -name "*.f90" | xargs git add
find . -name "*.cpp" | xargs git add
find . -name "*.c" | xargs git add
find . -name "*.cu" | xargs git add
find . -name "*.F" | xargs git add
find . -name "*.vbs" | xargs git add
find . -name "*.py" | xargs git add
find . -name "*.txt" | xargs git add
find . -name "*.wps" | xargs git add
find . -name "*.csh" | xargs git add
find . -name "*.md" | xargs git add

git add */script/*
git add */SourceMods*

git commit -m "${LID}"
git pull origin master
git push --force origin master
