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
    SMFONT=16
    width=15.0
    height=9.0
    
    line_libs=['b','b-s','b-^','b-v','b--','r','r-v','r--','g-s','g--']
    
    # arguments in
    args=sys.argv
    
    PRE_DIR=args[1]
    OBV_TCK=args[2]
    FIG_DIR_ROOT=args[3]
    COMP1_TSTRT=datetime.datetime.strptime(args[4],'%Y%m%d%H')
    COMP1_TEND=datetime.datetime.strptime(args[5],'%Y%m%d%H')
    IDOM=args[6]
    casenames=args[7:]

    # Read Obv Data
    obv_path=PRE_DIR+'/'+OBV_TCK
    
    dateparse = lambda x: datetime.datetime.strptime(x, '%Y%m%d%H')
    df_obv=pd.read_csv(obv_path,parse_dates=True,index_col='time', sep='\s+', date_parser=dateparse)
   
   
    fig, ax = plt.subplots()

    #fig,ax = plt.subplots(figsize=(10,4))
    fig.subplots_adjust(left=0.08, bottom=0.18, right=0.99, top=0.92, wspace=None, hspace=None) 
   
    df_obv_period=df_obv[((df_obv.index>=COMP1_TSTRT)&(df_obv.index<=COMP1_TEND))]
    df_obv_period=df_obv_period.astype({'slp': 'float'})
    df_obv_period=df_obv_period.dropna()
    plt.plot(df_obv_period['slp'], label='CMA best', marker='o', color='black')
    # Deal with cases
    dateparse = lambda x: datetime.datetime.strptime(x, '%Y%m%d%H%M%S')
    for (line_type,casename) in zip(line_libs,casenames):
        sen_path=PRE_DIR+'/'+casename+'/trck.'+casename+'.d0'+IDOM
        df_sen=pd.read_csv(sen_path,parse_dates=True,index_col='timestamp', sep='\s+', date_parser=dateparse)
        df_sen_period=df_sen[((df_sen.index>=COMP1_TSTRT)&(df_sen.index<=COMP1_TEND))]
        plt.plot(df_sen_period['minSLP'], line_type, label=casename)
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
#    fig.tight_layout()
#    plt.show()
    fig.savefig(FIG_DIR_ROOT+'/tc-minSLP-evolve-d0'+IDOM+'.png')

   
    
if __name__ == "__main__":
    main()



