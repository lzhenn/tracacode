#! /usr/bin/env python
#  Deal with 59287 station data 
#   
#               L_Zealot
#               Jul 17, 2019
#               Guangzhou, GD
#

import os
import json
import numpy as np
import pandas as pd
import datetime

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def main():

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------
    BIGFONT=22
    MIDFONT=18
    SMFONT=16


    # Result Input File
    result_in_file='/home/metctm1/array/workspace/spellcaster-local/json_base/whole_china_t2m_full_XY_result.json'
    result_in_file2='/home/metctm1/array/workspace/spellcaster-local/json_base/whole_china_prec_full_XY_result.json'

#----------------------------------------------------
# Main function
#----------------------------------------------------
    
    with open(result_in_file) as f:
        result_dic=json.load(f)
    
    with open(result_in_file2) as f:
        result_dic2=json.load(f)
    

    features=['lag'+str(itm) for itm in range(1,25)]
    nfea=len(features)

    print(features)
    
    data=np.zeros((nfea,2))

    # fill in the heatmap array
    for idx, itm in result_dic.items():
        try: 
            names=itm['w_name']
            wgts=itm['w']
            for (iname,iwgt) in zip(names,wgts):
                iname_part=iname.split('_')
                ipos=features.index(iname_part[1])
                data[ipos,0]=data[ipos,0]+1
        except:
            continue
 
    for idx, itm in result_dic2.items():
        try: 
            names=itm['w_name']
            wgts=itm['w']
            for (iname,iwgt) in zip(names,wgts):
                iname_part=iname.split('_')
                ipos=features.index(iname_part[1])
                data[ipos,1]=data[ipos,1]+1
        except:
            continue
        


    fig = plt.figure(figsize=[10, 4],frameon=True)
    ax = fig.add_axes([0.08, 0.05, 0.8, 0.94])

    x = np.arange(len(features))  # the label locations
    width = 0.35  # the width of the bars

    rects1 = ax.bar(x - width/2, data[:,0]/data[:,0].sum(), width, label='T2m', color='darkorange')
    rects2 = ax.bar(x + width/2, data[:,1]/data[:,1].sum(), width, label='Prec', color='dodgerblue')

    # Add some text for labels, title and custom x-axis tick labels, etc.
    plt.xlabel('lag months', fontsize=SMFONT)
    plt.ylabel('Frequency', fontsize=SMFONT)
    plt.xticks(rotation=45)
    ax.set_xticks(x)
    ax.set_xticklabels(features)
    ax.legend(fontsize=SMFONT)

    plt.title("Lag months distribution in valid features (T2m & Prec)", fontsize=SMFONT)

    plt.savefig('../fig/stem_features_lag.png', dpi=120, bbox_inches='tight')


if __name__ == "__main__":
    main()


