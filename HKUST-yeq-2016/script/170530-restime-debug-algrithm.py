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

# parser path


def read_latlon(pfname):
    corfile= Dataset(pfname)
    lat=corfile.variables['LAT'][0,0,:,:]
    lon=corfile.variables['LON'][0,0,:,:]
    return lat, lon

# Get gridsystem
pfname='/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/HKUST_yeq-2016/gridsys/GRIDCRO2D_3km'


print('Initialize Domian grid system...')
lat_mtx, lon_mtx = read_latlon(pfname)
# these all for domian box border
latmax=lat_mtx.max()
latmin=lat_mtx.min()
lonmax=lon_mtx.max()
lonmin=lon_mtx.min()

lat_range0=latmax-latmin
lon_range0=lonmax-lonmin
size_grid=np.shape(lat_mtx)

# Get the inner point
print('Initialize PRD grid system...')
with open('/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/HKUST_yeq-2016/resident-time_output/data/hysplit/prd/inner_point.json', 'r') as f:
    inner_pt_dic = json.load(f)
latmx=0
latmn=100
lonmx=0
lonmn=100
# these all for prd box border
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
fr = open('/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/HKUST_yeq-2016/resident-time_output/data/hysplit/prd/point-3km-xy-grid', 'r')
point_list=fr.readlines()

for idx, point in enumerate(point_list):
    content=point.split()       # [1]--cor_x [2]--cor_y [3]--lat [4]--lon
    pt_id =idx+1
    pt_dic[str(pt_id)]={'cor_x':int(content[1]), 'cor_y':int(content[2]), 'lat':float(content[3]), 'lon':float(content[4]), 'res_time': 0}

# initial min distance threshold to the grid point
min_dis=0.03

while int_time_obj <= end_time_obj:
    inv_path='/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/HKUST_yeq-2016/resident-time_output/data/hysplit/prd/test-output/'
    print('Parsing '+int_time_obj.strftime('%y%m%d%H')+'...')
    fn='forward_'+int_time_obj.strftime('%y%m%d%H')
    fr = open(inv_path+fn, 'r')
    lines=fr.readlines()
    lines0=lines[npoints*2+4:] 
    len_line0=len(lines0)

    # Loop the recordi
    strt_time=time.clock()
    for pos_line, point in enumerate(lines0):
        content=point.split() # [0]--# [9]--lat [10]--lon
        pt_id=str(content[0])
        
        lat=float(content[9])     # traj position
        lon=float(content[10])
 
        if pos_line % 10000==0:
            elapsed=time.clock()-strt_time
            print('Line %10d/%10d Time elapsed:%7.2fs pt_id=%6s' % (pos_line, len_line0, elapsed, pt_id))
      
        # out of the prd box
        if (lat>latmx) or (lat<latmn) or (lon>lonmx) or (lon<lonmn):
            continue 
        
        lat_est=int(size_grid[0]*(lat-latmin)/lat_range0)
        lon_est=int(size_grid[1]*(lon-lonmin)/lon_range0)
        dislat=abs(lat_mtx[lat_est, lon_est]-lat)
        dislon=abs(lon_mtx[lat_est, lon_est]-lon)
        find_flag=False
        cor_x_pos0=lat_est
        cor_y_pos0=lon_est
        curr_id=cor_x_pos0*152+cor_y_pos0+1

        if (dislat+dislon>min_dis):
            for est_x in (0, 1,  -1, 2, -2):
                for est_y in (0, 1, -1, 2, -2):
                    try:
                        dislat=abs(lat_mtx[cor_x_pos+est_x, cor_y_pos+est_y]-lat)
                        dislon=abs(lon_mtx[cor_x_pos+est_x, cor_y_pos+est_y]-lon)
                        if (dislat+dislon<=min_dis):
                            find_flag=True
                            cor_x_pos0=cor_x_pos
                            cor_y_pos0=cor_y_pos
                            curr_id=cor_x_pos0*152+cor_y_pos0+1
                            break
                    except:
                        continue
                if find_flag:
                    break

        if str(curr_id) in inner_pt_dic.keys(): 
            pt_dic[pt_id]['res_time']=pt_dic[pt_id]['res_time']+1
    
    for idx in pt_dic:
        pt_dic[idx]['res_time']=(pt_dic[idx]['res_time'])/12.0 # adjust the res_time unit to hr


    # output
    print('output...')
    fr2=open(inv_path+'./res_time/res_'+int_time_obj.strftime('%y%m%d%H')+'.txt','w')
    for item in pt_dic.values():
        cor_x=item['cor_x']
        cor_y=item['cor_y']
        lat=item['lat']
        lon=item['lon']
        value=item['res_time']
        fr2.write('%4d %4d %8.3f %8.3f %5.1f\n' % (cor_x, cor_y, lat, lon, value))
    fr2.close()
    for idx in pt_dic:
        pt_dic[idx]['res_time']=0

    int_time_obj = int_time_obj+time_delta
# While: All experiments


