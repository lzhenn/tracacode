#!/usr/bin/env python3
'''
Module Painter


History:
Nov 06, 2022 --- render3d serial version completed!
Nov 06, 2022 --- FLEXPART output support for rendering

'''

import os, gc, subprocess
import datetime
import numpy as np
import pandas as pd
import xarray as xr 
from multiprocessing import Pool, cpu_count
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
import cmaps
import numba as nb
from mpl_toolkits.axes_grid1 import make_axes_locatable

print_prefix='painter>>'
topo_path='/home/lzhenn/array74/workspace/lavender/lavender/db/hk_dtm_100m.nc'
helicopter_data='/home/lzhenn/array74/data/airq_campaign/helicopter_221113.csv'
ship_data='/home/lzhenn/array74/data/airq_campaign/ship_221113.csv'
strt_time=datetime.datetime(2022,11,13,11,9,0)
end_time=datetime.datetime(2022,11,13,12,16,0)
ncmap = ListedColormap(cmaps.GMT_globe(range(0,209,2))) 

# feet to meter
f2m=0.3048
## fig
FIG_WIDTH=10
FIG_HEIGHT=10
FRM_MARGIN=[0.0, 0.0, 1.0, 1.0]
#FRM_MARGIN=[0.1, 0.1, 0.9, 0.9]
MIDFONT=18

def main():
    '''
    main function
    '''
    # load data
    pd_data=load_data()
    # render 3d plot
    render3d(pd_data)

def load_data():
    '''
    load data 
    '''
    data = pd.read_csv(
        helicopter_data,index_col=0, header=0, parse_dates=True)
#        date_parser=lambda x: pd.to_datetime(x, format='%Y/%m/%d %H:%M:%S'))
    return data

def render3d(pd_data):
    '''
    render 3d plot of the dumped partical file 
    '''
    ntasks=16
    # get topo file path
    max_ny=400

    # vis domain bdy    
    latN, latS=22.6,22.13 
    lonW, lonE=113.83,114.4
    zbot, ztop=0,1500
    bnd_lim=[lonW,lonE,latS,latN,zbot,ztop]
    
    # cam pos, elev0, change elev by elev_r per frame, same for azim
    cam_pos_lst=[60.0, -0.5, -120.0, 0.5]
    # get topo data
    topo_lat,topo_lon,topo_z = __get_topo_data(
        topo_path, latN, latS, lonW, lonE)
    
    # topo min lim
    topo_min=-150
    topo_zoom=2.0
    color_zoom=0.5
    topo_z=topo_z/topo_zoom
    topo_z=topo_z.where(topo_z>0,topo_min)
    
    ny=topo_lat.shape[0]
    
    if ny>max_ny:
        zoom_r=int(np.floor(ny/max_ny))+1
        topo_lat=topo_lat[::zoom_r]
        topo_lon=topo_lon[::zoom_r]
        topo_z=topo_z[::zoom_r,::zoom_r] 
    topo_lon, topo_lat = np.meshgrid(topo_lon.values, topo_lat.values)
    
    dx = np.diff(topo_lon[1,1:3])
    dy = np.diff(topo_lat[1:3,1])
    idx_col=pd_data.index.to_pydatetime()
    # mtsks_lst[iproc(strt_subidx,end_subidx)]
    mtsks_lst=alloc_mtasks_lst(ntasks, idx_col)
    ntasks=len(mtsks_lst) 
    run_plot=True
    if run_plot: 
        # MULTIPROCESSING: start process pool
        process_pool = Pool(processes=ntasks)
        results=[]

        # open tasks ID 0 to ntasks-1
        for itsk in range(0, ntasks):  
            # start and end file index for each task
            result=process_pool.apply_async(
                __mtsk_render3d, 
                args=(
                    itsk, mtsks_lst, pd_data,
                    topo_lat, topo_lon, topo_z,
                    dx, dy, bnd_lim, 
                    color_zoom, cam_pos_lst))
            results.append(result)
        print(results[0].get())
        process_pool.close()
        process_pool.join() 
    else:
        print(print_prefix+'skip plot')
    
    _form_anim('anim.mp4')

