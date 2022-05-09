#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
#
#       L_Zealot
#       Feb 28, 2017
#
#
import json
import datetime

start_time='2016-09-01 00:00:00'
end_time='2016-09-30 00:00:00'

# Integration step in Hour
int_step=24

# Number of points
npoints=32224

#Operation
int_time_obj = datetime.datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
end_time_obj = datetime.datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')
time_delta=datetime.timedelta(hours=int_step)

# parser path
inv_path='/home/yangsong3/data/model/L_Zealot/HKUST_yeq-2016/resident-time_output/data/hysplit/xiamen/traj_100m/2016/'

#Parser
with open(inv_path+'../../inner_point.json', 'r') as f:
        inner_pt_dic = json.load(f)




fr1=open(inv_path+'record.txt','w')


while int_time_obj <= end_time_obj:
    time_stamp=int_time_obj.strftime('%y%m%d%H')
    print('parsing '+time_stamp+'...')
    
    # open hyspilt output
    fn='backward_'+time_stamp
    fr = open(inv_path+fn, 'r')
    lines=fr.readlines()
    fr.close()

    lines0=lines[npoints+4:] 
    len_line0=len(lines0)
    for pos_line, point in enumerate(lines0):
        content=point.split() # [0]--# [8]--timestep [9]--lat [10]--lon
        pt_id=str(content[0])
        ts=abs(int(float(content[8])))
        lat=float(content[9])
        lon=float(content[10])
        if  ts in [23, 24, 25, 47, 48, 49] and (pt_id in inner_pt_dic):
            ts_pos = ts - 36
            if ts_pos <0:
                fr1.write('%6s %6s %3d %8.3f %8.3f\n' % (pt_id, time_stamp, ts, lat, lon))
            else:
                fr2.write('%6s %6s %3d %8.3f %8.3f\n' % (pt_id, time_stamp, ts, lat, lon))
    int_time_obj = int_time_obj+time_delta
fr1.close()
exit()

