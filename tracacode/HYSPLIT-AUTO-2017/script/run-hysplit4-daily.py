import os
import sys
import datetime


arg_dic={
        'wrfout':sys.argv[1],
        'ptlist':sys.argv[2],
        'back_fg':int(sys.argv[3]),     # Backward Flag 1--backward 0--foreward
        'hgt':float(sys.argv[4]),
        'rtime':int(sys.argv[5]),
        'wrfpre':sys.argv[6]}

# CONTROL file sample directory (Don't use 'CONTROL')
smp_path='CONTROL.smp'

#Operation
time_obj = datetime.datetime.utcnow()
fc_time_delta=datetime.timedelta(hours=24)
yyyy=time_obj.strftime('%Y')
yyyymm=time_obj.strftime('%Y%m')
yyyymmdd=time_obj.strftime('%Y%m%d')
psdo_path='/disk/hq247/yhuangci/cmaq-run/data/wrf-fc/'+yyyy+'/'+yyyymm+'/'+yyyymmdd+'12'

# make sure the existence of the dir
while not(os.path.isdir(psdo_path)):
    time_obj=time_obj-fc_time_delta
    yyyy=time_obj.strftime('%Y')
    yyyymm=time_obj.strftime('%Y%m')
    yyyymmdd=time_obj.strftime('%Y%m%d')
    psdo_path='/disk/hq247/yhuangci/cmaq-run/data/wrf-fc/'+yyyy+'/'+yyyymm+'/'+yyyymmdd+'12'

time_obj=datetime.datetime.strptime('%s%s' %(yyyymmdd,'12'), '%Y%m%d%H')
print('Found: %s' % psdo_path)

# wrf data to arl data
#####os.system('ln -s '+psdo_path+'/'+arg_dic['wrfpre']+'* ./wrf-link/')
#####os.system('sh exec_arw2arl.sh')

# read points
with open(arg_dic['ptlist'],'r') as fr:
    lines_pt=fr.readlines()

# read sample
with open(smp_path,'r') as fsmp:
    lines_smp=fsmp.readlines()

# Initial Date Change, back_fg=1, shift rtime forward
ini_time_obj=time_obj+arg_dic['back_fg']*datetime.timedelta(hours=arg_dic['rtime'])
lines_smp[0]=ini_time_obj.strftime('%y %m %d %H\n')

# Integration time change
lines_smp[3]='%4d\n' % ((-1)**arg_dic['back_fg']*arg_dic['rtime'])

for idx, pt in enumerate(lines_pt):
    ele=pt.split()

    os.system('mkdir ./traj_output/'+ele[2]+'')

    pt=pt.strip('\n')
    # Change Point and height
    lines_smp[2]='%s %s %8.1f\n'% (ele[0], ele[1], arg_dic['hgt'])

    # Output Filename Change
    lines_smp[-2]='./traj_output/%s/\n' % (ele[2])
    lines_smp[-1]='%s%s' % (ele[2], yyyymmdd)
    
    with open('../exec/CONTROL','w') as fr:
        fr.writelines(lines_smp)
    
    os.system('cd ./; ./hyts_std')
