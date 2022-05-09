import os
import datetime

start_time='2015-01-01 00:00:00'
end_time='2015-01-27 00:00:00'

# Point Height
height=100

# Integration step in Hour
int_step=12

# CONTROL file sample directory (Don't use 'CONTROL')
smp_path='CONTROL.smp'

#Operation
int_time_obj = datetime.datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
end_time_obj = datetime.datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')
time_delta=datetime.timedelta(hours=int_step)

while int_time_obj <= end_time_obj:
    print('-------------------------\n\n')
    print(int_time_obj)
    fr=open(smp_path,'r')
    lines=fr.readlines()
    fr.close()
    
    # Initial Date Change
    lines[0]=int_time_obj.strftime('%y %m %d %H\n')
    # Output Date Change
    lines[-1]='trajout_'+int_time_obj.strftime('%y%m%d%H\n')
    
    # Height Change
    npoints=int(lines[1])
    print(npoints)
    for idx, item in enumerate(lines):
        if (idx >=2) and (idx<=(2+npoints-1)):
            item_ind=item.split(' ')
            item_ind[2]=height
            lines[idx]=str(item_ind[0])+' '+str(item_ind[1])+' '+str(item_ind[2])+'\n'
            
    fr=open('CONTROL','w')
    fr.writelines(lines)
    fr.close()
    int_time_obj = int_time_obj+time_delta
    
    os.system('C:/hysplit4/exec/hyts_std.exe')
