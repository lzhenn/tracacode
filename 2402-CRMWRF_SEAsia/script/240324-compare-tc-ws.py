#! /usr/bin/env python
#   Plot TC intensity comparison, cases vs obv 
#   
#               L_Zealot
#               Apr 29, 2020
#               Clear Water Bay, HK 
#


import pandas as pd
import matplotlib
matplotlib.use('Agg') 
import matplotlib.pyplot as plt
import datetime
from matplotlib.pyplot import savefig
from uranus_viewer.lib import io

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------
def main():
    # constants
    BIGFONT=22
    MIDFONT=18
    SMFONT=16
    width=15.0
    height=7.0
   
    
    df_obv=io.get_ibtrack('HAIYAN','2013')
    work_dir='/home/lzhenn/SEAtest/201311'
    df_sim=pd.read_csv(
        f'{work_dir}/tc_track.csv', parse_dates=['time'],index_col=['time'])
    df_era5=pd.read_csv(
        f'{work_dir}/tc_track.era5.csv', parse_dates=['time'],index_col=['time'])
    
    df_obv=df_obv[df_sim.index[0]:]
    
    #line_libs=['b','b-s','b-^','b-v','b--','r','r-v','r--','g-s','g--']
    
    
   
    fig,ax = plt.subplots(figsize=(4,4))
    #fig.subplots_adjust(left=0.08, bottom=0.18, right=0.95, top=0.92, wspace=None, hspace=None) 
    plt.plot(df_obv['HKO_WIND']/3.6, label='HKO best', marker='o', color='black')
    plt.plot(df_sim['wsmax'],'r-^', label='WRF')
    plt.plot(df_era5['wsmax'],'b-^', label='ERA5')
    # end for: casenames
    
    plt.legend(loc='best', fontsize=SMFONT)
    plt.xlabel('Time',fontsize=SMFONT)
    plt.ylabel('WSPD (m/s)',fontsize=SMFONT)
    plt.xticks(fontsize=SMFONT)
    #plt.xticks(fontsize=SMFONT,rotation=-30)
    plt.yticks(fontsize=SMFONT)
    
   # pletp(ax.get_xticklabels(), rotation=-60, ha="right",
   # rotation_mode="anchor")
    
    plt.title('TC Strength Evolution', fontsize=BIGFONT)
    fig.set_size_inches(width, height)
    fig.savefig('../fig/tc-mxws-evolve.png')

   
    
if __name__ == "__main__":
    main()



