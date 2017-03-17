#!/usr/bin/python
# -*- coding: UTF-8 -*-

import os
import datetime

year_start=1980


# Integration hours for each experiment
g_int=96

# Initial shift (hr)
g_init_shift=24

# p levels 
p_lvls=[1000,925,850,700,600,500,200]

## For onset problem
#onset_date=[125,136,133,134,143,108,136,123,119,119,128,105,110,132,134,114,126,112,133,132,93,100,115,114,127,118,123,107,116,112,99,134,113,119,123]
onset_date=[136,133,134,143,108,136,123,119,119,128,105,110,132,134,114,126,112,133,132,93,100,115,114,127,118,123,107,116,112,99,134,113,119,123]

## Shift days, simulation start point
left_shift_day=10
right_shift_day=7

for year in range(year_start,year_start+len(onset_date),1):
    
    #Calculate start date for backward trajectroy
    # onset_day-1, 1 Jan + 1 = 2 Jan (Rank: 2)
    init_time = datetime.datetime(year, 1, 1, 0)
    init_time += datetime.timedelta(days=((onset_date[year-year_start]-1)-left_shift_day))
    for init_times in range(-left_shift_day, right_shift_day): 
        # Previous date, similation ending 
        end_time = init_time-datetime.timedelta(hours=g_int)
        fr=open('CONTROL','w')
        fr.write(init_time.strftime('%Y-%m-%d %H:%M:%S\n'))
        fr.write(end_time.strftime('%Y-%m-%d %H:%M:%S\n'))
        for lvl in p_lvls:
            fr.write('%6d'% lvl)
        fr.close()
       
        os.system('python back_traj_model-multi-input-files.py')
        init_time+=datetime.timedelta(hours=24)
