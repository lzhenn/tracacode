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
    
    ctrl_path='../data/1911-COAWST/joe_tc_ctrl/tc_wind.txt'
    sen_path='../data/1911-COAWST/joe_tc_sen/tc_wind.txt'

    df_ctrl=pd.read_csv(ctrl_path, sep='\s+')
    df_sen=pd.read_csv(sen_path, sep='\s+')
    
    fig, ax = plt.subplots()
    plt.plot(df_ctrl['ws'], label='CTRL', color='blue')
    plt.plot(df_sen['ws'], label='SEN', color='red')
    plt.legend(loc='best', fontsize=SMFONT)
    plt.xlabel('Hrs since Simulation',fontsize=SMFONT)
    plt.ylabel('Wind Speed (m/s)',fontsize=SMFONT)
    plt.xticks(fontsize=SMFONT)
    plt.yticks(fontsize=SMFONT)
    
    plt.title('TC Strength Evolution', fontsize=BIGFONT)
    fig.tight_layout()
    plt.show()
    savefig('../fig/tc-develop-wind-ts.png')

   
    
if __name__ == "__main__":
    main()



