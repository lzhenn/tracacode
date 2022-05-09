import numpy as np
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
matplotlib.use('Agg') 
import xarray as xr
import datetime
import salem

def get_closest_data(var, lat2d, lon2d, lat0, lon0):
    dis_lat2d=lat2d-lat0
    dis_lon2d=lon2d-lon0
    dis=abs(dis_lat2d)+abs(dis_lon2d)
    idx=np.argwhere(dis.values==dis.values.min()) # x, y position
    var=var.where(dis==dis.min(),drop=True).squeeze() # closest value
    return var, idx 

def get_closest_idx(lat2d, lon2d, lat_array, lon_array):
    idx=[]
    for (lat0, lon0) in zip(lat_array, lon_array):
        dis_lat2d=lat2d-lat0
        dis_lon2d=lon2d-lon0
        dis=abs(dis_lat2d)+abs(dis_lon2d)
        idx.append(np.argwhere(dis.values==dis.values.min()).tolist()) # x, y position
    return idx #[[[x0,y0]],[[x1,y1]]] 

def box_composite(var, boxR, idx):
    nsmp=0
    comp_var=var[0,0:2*boxR, 0:2*boxR]
    comp_var=0
    for itm in idx:
        comp_var=comp_var+var[nsmp, itm[0][0]-boxR:itm[0][0]+boxR, itm[0][1]-boxR:itm[0][1]+boxR]
        nsmp=nsmp+1
    comp_var=comp_var/nsmp
    return comp_var

def box_collect(var, boxR, idx):
    nsmp=0
    collect_var=var[0:len(idx),0:2*boxR, 0:2*boxR]
    for itm in idx:
        collect_var[nsmp,:,:]=var[nsmp, itm[0][0]-boxR:itm[0][0]+boxR, itm[0][1]-boxR:itm[0][1]+boxR]
        nsmp=nsmp+1
    return collect_var


def windspeed(var1,var2):
    return np.sqrt(var1*var1+var2*var2)


def main():
     
    # constants
    BIGFONT=22
    MIDFONT=18
    SMFONT=16
    FIG_WIDTH=15.0
    FIG_HEIGHT=10.0

    #cases=["ERA5_C2008", "ERA5_TY2001", "ERA5_WRFROMS", "ERA5_WRF"]
    #cases=["ERA5_TY2001", "ERA5_WRFROMS"]
    ctrl_case='ERA5_WRFROMS'
    sen_case='ERA5_TY2001'
    #line_libs=['b.','g*','r^','k+']
    #line_libs=['b.','b*','g.','g*','r^','k+']
    line_libs=['b.','g.','r.','k.']
    wrf_root='/disk/v092.yhuangci/lzhenn/1911-COAWST/'
    
    i_dom=2
    strt_time_str='201809152200'
    end_time_str='201809160600'
    box_R=80

    strt_time_obj=datetime.datetime.strptime(strt_time_str, '%Y%m%d%H%M')
    end_time_obj=datetime.datetime.strptime(end_time_str, '%Y%m%d%H%M')

    dateparse = lambda x: datetime.datetime.strptime(x, '%Y%m%d%H0000')
    
    # read track data ctrl
    tc_info_fn=wrf_root+'/'+ctrl_case+'/trck.'+ctrl_case+'.d0'+str(i_dom)
    df_tc_info=pd.read_csv(tc_info_fn, sep='\s+', parse_dates=True, index_col='timestamp', header=0, date_parser=dateparse)
    df_tc_info_ctrl=df_tc_info[((df_tc_info.index>=strt_time_obj)&(df_tc_info.index<=end_time_obj))]

    # read track data sen 
    tc_info_fn=wrf_root+'/'+sen_case+'/trck.'+sen_case+'.d0'+str(i_dom)
    df_tc_info=pd.read_csv(tc_info_fn, sep='\s+', parse_dates=True, index_col='timestamp', header=0, date_parser=dateparse)
    df_tc_info_sen=df_tc_info[((df_tc_info.index>=strt_time_obj)&(df_tc_info.index<=end_time_obj))]

    tc_lat_ctrl=df_tc_info_ctrl['lat']
    tc_lon_ctrl=df_tc_info_ctrl['lon']
    
    tc_lat_sen=df_tc_info_sen['lat']
    tc_lon_sen=df_tc_info_sen['lon']

    # read raw input
    ds = salem.open_wrf_dataset('/disk/v092.yhuangci/lzhenn/1911-COAWST/'+ctrl_case+'/wrfout_d02')
    ds=ds.sel(time=slice(strt_time_obj,end_time_obj))

    var1_ctrl = ds['LH'] # heat exch
    varmask_ctrl=ds['LANDMASK']
    var1_ctrl.values=np.where(varmask_ctrl.values==1, np.nan, var1_ctrl.values) # get rid off land points
    idx_ctrl=get_closest_idx(var1_ctrl.lat, var1_ctrl.lon, tc_lat_ctrl.values, tc_lon_ctrl.values)
    var1_ctrl_box_comp=box_composite(var1_ctrl.values, box_R, idx_ctrl) # nparray inout

    # read raw input
    ds = salem.open_wrf_dataset('/disk/v092.yhuangci/lzhenn/1911-COAWST/'+sen_case+'/wrfout_d02')
    ds=ds.sel(time=slice(strt_time_obj,end_time_obj))

    var1_sen = ds['LH'] # heat exch
    varmask_sen=ds['LANDMASK']
    var1_sen.values=np.where(varmask_sen.values==1, np.nan, var1_sen.values) # get rid off land points
    idx_sen=get_closest_idx(var1_sen.lat, var1_sen.lon, tc_lat_sen.values, tc_lon_sen.values)
    var1_sen_box_comp=box_composite(var1_sen.values, box_R, idx_sen) # nparray inout

    var1_diff=var1_sen_box_comp-var1_ctrl_box_comp 


    fig, ax=plt.subplots()
#    fig.subplots_adjust(left=0.08, bottom=0.18, right=0.99, top=0.92, wspace=None, hspace=None) 
    
    im=ax.imshow(var1_diff)
      
#    plt.legend(loc='best', fontsize=SMFONT)
    plt.xlabel('distanceX',fontsize=SMFONT)
    plt.ylabel('distanceY',fontsize=SMFONT)
    plt.xticks(fontsize=SMFONT)
    plt.yticks(fontsize=SMFONT)
      
    plt.title('LH Diff, Box Composite', fontsize=BIGFONT)
#    fig.set_size_inches(FIG_WIDTH, FIG_HEIGHT)
    fig.savefig('../fig/boxdiff_LHF.png')
    #plt.show()

if __name__ == "__main__":
    main()


