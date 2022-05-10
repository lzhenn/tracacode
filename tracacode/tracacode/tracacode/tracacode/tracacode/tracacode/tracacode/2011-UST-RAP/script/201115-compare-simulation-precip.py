#! /usr/bin/env python
#  Deal with raw precip data 
#   
#               L_Zealot
#               Nov 15, 2020 
#               Hong Kong 
#
import os
import numpy as np
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
matplotlib.use('Agg')
import xarray as xr
import datetime
import salem

#-------------------------------------
# Function Definition Part
#-------------------------------------
def get_closest_idx(lat2d, lon2d, lat0, lon0):
    dis_lat2d=lat2d-lat0
    dis_lon2d=lon2d-lon0
    dis=abs(dis_lat2d)+abs(dis_lon2d)
    idx=np.argwhere(dis.values==dis.values.min()).tolist()[0] # x, y position
    return idx 




def main():
# constants
    BIGFONT=22
    MIDFONT=18
    SMFONT=16
    FIG_WIDTH=10.0
    FIG_HEIGHT=10.0


    i_dom=2
    strt_time_str='201809151800'
    end_time_str='201809171200'



    # Input File
    in_file='/disk/hq247/yhuangci/lzhenn/data/2011-UST-RAP/a_precip_20201113141016.csv'
    df = pd.read_csv(in_file,parse_dates=True) 
    df['id']=df['lon']*df['lat']
    df_process=df.groupby('id').sum()    # Resample into hourly data
    df_process['lon'] =df_process['lon']/df_process['val2']
    df_process['lat'] =df_process['lat']/df_process['val2']

    cases=[ "WRFONLY","WRFROMS",   "TY2001", "C2008"]
#    cases=[ "WRFONLY", "TY2001"]
    line_libs=['k.','bo','r^','bo','go']
    #line_libs=['b.','g*','r^','k+']
    wrf_root='/disk/v092.yhuangci/lzhenn/1911-COAWST/'
    

    strt_time_obj=datetime.datetime.strptime(strt_time_str, '%Y%m%d%H%M')
    end_time_obj=datetime.datetime.strptime(end_time_str, '%Y%m%d%H%M')

    fig, ax=plt.subplots()
#    fig.subplots_adjust(left=0.08, bottom=0.18, right=0.99, top=0.92, wspace=None, hspace=None) 
    
    for (line_type, case) in zip(line_libs, cases):

        # read raw input
        ds = salem.open_wrf_dataset('/disk/v092.yhuangci/lzhenn/1911-COAWST/'+case+'/wrfout_d02')
        ds=ds.sel(time=end_time_obj)

        var1 = ds['RAINNC'] # heat exch
        lat2d=var1.lat
        lon2d=var1.lon
        sim=[]
        for index, row in df_process.iterrows():
            lat0=row['lat']
            lon0=row['lon']
            idx=get_closest_idx(lat2d, lon2d, lat0, lon0)
            sim.append(var1.values[idx[0], idx[1]])
        
        rmse=((sim-df_process['val1'])**2).mean()**.5
        mae=(sim-df_process['val1']).mean()
        print(rmse, mae, np.corrcoef(sim, df_process['val1']))
        ax.plot(df_process['val1'], sim,line_type, label=case, markersize=3, alpha=0.8, markeredgecolor='none')
    ax.plot(np.arange(0, 500, 1))  
    plt.legend(loc='best', fontsize=SMFONT, markerscale=2.0)
    plt.xlabel('Observed Rainfall',fontsize=SMFONT)
    plt.ylabel('Simulated Rainfall',fontsize=SMFONT)
    plt.xticks(fontsize=SMFONT)
    plt.yticks(fontsize=SMFONT)
    plt.xlim(0, 500) 
    plt.ylim(0, 500) 
    plt.title('Obv - Sim Rainfall', fontsize=BIGFONT)
    fig.set_size_inches(FIG_WIDTH, FIG_HEIGHT)
    fig.savefig('../fig/scatter_rainfall.png')
    #plt.show()





if __name__ == "__main__":
    main()

   

