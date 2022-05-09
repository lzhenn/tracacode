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
from sklearn.linear_model import LassoCV, Lasso
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
    
    obv_path='../data/1911-COAWST/sandy/bouy44009'
    sen_path='../data/1911-COAWST/sandy/bouy44009-sim.txt'

    dti = pd.date_range('2012-10-28 12:00:00', periods=97, freq='30min')
    df_obv=pd.read_csv(obv_path,sep='\s+')
    df_cpl=pd.read_csv(sen_path,sep='\s+')
    df_cpl['time']=dti
    df_cpl.set_index('time', inplace=True, drop=True)
    
    df_time=df_obv[['YY', 'MM', 'DD', 'hh', 'mm']]
    df_time=df_time.rename(columns={'YY': 'year', 'MM': 'month','DD':'day','hh':'hour','mm':'minute'})
    dti=pd.to_datetime(df_time[['year', 'month', 'day', 'hour', 'minute']],format='%Y%m%d%H%M')
    df_obv['time']=dti
    df_obv.set_index('time', inplace=True, drop=True)
    
    fig, ax = plt.subplots()
    
    plt.plot(df_cpl['hgt'], label='SWAN Sim', color='blue')
    plt.plot(df_obv['WVHT'], label='Bouy 44009', marker='o', color='black')

    plt.legend(loc='best', fontsize=SMFONT)
    plt.xlabel('Time',fontsize=SMFONT)
    plt.ylabel('SigH (m)',fontsize=SMFONT)
    plt.xticks(fontsize=SMFONT,rotation=-30)
    plt.yticks(fontsize=SMFONT)
    
    plt.title('SigH Simulation by SWAN', fontsize=BIGFONT)
    fig.tight_layout()
    plt.show()


   # savefig('../fig/tc-hsig.png')

   
    
if __name__ == "__main__":
    main()