def alloc_mtasks_lst(ntasks, task_list):
    '''
    allocated tasks to multiple processes
    '''
    len_lst=len(task_list)
    
    # determine number of tasks
    if ntasks ==0:
        ntasks=cpu_count()
    if ntasks > len_lst:
        ntasks=len_lst
        print('ntasks reduced to  %4d according list length.' % (ntasks))
    if ntasks > cpu_count():
        ntasks=cpu_count()
        print('ntasks reduced to  %4d according cpu_count' % (ntasks))    
    print('ntasks set to: %4d' % (ntasks))

    avglen, res=divmod(len(task_list), ntasks)
    seg_lst=[]
    for i in range(0, ntasks):
        if i < res:
            seg_lst.append(task_list[i*avglen+i: (i+1)*avglen+i+1])
        else:
            seg_lst.append(task_list[i*avglen+res: (i+1)*avglen+res])
    return seg_lst

def  _form_anim(anim_name):
        '''form animation from pngs'''
        print('form animation from pngs')
        anim_fps=8
        fig_path=os.path.join('../fig','*.png')
        anim_path=os.path.join('../fig',anim_name)
        cmd="ffmpeg -y -r %d -pattern_type glob -i '%s' -c:v libx264 -vf \"fps=8,format=yuv420p\" %s" % (
            anim_fps, fig_path, anim_path)
        subprocess.call(cmd, shell=True) 


def __mtsk_render3d(
        itsk, seg_list,pd_data, 
        topo_lat, topo_lon, topo_z, 
        dx, dy, bnd_lim,
        color_zoom=1.0, cam_pos_lst=[60.0,-0.5,-80.0,0.5]):
    '''
    multiprocessing render 3d plot of the dumped partical file
    '''
    
    cam_elev0, cam_elevr, cam_azim0, cam_azimr = cam_pos_lst 
    len_seg=len(seg_list[itsk])    
    for subid, ts in enumerate(seg_list[itsk]):
        print(
            '%sTASK[%04d]: subtask (%04d/%04d) rendering %s' % (
                print_prefix, itsk, subid+1, len_seg, ts))
        pd_rows=pd_data.loc[:ts]
        plon,plat,pz=pd_rows['Longitude'].values, pd_rows['Latitude'].values, pd_rows['Pressure_Altitude'].values
        pconcen=pd_rows['O3 (ppb)'].values
        gidx=len(plon)-1
        # adjust the pressure altitude to the sea level
        pz=(pz-pz.min())*f2m
        # Create a mask that selects the points within the specified boundary
        lonW,lonE,latS,latN,zbot,ztop=bnd_lim
        mask = (plat >= latS) & (plat <= latN) & (
            plon >= lonW) & (plon <= lonE) & (pz >= zbot) & (pz <= ztop)

        # Apply the mask to the point positions to extract the points within the boundary
        plon = plon[mask]
        plat = plat[mask]
        pz = pz[mask] 

        fig = plt.figure(
            figsize=[FIG_WIDTH, FIG_HEIGHT],dpi=150)

        ax = fig.add_axes(FRM_MARGIN, projection='3d')
   
        res = len(topo_lon[0,:])
        # camera position in xyz
        xyz = np.array(__sph2cart(*__sphview(ax)), ndmin=3).T   
        # "distance" of bars from camera
        zo = np.multiply(
            [topo_lon, topo_lat, np.zeros_like(topo_z)], xyz).sum(0)  
        bars = np.empty(topo_lon.shape, dtype=object)

        #ncmap = ListedColormap(["red","blue","green"])
        #cnlevels = np.concatenate(
        #    (np.arange(-3150,0,50),np.arange(0,6150,150)))
        cnlevels = np.concatenate(
            (np.arange(-315,0,5),np.arange(0,615*color_zoom,15*color_zoom)))


        for i,(x,y,dz,o) in enumerate(__ravzip(
            topo_lon, topo_lat,topo_z, zo)):
            for nll in range(0,len(cnlevels),1):
                if nll==0 and dz<cnlevels[nll]:
                    color0 = ncmap([nll])
                    break
                elif (nll>0 and nll<(len(cnlevels)-1)) and (
                    dz>=cnlevels[nll-1] and dz<cnlevels[nll]):
                    color0 = ncmap([nll])
                    break
                elif nll==(len(cnlevels)-1) and dz>=cnlevels[nll]:
                    color0 = ncmap([nll+1])

            j, k = divmod(i, res)
            bars[j, k] = pl = ax.bar3d(x, y, 0, dx, dy, dz, color0)
            pl._sort_zpos = o
        scatter=ax.scatter(
            plon, plat,pz, c=pconcen, cmap='viridis', marker='o',
            zorder=999999, s=40, alpha=1, vmin=20, vmax=80,edgecolors='black')   
        ax.set_facecolor('k')
        ax.set_zscale('log')
        ax.set_xlim(lonW,lonE)
        ax.set_ylim(latS,latN)
        ax.set_zlim(zbot, ztop)
        ax.view_init(
            elev=cam_elev0+cam_elevr*gidx, 
            azim=cam_azim0+cam_azimr*gidx)
        ax.grid(False)
        ax.annotate(
            'Helicopter Observed Ozone (ppb)@%s' % ts.strftime('%Y-%m-%d %H:%M'),
            xy=(0.5, 0.95), xycoords='axes fraction', ha='center', 
            va='top', fontsize=MIDFONT, color='white')        
        
        plt.axis('off')
        cbar = plt.colorbar(scatter, shrink=0.7)
        # set the font size, background color, and font color of the colorbar
        cbar.ax.tick_params(labelsize=18,colors='white', 
                            labelcolor='white')
        # set the background color of the Figure, Axes, and colorbar to black
        fig.set_facecolor('black')
        cbar.ax.set_facecolor('black')        
       
        figpath='../fig/helicopter_%s.png' % ts.strftime('%Y%m%d_%H%M%S')
        plt.savefig(figpath, dpi=150)
        plt.close('all')
        print(
            '%sTASK[%04d]: subtask (%04d/%04d) render3D done!' % (
                print_prefix, itsk, subid+1, len_seg))
        gc.collect()
        # break for test
        # break
    return 0


