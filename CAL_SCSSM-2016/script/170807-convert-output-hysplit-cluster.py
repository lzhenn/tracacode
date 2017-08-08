#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
#
#       L_Zealot
#       Feb 28, 2017
#
#
import datetime
#---------------------------
# Function definition
#---------------------------

# get traj end points with 
def get_inner_points(fn, latS, latN, lonW, lonE):
    # open the sample file
    fr = open(fn, 'r')     
    lines=fr.readlines()
    fr.close()
    pt_dic={}
    for pos_line, point in enumerate(lines):
        content=point.split() # [0]--# [1]--timestep [2]--lat [3]--lon [4]--pressure
        pt_id=str(content[0])
        ts=abs(int(float(content[1])))
        lat=float(content[2])
        lon=float(content[3])
        if ts > 0:
            break
        if (lat<=latN and lat>=latS and lon<=lonE and lon>=lonW):            
            pt_dic[pt_id]={'lat':lat, 'lon':lon}
    return pt_dic

# move other points to center point
def trans_points():
    exit()

year_start=1979

# Which level
p_level=700

# Region
latS=5
latN=15
lonW=87.5
lonE=105

# parser path
inv_path='/Users/zhenningli/data/CAL_SCSSM-2016/back_traj/CAL_SCSSM-2016/'
out_path='/Users/zhenningli/data/CAL_SCSSM-2016/back_traj/CAL_SCSSM-2016/post_process/'

latC=(latS+latN)/2.0
lonC=(lonW+lonE)/2.0

onset_date=[125,136,133,134,143,108,136,123,119,119,128,105,110,132,134,114,126,112,133,132,93,100,115,114,127,118,123,107,116,112,99,134,113,119,123]
day_shift=-2


#Parser
init_time = datetime.datetime(year_start, 1, 1, 0)
init_time += datetime.timedelta(days=((onset_date[0]-1)+day_shift))
time_stamp=init_time.strftime('%Y%m%d%H')

print('Parsing points list...')
filename=inv_path+time_stamp+'-'+str(p_level)+'hPa.txt'
print('Sample File:'+filename)
pt_dic=get_inner_points(filename, latS, latN, lonW, lonE)
for keys,values in pt_dic.items():
    print(keys)
    print(values)
exit()
for year in range(year_start,year_start+len(onset_date),1):
        
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
        if  ts in range(1,25) and (pt_id in inner_pt_dic):
            fr1.write('%6s %6s %3d %8.3f %8.3f\n' % (pt_id, time_stamp, ts, lat, lon))
    int_time_obj = int_time_obj+time_delta
fr1.close()
exit()




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

while int_time_obj <= end_time_obj:
    print('parsing '+int_time_obj.strftime('%y%m%d%H')+'...')
    fn='forward_'+int_time_obj.strftime('%y%m%d%H')
    fr = open(inv_path+fn, 'r')
    lines=fr.readlines()
    fr.close()
    lines0=lines[npoints+4:] 
    len_line0=len(lines0)
    for pos_line, point in enumerate(lines0):
        content=point.split() # [0]--# [9]--lat [10]--lon
        pt_id=str(content[0])
        lat=float(content[9])
        lon=float(content[10])
        if pos_line % 2000 ==0:
            print('Line'+str(pos_line)+'/'+str(len_line0))
        if pt_id in pt_dic:
            if (lat>latmx) or (lat<latmn) or (lon>lonmx) or (lon<lonmn):
                continue 
            for [latx, lonx] in inner_pt_dic.values():
                if abs(lat-latx)+abs(lon-lonx) <=0.09:
                    pt_dic[pt_id]['value']=pt_dic[pt_id]['value']+1
                    break
        # For: Find if pt inner PRD
    init_time = datetime.datetime(year, 1, 1, 0)
    init_time += datetime.timedelta(days=((onset_date[year-year_start]-1)-left_shift_day))

    time_stamp=init_time.strftime('%y%m%d')
    print('parsing '+time_stamp+'...')


    # For: All pts in file
    
    fr2=open(inv_path+'record_'+int_time_obj.strftime('%y%m%d%H')+'.txt','w')
    for item in pt_dic.values():
        lat=item['lat']
        lon=item['lon']
        value=item['value']
        fr2.write('%8.3f %8.3f %4d\n' % (lat, lon, value))
    fr2.close()
    for idx in pt_dic:
        pt_dic[idx]['value']=0
# While: All experiments


