import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import datetime

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

    varname='LH'
    cases=["ERA5_TY2001", "ERA5_C2008","ERA5_WAOFF", "ERA5_WRF"]

    wrf_root='/disk/v092.yhuangci/lzhenn/1911-COAWST/'
        
    #open dataset
    fig,ax = plt.subplots()
    width=15.0
    height=7.0
    #fig,ax = plt.subplots(figsize=(10,4))
    fig.subplots_adjust(left=0.08, bottom=0.18, right=0.99, top=0.92, wspace=None, hspace=None) 
   
    #fetch lh radius list
    for case in cases:
        radius_loc=wrf_root+case+'/'+varname+'.radius'
        with open(radius_loc) as f:
            content_list=f.read().splitlines()
        ii=0
        for itm in content_list:
            content_list[ii]=float(itm)
            ii=ii+1
        # adjust to fit in the canvas 
        plt.plot(np.arange(81)*3, content_list, label=case)
    
    plt.legend(loc='best', fontsize=MIDFONT)
    plt.xlabel('Radius (km)',fontsize=MIDFONT)
    plt.ylabel('SST (W/m^2)',fontsize=MIDFONT)
    plt.xticks(fontsize=MIDFONT)
    #plt.xticks(fontsize=MIDFONT,rotation=-30)
    plt.yticks(fontsize=MIDFONT)
    
    plt.title('Azimuthally averaged '+varname, fontsize=BIGFONT)
#    fig.tight_layout()
#    plt.show()
    fig.set_size_inches(width, height)
    fig.savefig('../fig/'+varname+'_radius.pdf')

    #break
if __name__ == "__main__":
    main()


