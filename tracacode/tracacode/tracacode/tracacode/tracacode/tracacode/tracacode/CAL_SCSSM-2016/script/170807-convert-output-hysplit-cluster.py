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
def get_inner_points(fn, latS, latN, lonW, lonE, latC, lonC):
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
        if (lat<=latN and lat>=latS and lon<=lonE and lon>=lonW and (abs(latC-lat)<0.375 or abs(lonC-lon)<0.375)):            
            pt_dic[pt_id]={'lat':lat, 'lon':lon}
    return pt_dic




# Main Function: Process the file
def process_traj_points(pt_list, latC, lonC, infile, outpath, exppath, hr_end, hr_step, init_time):
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
                pt_traj_dic[pt_id]={'lat':[latC], 'lon':[lonC], 'plvl':[plvl]}
            else:
                # Transform
                pt_traj_dic[pt_id]['lat'].append(latC+(lat-pt_list[pt_id]['lat']))
                pt_traj_dic[pt_id]['lon'].append(lonC+(lon-pt_list[pt_id]['lon']))
                pt_traj_dic[pt_id]['plvl'].append(plvl)
    write_status=write_traj_points(pt_traj_dic, latC, lonC, outpath, exppath, hr_end, hr_step, init_time)

def write_traj_points(pt_traj, latC, lonC, outpath, exppath, hr_end, hr_step, dum_time_obj):
    dum_height=500.0
    fr = open(exppath, 'r')
    lines=fr.readlines()
    fr.close()
    yymmddHH=dum_time_obj.strftime('%y%m%d%H')
    yy=dum_time_obj.strftime('%y')
    mon=dum_time_obj.month
    day=dum_time_obj.day
    hr=dum_time_obj.hour
    hr_end=hr_end

    # Headlines
#     NGM     95    10     1     0    12
    lines[1]='%7s%7d%6d%6d%6d%6d\n' % ('NGM', int(yy), mon, day, hr, hr_end)
#     95    10     1     0   40.000  -90.000   500.0
    lines[3]='%6d%6d%6d%6d%9.3f%9.3f%8.1f\n' % (int(yy), mon, day, hr, latC, lonC, dum_height)
    

    # Contents
    for pt_id in pt_traj:
#      1     1    95    10     1     0     0    11     0.0   40.000  -90.000    500.0    927.9
        dum_time_pt=dum_time_obj   # Renew time stap
        fw= open(outpath+'N'+pt_id.zfill(4)+'_'+yymmddHH,'w')
        fw.writelines(lines[0:5])
        latlist=pt_traj[pt_id]['lat']
        lonlist=pt_traj[pt_id]['lon']
        plvllist=pt_traj[pt_id]['plvl']
        yy=dum_time_pt.strftime('%y')
        mon=dum_time_pt.month
        day=dum_time_pt.day
        hr=dum_time_pt.hour

        for pos, lat in enumerate(latlist):
            fw.write('%6d%6d%6d%6d%6d%6d%6d%6d%8.1f%9.3f%9.3f%9.1f%9.1f\n' % (1, 1, int(yy), mon, day, hr, 0, 1, pos*1.0, lat, lonlist[pos], dum_height,plvllist[pos]))
            dum_time_pt += -datetime.timedelta(hours=hr_step)
            yy=dum_time_pt.strftime('%y')
            mon=dum_time_pt.month
            day=dum_time_pt.day
            hr=dum_time_pt.hour
        fw.close()
    return 0
# ------------Main------------

year_start=1979

# Which level
p_level=700

# Region
latS=7.5
latN=13
lonW=87.5
lonE=97

# Time step
nhour=1
# Integration steps
nsteps=96
# Total hours for integration
nhrs=nsteps*nhour

# parser path
inv_path='/Users/zhenningli/data/CAL_SCSSM-2016/back_traj/CAL_SCSSM-2016/'
exp_path='/Users/zhenningli/data/CAL_SCSSM-2016/back_traj/CAL_SCSSM-2016/example-traj.txt'
out_path='/Users/zhenningli/data/CAL_SCSSM-2016/back_traj/CAL_SCSSM-2016/post_process/'

latC=(latS+latN)/2.0
lonC=(lonW+lonE)/2.0

onset_date=[125,136,133,134,143,108,136,123,119,119,128,105,110,132,134,114,126,112,133,132,93,100,115,114,127,118,123,107,116,112,99,134,113,119]
day_shift=-2


#Parser
init_time = datetime.datetime(year_start, 1, 1, 0)
init_time += datetime.timedelta(days=((onset_date[0]-1)+day_shift))
time_stamp=init_time.strftime('%Y%m%d%H')

print('Parsing points list...')
filename=inv_path+time_stamp+'-'+str(p_level)+'hPa.txt'
print('Sample File:'+filename)
pt_dic=get_inner_points(filename, latS, latN, lonW, lonE, latC, lonC)
for year in range(year_start,year_start+len(onset_date),1):
    init_time = datetime.datetime(year, 1, 1, 0)
    init_time += datetime.timedelta(days=((onset_date[year-year_start]-1)+day_shift))
    time_stamp=init_time.strftime('%Y%m%d%H')
    filename=inv_path+time_stamp+'-'+str(p_level)+'hPa.txt'
    print('Parsing %8s trajectories...'% time_stamp)
    traj_result= process_traj_points(pt_dic, latC, lonC, filename, out_path, exp_path, nhrs, nhour, init_time)
    

# While: All experiments


