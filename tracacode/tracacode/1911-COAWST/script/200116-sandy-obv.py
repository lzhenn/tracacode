#! /usr/bin/env python
#   Try sklearn lasso model 
#   
#               L_Zealot
#               Aug 16, 2019
#               Guangzhou, GD
#

import os
import json

import numpy as np
import pandas as pd
import matplotlib
#matplotlib.use('Agg') 
import matplotlib.pyplot as plt
import datetime
from matplotlib.pyplot import savefig


#----------------------------------------------------
# User Defined Part
#----------------------------------------------------
def main():
    
    BIGFONT=22
    MIDFONT=18
    SMFONT=16
    
    obv_path='../data/1911-COAWST/sandy/sandy.obv.trck'
    sen_path='../data/1911-COAWST/sandy/sandy.cpl.trck'
    ctrl_path='../data/1911-COAWST/sandy/sandy.wrf.trck'

    dti = pd.date_range('2012-10-28 12:00:00', periods=97, freq='30min')


    df_obv=pd.read_csv(obv_path,parse_dates=True,index_col='time')
    df_cpl=pd.read_csv(sen_path, sep='\s+')
    df_wrf=pd.read_csv(ctrl_path, sep='\s+')
    df_cpl['time']=dti
    df_cpl.set_index('time', inplace=True, drop=True)
    
    df_wrf['time']=dti
    df_wrf.set_index('time', inplace=True, drop=True)
    
    fig, ax = plt.subplots()
    df_obv_period=df_obv[((df_obv.index>=dti[0])&(df_obv.index<=dti[-1]))]
    df_obv_period=df_obv_period.astype({'slp': 'float'})
    df_obv_period=df_obv_period.dropna()
    
    plt.plot(df_cpl['slp'], label='CPL', color='red')
    plt.plot(df_wrf['slp'], label='WRF_ONLY', color='blue')
    plt.plot(df_obv_period['slp'], label='IBTrACS obv', marker='o', color='black')

    plt.legend(loc='best', fontsize=SMFONT)
    plt.xlabel('Time',fontsize=SMFONT)
    plt.ylabel('SLP (hPa)',fontsize=SMFONT)
    plt.xticks(fontsize=SMFONT,rotation=-30)
    plt.yticks(fontsize=SMFONT)
    
   # pletp(ax.get_xticklabels(), rotation=-60, ha="right",
   # rotation_mode="anchor")
    
    plt.title('TC Strength Evolution', fontsize=BIGFONT)
#    fig.tight_layout()
    plt.show()
#    savefig('../fig/sandy/tc-develop-timeseries.png')

   
    
if __name__ == "__main__":
    main()



