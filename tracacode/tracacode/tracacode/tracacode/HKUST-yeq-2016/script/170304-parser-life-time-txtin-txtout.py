#!/usr/bin/python
# -*- coding: UTF-8 -*-
# Find the partical lifetime and indx, merging into inner time
# txt files
#
#       L_Zealot
#       Feb 28, 2017
#
#
import json
import datetime

start_time='2015-01-01 00:00:00'
end_time='2015-01-27 00:00:00'

# Integration step in Hour
int_step=12

# Number of points
npoints=16720

#Operation
int_time_obj = datetime.datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
end_time_obj = datetime.datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')
time_delta=datetime.timedelta(hours=int_step)

# parser path
inv_path='/home/yangsong3/data/model/L_Zealot/HKUST_yeq-2016/resident-time_output/data/hysplit/traj_100m/'


fr = open(inv_path+'../points', 'r')
point_list=fr.readlines()
fr.close()
pt_dic={}
for idx, point in enumerate(point_list):
    content=point.split()       # [4]--lat [5]--lon [6]--height
    pt_id =idx+1
    pt_dic[str(pt_id)]={'lat':float(content[4]), 'lon':float(content[5]), 'value': 0}

while int_time_obj <= end_time_obj:
    print('parsing '+int_time_obj.strftime('%y%m%d%H')+'...')
    fn='trajout_'+int_time_obj.strftime('%y%m%d%H')
    fr = open(inv_path+fn, 'r')
    lines=fr.readlines()
    fr.close()
    lines0=lines[npoints+4:] 
    len_line0=len(lines0)
    for pos_line, point in enumerate(lines0):
        content=point.split() # [0]--# [9]--lat [10]--lon
        pt_id=str(content[0])
        pt_dic[pt_id]['value']=pt_dic[pt_id]['value']+1
    
    fr2=open(inv_path+'life_'+int_time_obj.strftime('%y%m%d%H')+'.txt','w')
    for item in pt_dic.values():
        lat=item['lat']
        lon=item['lon']
        value=item['value']
        fr2.write('%8.3f %8.3f %4d\n' % (lat, lon, value))
    fr2.close()
    for idx in pt_dic:
        pt_dic[idx]['value']=0
    int_time_obj = int_time_obj+time_delta
# While: All experiments


