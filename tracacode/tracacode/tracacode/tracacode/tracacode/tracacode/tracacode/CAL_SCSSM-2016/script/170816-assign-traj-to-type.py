#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
#
#       L_Zealot
#       Feb 28, 2017
#
#
import datetime
import math
#---------------------------
# Function definition
#---------------------------

# read and organize clusters
def org_cluster(fn):
    fr = open(fn, 'r')     
    lines=fr.readlines()
    fr.close()
    lines=lines[7:]
    clst_dic={}

    for pos_line, point in enumerate(lines):
        content=point.split() # [0]--# [1]--timestep [2]--lat [3]--lon [4]--pressure
        pt_id=str(content[0])
        lat=float(content[9])
        lon=float(content[10])
        if pt_id in clst_dic:            
            clst_dic[pt_id]['lat'].append(lat)
            clst_dic[pt_id]['lon'].append(lon)
        else:
            clst_dic[pt_id]={'lat':[lat], 'lon':[lon]}
    return clst_dic



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
        if (lat<=latN and lat>=latS and lon<=lonE and lon>=lonW ):            
            pt_dic[pt_id]={'lat':lat, 'lon':lon}
    return pt_dic




# Main Function: Process the file
def get_traj_samples(pt_list, infile):
    # open the infile
    fr = open(infile, 'r')     
    lines=fr.readlines()
    fr.close()

    pt_traj_dic={}
    for pos_line, point in enumerate(lines):
        content=point.split() # [0]--# [1]--timestep [2]--lat [3]--lon [4]--pressure
        pt_id=str(content[0])
        ts=abs(int(float(content[1])))
        lat=float(content[2])
        lon=float(content[3])
        plvl=float(content[4])
    
        # if we got the specific traj
        if (pt_id in pt_list):
            if ts==0:            
                pt_traj_dic[pt_id]={'type:':-1,'lat':[lat], 'lon':[lon], 'plvl':[plvl]}
            else:
                # Transform
                pt_traj_dic[pt_id]['lat'].append(lat)
                pt_traj_dic[pt_id]['lon'].append(lon)
                pt_traj_dic[pt_id]['plvl'].append(plvl)
    return pt_traj_dic

def assign_traj_samples(sp_list, clst_list, step):
    
    latC=clst_list['1']['lat'][0]
    lonC=clst_list['1']['lon'][0]
    type_list=sp_list
    for pt_id in sp_list:
        # Transform the traj position
        dlat=sp_list[pt_id]['lat'][0]-latC
        dlon=sp_list[pt_id]['lon'][0]-lonC
        dis=[0, 0, 0]
        for ii in range(step, 97, step):
            dis[0]=dis[0]+math.sqrt(math.pow(((sp_list[pt_id]['lat'][ii]-dlat)-clst_list['1']['lat'][ii]),2)+math.pow(((sp_list[pt_id]['lon'][ii]-dlon)-clst_list['1']['lon'][ii]),2))
            dis[1]=dis[1]+math.sqrt(math.pow(((sp_list[pt_id]['lat'][ii]-dlat)-clst_list['2']['lat'][ii]),2)+math.pow(((sp_list[pt_id]['lon'][ii]-dlon)-clst_list['2']['lon'][ii]),2))
            dis[2]=dis[2]+math.sqrt(math.pow(((sp_list[pt_id]['lat'][ii]-dlat)-clst_list['3']['lat'][ii]),2)+math.pow(((sp_list[pt_id]['lon'][ii]-dlon)-clst_list['3']['lon'][ii]),2))
        clst_id=dis.index(min(dis))+1
        type_list[pt_id]['type']=clst_id
    return type_list    

def write_traj_points(traj_assigned, out_path, init_time, w_step, t_step):
    yyyymmdd=init_time.strftime('%Y%m%d')
    fw= open(out_path+'clster-'+yyyymmdd,'w')
    for ii in range(0, t_step+1, w_step):
    
        yyyymmddHH=init_time.strftime('%Y%m%d%H')
        for pt_id in traj_assigned:
            fw.write('%4s%12s%8.2f%8.2f%6.1f%6d\n' % (pt_id,yyyymmddHH, traj_assigned[pt_id]['lat'][ii], traj_assigned[pt_id]['lon'][ii], traj_assigned[pt_id]['plvl'][ii],traj_assigned[pt_id]['type']))
        
        init_time += -datetime.timedelta(hours=w_step)
    fw.close()
    return 0
# ------------Main------------

year_start=1979

# Which level
p_level=700

# Region
latS=7.5
latN=15
lonW=87.5
lonE=97

# Write steps
w_step=24
# total step
t_step=96

# parser path
inv_path='/Users/zhenningli/data/CAL_SCSSM-2016/back_traj/CAL_SCSSM-2016/'
out_path='/Users/zhenningli/data/CAL_SCSSM-2016/back_traj/CAL_SCSSM-2016/post_process/'

day_shift=2
clst_file="/Users/zhenningli/data/CAL_SCSSM-2016/back_traj/Cluster/Cmean1_3_A2.tdump"
onset_date=[125,136,133,134,143,108,136,123,119,119,128,105,110,132,134,114,126,112,133,132,93,100,115,114,127,118,123,107,116,112,99,134,113,119]


cst_dic={}
cst_dic=org_cluster(clst_file)

#Parser
init_time = datetime.datetime(year_start, 1, 1, 0)
init_time += datetime.timedelta(days=((onset_date[0]-1)+day_shift))
time_stamp=init_time.strftime('%Y%m%d%H')

print('Parsing points list...')
filename=inv_path+time_stamp+'-'+str(p_level)+'hPa.txt'
print('Sample File:'+filename)

pt_dic=get_inner_points(filename, latS, latN, lonW, lonE)
for year in range(year_start,year_start+len(onset_date),1):
    init_time = datetime.datetime(year, 1, 1, 0)
    init_time += datetime.timedelta(days=((onset_date[year-year_start]-1)+day_shift))
    time_stamp=init_time.strftime('%Y%m%d%H')
    filename=inv_path+time_stamp+'-'+str(p_level)+'hPa.txt'
    print('Parsing %8s trajectories...'% time_stamp)
    traj_samples= get_traj_samples(pt_dic, filename)
    traj_assigned= assign_traj_samples(traj_samples, cst_dic, 6)
    write_status=write_traj_points(traj_assigned, out_path, init_time, w_step, t_step)
# While: All experiments


