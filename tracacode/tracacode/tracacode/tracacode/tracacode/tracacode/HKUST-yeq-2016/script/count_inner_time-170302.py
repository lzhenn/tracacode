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
inv_path='/home/yangsong3/data/model/L_Zealot/HKUST_yeq-2016/resident-time_output/data/hysplit/traj_200m/'



#Parser
with open(inv_path+'../inner_point.json', 'r') as f:
        inner_pt_dic = json.load(f)

latmx=0
latmn=100
lonmx=0
lonmn=100
for [latx, lonx] in inner_pt_dic.values():
    if latmx<latx:
        latmx=latx
    if latmn>latx:
        latmn=latx
    
    if lonmx<lonx:
        lonmx=lonx
    if lonmn>lonx:
        lonmn=lonx

pt_dic={}
fr = open(inv_path+'../points', 'r')
point_list=fr.readlines()

for idx, point in enumerate(point_list):
    content=point.split()       # [4]--lat [5]--lon [6]--height
    pt_id =idx+1
    pt_dic[str(pt_id)]={'lat':float(content[4]), 'lon':float(content[5]), 'value': 0}

while int_time_obj <= end_time_obj:
    print('parsing '+int_time_obj.strftime('%y%m%d%H')+'...')
    fn='trajout_'+int_time_obj.strftime('%y%m%d%H')
    fr = open(inv_path+fn, 'r')
    lines=fr.readlines()
    lines0=lines[16724:] 
    len_line0=len(lines0)
    for pos_line, point in enumerate(lines0):
        find_pt=False
        content=point.split() # [0]--# [9]--lat [10]--lon
        pt_id=str(content[0])
        
        lat=float(content[9])
        lon=float(content[10])
        if pos_line % 2000 ==0:
            print('Line'+str(pos_line)+'/'+str(len_line0))
        keys=None
        if (lat>latmx) or (lat<latmn) or (lon>lonmx) or (lon<lonmn):
            continue 

        for [latx, lonx] in inner_pt_dic.values():
            if abs(lat-latx)+abs(lon-lonx) <=0.03:
                pt_dic[pt_id]['value']=pt_dic[pt_id]['value']+1
                break

    jsObj = json.dumps(pt_dic)  
      
    fileObject = open(inv_path+'record_'+int_time_obj.strftime('%y%m%d%H')+'.json', 'w')  
    fileObject.write(jsObj)  
    fileObject.close()  
    int_time_obj = int_time_obj+time_delta
# While: All experiments


