#!/bin/sh

TASK=`yhqueue | grep NAME`
if [ -n "$TASK" ]; then
    echo "Task on but cesm.log not found, will try another time..."    
    sleep 60
else
    echo "No task info and no cesm.log, error may occur..."
    exit
fi