@nb.njit(parallel=True)
def check_collision(
        plat, plon, pz, plat1, plon1, pz1,
        latmin, lonmin, zmin):
    
    # initialize the collision array
    collision = np.zeros_like(plat1, dtype=np.bool_)

    # loop over particles in group2
    for i in nb.prange(plat1.shape[0]):
        # compute the distances between the i-th particle in group2
        # and all particles in group1
        dlat = np.abs(plat1[i] - plat)
        dlon = np.abs(plon1[i] - plon)
        dz = np.abs(pz1[i] - pz)

        # check if any particle in group1 collides with the i-th particle in group2
        if np.any((dlat < latmin) & (dlon < lonmin) & (dz < zmin)): 
            collision[i] = True
    return collision

def __sph2cart(r, theta, phi):
    '''spherical to cartesian transformation.'''
    x = r * np.sin(theta) * np.cos(phi)
    y = r * np.sin(theta) * np.sin(phi)
    z = r * np.cos(theta)
    return x, y, z

def __sphview(ax):
    '''returns the camera position for 3D axes in spherical coordinates'''
    r = np.square(
        np.max([ax.get_xlim(), ax.get_ylim()], 1)).sum()
    theta, phi = np.radians((90-ax.elev, ax.azim))
    return r, theta, phi

def __ravzip(*itr):
    '''flatten and zip arrays'''
    return zip(*map(np.ravel, itr))

 
    
        
def __get_topo_data(topo_file, latN, latS, lonW, lonE):
    '''
    get topo data from topo file
    '''
    #topo_file=os.path.join(topo_path,'db/', fn)
    if not(os.path.exists(topo_file)):
        print(
            print_prefix+topo_file+' not exist, skip...')
        return None
    else:
        print(print_prefix+'load topo data from '+topo_file)
        topo=xr.open_dataset(topo_file)
    topo=topo.sel(y=slice(latS,latN), x=slice(lonW,lonE))
    topo_lat,topo_lon,topo_z=topo['y'], topo['x'], topo['z']
    
    return topo_lat,topo_lon,topo_z


if __name__ == '__main__':
    main()