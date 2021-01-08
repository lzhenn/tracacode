#! /usr/bin/env python
#   Plot TC intensity comparison, cases vs obv 
#   
#               L_Zealot
#               Apr 29, 2020
#               Clear Water Bay, HK 
#

import os, sys
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
    
    # constants
    BIGFONT=22
    MIDFONT=18
    SMFONT=14
    width= 10.0
    height=10.0
    
    #line_libs=['b','b-s','b-^','b-v','b--','r','r-v','r--','g-s','g--']
    line_libs=['r-^','r-s','b-.*','g--o']
    
    # arguments in
    
    PRE_DIR='/home/metctm1/array/data/1911-COAWST/'
    OBV_TCK='hko.trck.mangkhut'
    FIG_DIR_ROOT='../../fig/paper/'
    COMP1_TSTRT=datetime.datetime.strptime('2018091506','%Y%m%d%H')
    COMP1_TEND=datetime.datetime.strptime('2018091700','%Y%m%d%H')
    IDOM='2'
    casenames=["C2008", "TY2001", "WRFROMS", "WRFONLY"]

    # Read Obv Data
    obv_path=PRE_DIR+'/'+OBV_TCK
    
    dateparse = lambda x: datetime.datetime.strptime(x, '%Y%m%d%H')
    df_obv=pd.read_csv(obv_path,parse_dates=True,index_col='time', sep='\s+', date_parser=dateparse)
   
   
    fig, ax = plt.subplots(2, 1)

    #fig,ax = plt.subplots(figsize=(10,4))
    fig.subplots_adjust(left=0.08, bottom=0.18, right=0.99, top=0.92, wspace=None, hspace=None) 
   
    df_obv_period=df_obv[((df_obv.index>=COMP1_TSTRT)&(df_obv.index<=COMP1_TEND))]

    #slp
    df_obv_slp=df_obv_period.astype({'slp': 'float'})
    df_obv_slp=df_obv_slp.dropna()
    ax[0].plot(df_obv_slp['slp'], label='HKO best', marker='o', color='black')

    #ws
    df_obv_ws=df_obv_period.astype({'ws': 'float'})
    df_obv_ws=df_obv_ws.dropna()
    ax[1].plot(df_obv_ws['ws'], label='HKO best', marker='o', color='black')

    # Deal with cases
    dateparse = lambda x: datetime.datetime.strptime(x, '%Y%m%d%H%M%S')
    for (line_type,casename) in zip(line_libs,casenames):
        sen_path=PRE_DIR+'/'+casename+'/trck.'+casename+'.d0'+IDOM
        df_sen=pd.read_csv(sen_path,parse_dates=True,index_col='timestamp', sep='\s+', date_parser=dateparse)
        df_sen_period=df_sen[((df_sen.index>=COMP1_TSTRT)&(df_sen.index<=COMP1_TEND))]
        df_sen_period=df_sen_period[df_sen_period['minSLP']>0]
        ax[0].plot(df_sen_period['minSLP'], line_type, label=casename)
        ax[1].plot(df_sen_period['maxWS'], line_type, label=casename)
    # end for: casenames
    
    ax[0].set_title('(a) Minimum Sea Level Pressure Evolution', fontsize=MIDFONT, loc='left')
    ax[0].legend(loc='best', fontsize=SMFONT)
    ax[0].set_xlabel('Time',fontsize=SMFONT)
    ax[0].set_ylabel('minSLP (hPa)',fontsize=SMFONT)
    
    ax[1].set_title('(b) Maximum Wind Speed Evolution', fontsize=MIDFONT, loc='left')
    ax[1].legend(loc='best', fontsize=SMFONT)
    ax[1].set_xlabel('Time',fontsize=SMFONT)
    ax[1].set_ylabel('maxWS (m/s)',fontsize=SMFONT)
    for axitm in ax: 
        axitm.tick_params(axis='both', which='major', labelsize=SMFONT)
    
    fig.set_size_inches(width, height)
    fig.tight_layout()
    fig.savefig(FIG_DIR_ROOT+'/fig8-minSLP-maxWS-evolve-d0'+IDOM+'.png')

   
    
if __name__ == "__main__":
    main()



