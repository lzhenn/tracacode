import numpy as np
import pandas as pd
from scipy import stats
import matplotlib
import matplotlib.pyplot as plt
matplotlib.use('Agg')
import xarray as xr
import datetime
import salem

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

    varname='LH'
    #cases=["ERA5_C2008_add", "ERA5_TY2001_add", "ERA5_WRFROMS_add", "ERA5_WRF_add"]
#    cases=["ERA5_C2008_dynlim",  "ERA5_TY2001_nolimit",  "ERA5_WRFROMS_add", "ERA5_WRF_add"]
    #cases=["ERA5_C2008", "ERA5_TY2001", "ERA5_WRFROMS", "ERA5_WRF"]
    #cases=[ "ERA5_WRF","ERA5_WRFROMS",   "ERA5_TY2001", "ERA5_C2008_dynlim"]
    cases=["WRFROMS", "C2008", "TY2001"]
    #line_libs=['ko','ro','bo','go']
    #line_libs=['k.','r.','b.','g.']
    dot_color_lib=['salmon', 'cyan', 'lightgreen']
    bar_color_lib=['r', 'b', 'g']
    #line_libs=['b.','g*','r^','k+']
    wrf_root='/disk/v092.yhuangci/lzhenn/1911-COAWST/'
    
    i_dom=2
    strt_time_str='201809151800'
    end_time_str='201809160000'
    box_R=80

    epsilon=0.333
    rho_air=1.29

    strt_time_obj=datetime.datetime.strptime(strt_time_str, '%Y%m%d%H%M')
    end_time_obj=datetime.datetime.strptime(end_time_str, '%Y%m%d%H%M')

    fig, ax=plt.subplots()
    fig.subplots_adjust(left=0.08, bottom=0.18, right=0.99, top=0.92, wspace=None, hspace=None) 
    
    for (dot_color, bar_color, case) in zip(dot_color_lib, bar_color_lib, cases):

        # read track data
        tc_info_fn=wrf_root+'/'+case+'/trck.'+case+'.d0'+str(i_dom)
        dateparse = lambda x: datetime.datetime.strptime(x, '%Y%m%d%H0000')
        df_tc_info=pd.read_csv(tc_info_fn, sep='\s+', parse_dates=True, index_col='timestamp', header=0, date_parser=dateparse)
        df_tc_info=df_tc_info[((df_tc_info.index>=strt_time_obj)&(df_tc_info.index<=end_time_obj))]
        
        print(df_tc_info)
        tc_lat=df_tc_info['lat']
        tc_lon=df_tc_info['lon']

        # read raw input
        ds = salem.open_wrf_dataset('/disk/v092.yhuangci/lzhenn/1911-COAWST/'+case+'/wrfout_d02')
        ds=ds.sel(time=slice(strt_time_obj,end_time_obj))
        
        var1 = ds[varname] # heat exch
        var2 = ds['U10'] # momentum exch
        var3 = ds['U10'] 
        var4 = ds['V10'] 
        varmask=ds['LANDMASK']
        var1.values=np.where(varmask.values==1, np.nan, var1.values)
        var2.values=np.where(varmask.values==1, np.nan, var2.values)
        ws=np.sqrt(var3*var3+var4*var4)
        idx=get_closest_idx(var1.lat, var1.lon, tc_lat.values, tc_lon.values)
        var1_box_comp=box_collect(var1.values, box_R, idx) # nparray inout
        var2_box_comp=box_collect(var2.values, box_R, idx) # nparray inout
        ratio=var1_box_comp/var2_box_comp
        ws_box_comp=box_collect(ws.values, box_R, idx) # nparray inout
        
        ws_box_comp= ws_box_comp[~np.isnan(ws_box_comp)]
        var1_box_comp= var1_box_comp[~np.isnan(var1_box_comp)]
        # get bins
        bin_means, bin_edges, binnumber = stats.binned_statistic(ws_box_comp.flatten(),
                                var1_box_comp.flatten(), statistic='mean', bins=50)
        bin_counts, bin_edges, binnumber = stats.binned_statistic(ws_box_comp.flatten(),
                                var1_box_comp.flatten(), statistic='count', bins=50)

        # scatter
        #ax.plot(ws_box_comp.flatten(), var1_box_comp.flatten(), label=case, linewidth=0.0, marker='.', color=dot_color, markersize=5, alpha=1.0, markeredgecolor='none')
        plt.hlines(bin_means*bin_counts, bin_edges[:-1], bin_edges[1:], colors=bar_color, lw=10, zorder=99, alpha=1.0, 
                         label='binned mean for '+case)

    plt.legend(loc='best', fontsize=SMFONT)
    plt.xlabel('10m WindSpeed',fontsize=SMFONT)
    plt.ylabel(varname,fontsize=SMFONT)
    plt.xticks(fontsize=SMFONT)
    plt.yticks(fontsize=SMFONT)
      
    plt.title( varname+' - 10m WindSpeed', fontsize=BIGFONT)
    fig.set_size_inches(FIG_WIDTH, FIG_HEIGHT)
    fig.savefig('../fig/scatter_add_'+varname+'.png')
    #plt.show()

if __name__ == "__main__":
    main()


