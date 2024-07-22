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
   
    
    df_obv=io.get_ibtrack('MANGKHUT','2018')
    simdir1='/home/lzhenn/array74/data/archive/njord/2018091200'
    simdir2='/home/lzhenn/array74/data/archive/njord/2018091200pgw_free'
    
    df_sim1=pd.read_csv(
        f'{simdir1}/tc_track.csv', parse_dates=['time'],index_col=['time'])
    df_sim2=pd.read_csv(
        f'{simdir2}/tc_track.csv', parse_dates=['time'],index_col=['time'])
    
    df_obv=df_obv[df_sim1.index[0]:df_sim1.index[-1]]
    
   
    #line_libs=['b','b-s','b-^','b-v','b--','r','r-v','r--','g-s','g--']
    
    
   
    fig, ax = plt.subplots()
    fig,ax = plt.subplots(figsize=(4,4))
    #fig.subplots_adjust(left=0.08, bottom=0.18, right=0.99, top=0.92, wspace=None, hspace=None) 
    plt.plot(df_obv['HKO_PRES'], label='HKO best', marker='o', color='black')
    plt.plot(df_sim1['slp'],'b-^', label='CURRENT')
    plt.plot(df_sim2['slp'],'r-^', label='FUTURE')
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
    fig.savefig('../fig/tc-minSLP-evolve.png')

   
    
if __name__ == "__main__":
    main()



