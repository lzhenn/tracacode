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

    #line_libs=['ko','ro','bo','go']
    #line_libs=['k.','r.','b.','g.']
    line_libs=['r.','b.']
    
    #line_libs=['b.','g*','r^','k+']
    mcip_grid_fn="/disk/hq247/yhuangci/resource/map_info/research_domains/27km/GRIDCRO2D.27km"
    coast_dis_fn     ="/disk/hq247/yhuangci/analy/halogen/result/ncl_files/v1/calc/dis_to_coast_27km.nc"
    out_res_path="/disk/hq247/yhuangci/lzhenn/workspace/easy-wrf-trck/outnc/"
      
    
    work_yyyymm='201607'

    ds_res=xr.open_mfdataset(out_res_path+'*'+work_yyyymm+'*')
    var_res=ds_res['OcnResTime']
    var_res=var_res.sum(dim='Time')
    var_res=var_res*100/720

    ds_dis=xr.open_dataset(coast_dis_fn)
    var_dis=ds_dis['dis_to_coast']

    ds_mcip_grid=xr.open_dataset(mcip_grid_fn)
    mcip_lat=ds_mcip_grid['LAT'][0,0,:,:]
    mcip_lon=ds_mcip_grid['LON'][0,0,:,:]
    
    var_res=var_res.loc[8:228,18:308]
    res_arr1d=var_res.values.flatten()
    dis_arr1d=27*var_dis.values.flatten()
    print(res_arr1d)
    print(dis_arr1d)

    fig, ax=plt.subplots()
    fig.subplots_adjust(left=0.08, bottom=0.18, right=0.99, top=0.92, wspace=None, hspace=None) 
    
    ax.plot(dis_arr1d, res_arr1d, 'r.', markersize=5, alpha=0.3, markeredgecolor='none')
      
    plt.legend(loc='best', fontsize=SMFONT)
    plt.xlabel('Distance to Coastline (km)',fontsize=SMFONT)
    plt.ylabel('Ocean Sourced Air Occupation Ratio (%)',fontsize=SMFONT)
    plt.xticks(fontsize=SMFONT)
    plt.yticks(fontsize=SMFONT)
    plt.xlim((-1000, 1000)) 
    plt.title('Jul: Ocean Sourced Air Occupation Ratio - Distance to Coastline', fontsize=BIGFONT)
    fig.set_size_inches(FIG_WIDTH, FIG_HEIGHT)
    fig.savefig('../fig/scatter_add_jul.png')
    #plt.show()

if __name__ == "__main__":
    main()


