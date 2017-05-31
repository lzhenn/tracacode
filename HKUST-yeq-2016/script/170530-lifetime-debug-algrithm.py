#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
#
#       L_Zealot
#       May 1, 2017
#
#
import scipy.io as sio 
from netCDF4 import Dataset
import numpy as np
import json
import datetime
import time
# Time settings
start_time='2015-02-09 00:00:00'
end_time='2015-02-09 00:00:00'

# Integration step in Hour
int_step=24

# Number of points
npoints=16720

# Operation
int_time_obj = datetime.datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
end_time_obj = datetime.datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')
time_delta=datetime.timedelta(hours=int_step)


pt_dic={}
fr = open('/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/HKUST_yeq-2016/resident-time_output/data/hysplit/prd/point-3km-xy-grid', 'r')
point_list=fr.readlines()

for idx, point in enumerate(point_list):
    content=point.split()       # [1]--cor_x [2]--cor_y [3]--lat [4]--lon
    pt_id =idx+1
    pt_dic[str(pt_id)]={'cor_x':int(content[1]), 'cor_y':int(content[2]), 'lat':float(content[3]), 'lon':float(content[4]), 'res_time': 0}

while int_time_obj <= end_time_obj:
    inv_path='/home/yangsong3/data-model/L_Zealot/HKUST_yeq-2016/resident-time_output/data/hysplit/prd/test-output/'
    print('parsing '+int_time_obj.strftime('%y%m%d%H')+'...')
    fn='forward_'+int_time_obj.strftime('%y%m%d%H')
    fr = open(inv_path+fn, 'r')
    lines=fr.readlines()
    lines0=lines[16724:] 
    len_line0=len(lines0)

    # Loop the recordi
    strt_time=time.clock()
    for pos_line, point in enumerate(lines0):
        content=point.split() # [0]--# [9]--lat [10]--lon
        pt_id=str(content[0])

        if pos_line % 10000==0:
            elapsed=time.clock()-strt_time
            print('Line %10d/%10d Time elapsed:%7.3fs pt_id=%6s' % (pos_line, len_line0, elapsed, pt_id))

        pt_dic[pt_id]['res_time']=pt_dic[pt_id]['res_time']+1
    for idx in pt_dic:
        pt_dic[idx]['res_time']=pt_dic[idx]['res_time']/12.0 # adjust the res_time unit to pop*hr


    # output
    fr2=open(inv_path+'res_time/res_'+int_time_obj.strftime('%y%m%d%H')+'.txt','w')
    for item in pt_dic.values():
        cor_x=item['cor_x']
        cor_y=item['cor_y']
        lat=item['lat']
        lon=item['lon']
        value=item['res_time']
        fr2.write('%4d %4d %8.3f %8.3f %6.1f\n' % (cor_x, cor_y, lat, lon, value))
    fr2.close()
    for idx in pt_dic:
        pt_dic[idx]['res_time']=0

    int_time_obj = int_time_obj+time_delta
# While: All experiments


