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

    # arguments in
    args=sys.argv
    
    PRE_DIR=args[1]
    OBV_TCK=args[2]
    FIG_DIR_ROOT=args[3]
    COMP1_TSTRT=datetime.datetime.strptime(args[4],'%Y%m%d%H')
    COMP1_TEND=datetime.datetime.strptime(args[5],'%Y%m%d%H')
    casenames=args[6:]

    # Read Obv Data
    obv_path=PRE_DIR+'/'+OBV_TCK
    
    dateparse = lambda x: pd.datetime.strptime(x, '%Y%m%d%H')
    df_obv=pd.read_csv(obv_path,parse_dates=True,index_col='time', sep='\s+', date_parser=dateparse)
   
   
    fig, ax = plt.subplots()
    df_obv_period=df_obv[((df_obv.index>=COMP1_TSTRT)&(df_obv.index<=COMP1_TEND))]
    df_obv_period=df_obv_period.astype({'slp': 'float'})
    df_obv_period=df_obv_period.dropna()
    plt.plot(df_obv_period['slp'], label='CMA best', marker='o', color='black')
    # Deal with cases
    dateparse = lambda x: pd.datetime.strptime(x, '%Y%m%d%H%M%S')
    for casename in casenames:
        
        sen_path=PRE_DIR+'/'+casename+'/trck.'+casename+'.d01'
        print(sen_path)
#        dti = pd.date_range('2018-09-14 12:00:00', periods=72, freq='60min')
        
        df_sen=pd.read_csv(sen_path,parse_dates=True,index_col='timestamp', sep='\s+', date_parser=dateparse)
        df_sen_period=df_sen[((df_sen.index>=COMP1_TSTRT)&(df_sen.index<=COMP1_TEND))]
#        df_sen_period=df_sen_period.astype({'slp': 'float'})
#        df_sen_period=df_sen_period.dropna()


        #df_cpl['time']=dti
        #df_cpl.set_index('time', inplace=True, drop=True)
        
                
        plt.plot(df_sen_period['minSLP'], label=casename)
    # end for: casenames
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



