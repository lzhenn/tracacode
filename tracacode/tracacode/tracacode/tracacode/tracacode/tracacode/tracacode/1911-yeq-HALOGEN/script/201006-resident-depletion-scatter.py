import numpy as np
import pandas as pd
import matplotlib
from scipy import stats
import matplotlib.pyplot as plt
matplotlib.use('Agg')
import xarray as xr
import datetime

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

    mcip_grid_fn="/disk/hq247/yhuangci/resource/map_info/research_domains/27km/GRIDCRO2D.27km"
    coast_dis_fn     ="/disk/hq247/yhuangci/analy/halogen/result/ncl_files/v1/calc/dis_to_coast_27km.nc"
    out_res_path="/disk/hq247/yhuangci/lzhenn/workspace/easy-wrf-trck/outnc/"
    cmaq_with_file="/disk/hq247/yhuangci/analy/halogen/result/data/cmaq/with/"  
    cmaq_without_file="/disk/hq247/yhuangci/analy/halogen/result/data/cmaq/without/"  
    
    line_types=['r-^','m:s','b-.*','g--o']
    months=['Jan', 'Apr', 'Jul', 'Oct']
    smonths=['jan', 'apr', 'jul', 'oct']
    work_yyyymm=['01', '04', '07', '10']
    
    fig, ax=plt.subplots()
    fig.subplots_adjust(left=0.08, bottom=0.18, right=0.97, top=0.92, wspace=None, hspace=None) 
        
    for line_type, mon, smon, itm in zip(line_types, months, smonths, work_yyyymm):
        
        ds_with=xr.open_mfdataset(cmaq_with_file+smon+'/COMBINE_CCTM_ACONC_27km_2016*',concat_dim='TSTEP')
        ds_without=xr.open_mfdataset(cmaq_without_file+smon+'/COMBINE_CCTM_ACONC_27km_2016*',concat_dim='TSTEP')
        var_with=ds_with['O3']
        var_without=ds_without['O3']

        var_with=var_with.mean(dim='TSTEP')
        var_without=var_without.mean(dim='TSTEP')
        var_diff=(var_with-var_without)*1000 # convert to ppb
        var_surf_diff=var_diff[0,:,:]
        var_pbl_diff=var_diff[0:19,:,:].mean(dim='LAY')
        print(var_pbl_diff)
        

        ds_res=xr.open_mfdataset(out_res_path+'*2016'+itm+'*')
        var_res=ds_res['OcnResTime']
        var_res=var_res.sum(dim='Time')
        var_res=var_res*100/720

        var_res=var_res.loc[8:228,18:308]
        res_arr1d=var_res.values.flatten()
        
        # get bins
        bin_means, bin_edges, binnumber = stats.binned_statistic(res_arr1d, 
                var_pbl_diff.values.flatten(), statistic='mean', bins=30)
        
        bin_std, bin_edges, binnumber = stats.binned_statistic(res_arr1d,
                var_pbl_diff.values.flatten(), statistic='std', bins=30)


        #bin_max, bin_edges, binnumber = stats.binned_statistic(dis_arr1d,
        #                        res_arr1d, statistic='max', bins=300)

        #bin_min, bin_edges, binnumber = stats.binned_statistic(dis_arr1d,
        #                        res_arr1d, statistic='min', bins=300)
        
        x_mid=(bin_edges[0:-1]+bin_edges[1:])/2
       
        ax.plot(x_mid,bin_means, line_type, label=mon, linewidth=3, markersize=10)
        ax.fill_between(x_mid, bin_means+bin_std, bin_means-bin_std, color=line_type[0:1], alpha=0.2) 

    plt.legend(loc='best', fontsize=SMFONT)
    plt.xlabel('Ocean Sourced Air Occupation Ratio (%)',fontsize=SMFONT)
    plt.ylabel('Ozone Depletion (ppb)',fontsize=SMFONT)
    plt.xticks(fontsize=SMFONT)
    plt.yticks(fontsize=SMFONT)
    plt.xlim((0, 60)) 
    plt.title('PBL Ozone Depletion - Ocean Sourced Air Occupation Ratio', fontsize=BIGFONT)
    fig.set_size_inches(FIG_WIDTH, FIG_HEIGHT)
    fig.savefig('../fig/ocean_occupy_pbl_o3_depletion.png')
    #plt.show()

if __name__ == "__main__":
    main()


