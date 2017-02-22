import os
import datetime

start_time='2015-01-26 12:00:00'
end_time='2015-01-27 00:00:00'

# Integration step in Hour
int_step=12


#Operation
int_time_obj = datetime.datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
end_time_obj = datetime.datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')
time_delta=datetime.timedelta(hours=int_step)

while int_time_obj <= end_time_obj:
    print(int_time_obj)
    fr=open('CONTROL','r+')
    lines=fr.readlines()
    
    lines[0]=int_time_obj.strftime('%y %m %d %H\n')
    lines[-1]='trajout_'+int_time_obj.strftime('%y%m%d%H\n')
    pos = fr.seek(0, 0);  # back to the file top
    fr.writelines(lines)
    fr.close()
    
    int_time_obj = int_time_obj+time_delta
    os.system('C:/hysplit4/exec/hyts_std.exe')