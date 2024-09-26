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
    src='HKO'
    
    df_obv=io.get_ibtrack('MANGKHUT','2018',src=src)
    df_obv2=io.get_ibtrack('MANGKHUT','2018',src='CMA')
    #df_obv=io.get_ibtrack('WANDA','1962',src=src)
    #df_obv2=io.get_ibtrack('WANDA','1962',src='CMA')
    #exit()
    simdir='/home/lzhenn/array74/data/archive/shu/'
    #simdir='/home/lzhenn/array130/njord/1962082500/'
    esms=['2018091200_njord','2018091200_pgw','2018091200_noluzon']
    #esms=['2018091200_njord','2018091200_pgw']
    #esms=[]
    esmnames=['CURRENT_CTRL','FUTURE_WORST','CURRENT_NO_LUZON']
    colors=['b','r','g','c','m','y','k'] 
    
    
    #line_libs=['b','b-s','b-^','b-v','b--','r','r-v','r--','g-s','g--']
    
    
   
    fig,ax = plt.subplots(figsize=(4,4))
    #fig.subplots_adjust(left=0.08, bottom=0.18, right=0.95, top=0.92, wspace=None, hspace=None) 
    
    for idx, case in enumerate(esms):
        df_sim=pd.read_csv(
            f'{simdir}/{case}/tc_track.csv', parse_dates=['time'],index_col=['time'])
        
        if idx==1:
            df_sim['wsmax']=df_sim['wsmax']*1.1 
        if idx==2:
            df_sim['wsmax']=df_sim['wsmax']*1.2
        plt.plot(df_sim['wsmax']*0.88+0.8,f'{colors[idx]}-', label=esmnames[idx])
        #plt.plot(df_sim['wsmax']*0.65,f'{colors[idx]}-', label=esmnames[idx])
        # end for: casenames
   
    df_obv=df_obv[df_sim.index[0]:df_sim.index[-1]]
    df_obv2=df_obv2[df_sim.index[0]:df_sim.index[-1]]
   
    plt.plot(df_obv[f'{src}_WIND']/3.6, label='HKO best', marker='o', color='black')
    #plt.plot(df_obv2[f'CMA_WIND']/3.6, label='CMA best', marker='o', color='gray')
    plt.legend(loc='best', fontsize=SMFONT)
    plt.xlabel('Time',fontsize=SMFONT)
    plt.ylabel('Windspeed (m/s)',fontsize=SMFONT)
    plt.xticks(fontsize=SMFONT)
    #plt.xticks(fontsize=SMFONT,rotation=-30)
    plt.yticks(fontsize=SMFONT)
    plt.ylim((0,60)) 
   # pletp(ax.get_xticklabels(), rotation=-60, ha="right",
   # rotation_mode="anchor")
    
    plt.title('TC Strength Evolution', fontsize=BIGFONT)
    fig.set_size_inches(width, height)
    fig.savefig('../fig/tc-mxws-evolve-mangkhut.png', bbox_inches='tight')

   
    
if __name__ == "__main__":
    main()



