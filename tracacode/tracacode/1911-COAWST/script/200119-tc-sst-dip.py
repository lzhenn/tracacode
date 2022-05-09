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
    
    ctrl_path='../data/1911-COAWST/joe_tc_ctrl/sst_point.txt'

    df_ctrl=pd.read_csv(ctrl_path, sep='\s+')
    
    fig, ax = plt.subplots()
    df_ctrl['sst']=df_ctrl['sst']-29.28995
    plt.plot(df_ctrl['sst'], color='blue')
    plt.legend(loc='best', fontsize=SMFONT)
    plt.xlabel('Hrs since Simulation',fontsize=SMFONT)
    plt.ylabel('SST DIP (K)',fontsize=SMFONT)
    plt.xticks(fontsize=SMFONT)
    plt.yticks(fontsize=SMFONT)
    
    plt.title('SST Dip at the TC Passage', fontsize=BIGFONT)
    fig.tight_layout()
    plt.show()
    savefig('../fig/tc-sst.png')

   
    
if __name__ == "__main__":
    main()



