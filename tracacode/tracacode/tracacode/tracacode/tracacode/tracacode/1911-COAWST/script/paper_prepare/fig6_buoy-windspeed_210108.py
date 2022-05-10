import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import xarray as xr
import datetime
import salem

def get_closest_data(var, lat2d, lon2d, lat0, lon0):
    dis_lat2d=lat2d-lat0
    dis_lon2d=lon2d-lon0
    dis=abs(dis_lat2d)+abs(dis_lon2d)
    var=var.where(dis==dis.min(),drop=True).squeeze()
    return var

def windspeed(var1,var2):
    return np.sqrt(var1*var1+var2*var2)



def main():
     
    # constants
    BIGFONT=22
    MIDFONT=18
    SMFONT=16

    width=10.0
    height=10.0
    
    cases=['C2008', 'TY2001', 'WRFROMS', 'WRFONLY']
    line_libs=['r-^','r-s','b-.*','g--o']
    
    wrf_root='/home/metctm1/array/data/1911-COAWST/'
    bouy_path='/home/metctm1/array/data/1911-COAWST/obv/bouy/'
    
    strt_time_str='201809150600'
    end_time_str='201809170000'
    strt_time_obj=datetime.datetime.strptime(strt_time_str, '%Y%m%d%H%M')
    end_time_obj=datetime.datetime.strptime(end_time_str, '%Y%m%d%H%M')

    #fetch bouys list
    bouy_loc=bouy_path+'location.csv'
    df_bouy_list=pd.read_csv(bouy_loc)

    fig,ax = plt.subplots(4, 1, sharex=True)
    fig.subplots_adjust(left=0.1, bottom=0.1, right=0.99, top=0.92, wspace=None, hspace=0) 

    icount=0
    for index, row in df_bouy_list.iterrows():
        bouy=row['bouy']
        bouy_lat0=row['lat']
        bouy_lon0=row['lon']
        dateparse = lambda x: datetime.datetime.strptime(x, '%Y-%m-%d %H:%M:%S')
        obv_path=bouy_path+bouy+'.csv'
        df_obv=pd.read_csv(obv_path,parse_dates=True,index_col='采集时间', header=1, date_parser=dateparse)
        # change to HKT, to get bouy data 
        strt_time_hkt_obj=strt_time_obj+ datetime.timedelta(hours=8) 
        end_time_hkt_obj=end_time_obj+ datetime.timedelta(hours=8)
        df_obv_period=df_obv[((df_obv.index>=strt_time_hkt_obj)&(df_obv.index<=end_time_hkt_obj))]
        # change index
        df_obv_period.index = df_obv_period.index - datetime.timedelta(hours=8)
        
        
        for (line_type, case) in zip(line_libs, cases):
            print(case)
            ds = salem.open_wrf_dataset('/disk/v092.yhuangci/lzhenn/1911-COAWST/'+case+'/wrfout_d02')
            ds=ds.sel(time=slice(strt_time_obj,end_time_obj))

            uwind = ds['U10']
            vwind = ds['V10']
            uwind_sta=get_closest_data(uwind, uwind.lat,uwind.lon,bouy_lat0, bouy_lon0)
            vwind_sta=get_closest_data(vwind, vwind.lat,vwind.lon,bouy_lat0, bouy_lon0)
            ws_sta=windspeed(uwind_sta, vwind_sta)
            #ws_sta.plot.line(line_type, linewidth=1, label=case)
            ws_sta=ws_sta.to_dataframe(name='ws')
            ax[icount].plot(ws_sta['ws'], line_type, label=case, linewidth=1)

        ax[icount].plot(df_obv_period['风速m/s'], label='Buoy', marker='o', color='black',linewidth=3)
        ax[icount].tick_params(axis='both', which='major', labelsize=SMFONT*0.8)
        ax[icount].annotate(bouy, xy=(0.02, 0.85), xycoords='axes fraction', fontsize=SMFONT)
#        ax[icount].set_yticks(np.arange(0, 30, 10))
        icount=icount+1
    ax[0].set_title('Surface Wind Speed at Buoy Sites', fontsize=MIDFONT, loc='left')
    ax[0].legend( fontsize=SMFONT*0.8, loc='upper right')
    ax[3].set_xlabel('Time',fontsize=SMFONT)
    fig.text(0.04, 0.5, 'Wind Speed (m/s)', va='center', rotation='vertical', fontsize=SMFONT)
   #plt.xticks(fontsize=SMFONT,rotation=-30)
   # pletp(ax.get_xticklabels(), rotation=-60, ha="right",
   # rotation_mode="anchor")
   # plt.title(bouy+' Wind Speed', fontsize=BIGFONT)
#    fig.tight_layout()
#    plt.show()
    fig.set_size_inches(width, height)
    fig.savefig('../../fig/paper/fig6_buoy_ws.pdf')

        #break
if __name__ == "__main__":
    main()


