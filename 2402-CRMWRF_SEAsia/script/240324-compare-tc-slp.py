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
   
    line_libs=['b-^','r--','g-s']
    
    df_obv=io.get_ibtrack('MANGKHUT','2018')
    case_names=['201809','201809_WSM6']
    
   
    #df_obv=df_obv[df_sim.index[0]:]
    fig,ax = plt.subplots(figsize=(4,4))
    #fig.subplots_adjust(left=0.08, bottom=0.18, right=0.95, top=0.92, wspace=None, hspace=None) 
    plt.plot(df_obv['HKO_PRES'], label='HKO best', marker='o', color='black')
    for idx,case_name in enumerate(case_names):
        work_dir=f'/home/lzhenn/SEAtest/{case_name}'
        df_sim=pd.read_csv(
            f'{work_dir}/tc_track.csv', parse_dates=['time'],index_col=['time'])
        plt.plot(df_sim['slp'],line_libs[idx], label=case_name)
        
    # end for: casenames
    
    plt.legend(loc='best', fontsize=SMFONT)
    plt.xlabel('Time',fontsize=SMFONT)
    plt.ylabel('SLP (hPa)',fontsize=SMFONT)
    plt.xticks(fontsize=SMFONT)
    #plt.xticks(fontsize=SMFONT,rotation=-30)
    plt.yticks(fontsize=SMFONT)
    
   # pletp(ax.get_xticklabels(), rotation=-60, ha="right",
   # rotation_mode="anchor")
    
    plt.title('TC Strength Evolution', fontsize=BIGFONT)
    fig.set_size_inches(width, height)
    fig.savefig(f'../fig/ts_slp.png', bbox_inches='tight', dpi=100)

   
    
if __name__ == "__main__":
    main()



