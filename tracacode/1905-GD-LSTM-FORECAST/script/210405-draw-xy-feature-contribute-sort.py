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
    result_in_file='/home/metctm1/array/workspace/spellcaster-local/json_base/whole_china_prec_full_XY_result.json'

#----------------------------------------------------
# Main function
#----------------------------------------------------
    
    with open(result_in_file) as f:
        result_dic=json.load(f)
    
    features_acc=[]
    stas=[]
    nsta=0

    features=['Y_lag'+str(itm) for itm in range(1,25)]
    for idx, itm in result_dic.items():
        try:
            features_acc=list(set(itm['w_name']).union(set(features_acc)))
            stas.append(idx)
            nsta=nsta+1

        except:
            continue # one station with empty return
    features.extend(features_acc)
    features = sorted(set(features),key=features.index) # rm duplicated records
    #features.sort()
    print(len(features))
    nfea=len(features)

    print(features)
    
    data=np.zeros((nfea, nsta))


    # fill in the heatmap array
    ista=0
    for idx, itm in result_dic.items():
        try: 
            names=itm['w_name']
            wgts=itm['w']
            for (iname,iwgt) in zip(names,wgts):
               ipos=features.index(iname)
               data[ipos,ista]=iwgt
            ista=ista+1
        except:
            continue
    data=data*data
    fctr_sum=np.sum(data, axis=1)
    sort_arr=np.argsort(fctr_sum)
    sort_arr=sort_arr[::-1]
    features=[features[itm] for itm in sort_arr]
    fctr_sum.sort()
    fctr_sum=fctr_sum[::-1]
    print(features)
    print(fctr_sum)
    
    fig = plt.figure(figsize=[10, 5],frameon=True)
    ax = fig.add_axes([0.08, 0.05, 0.8, 0.94])
    line=ax.stem(np.linspace(1, 258, num=258),fctr_sum)
    
    ax.set_yscale('log')
    plt.xlabel('Features',fontsize=BIGFONT)
    plt.ylabel('Accum Var',fontsize=BIGFONT)
    plt.xticks(fontsize=MIDFONT)
    plt.yticks(fontsize=MIDFONT)
    plt.ylim((1e-1, 1e4)) 
    plt.xlim((1, 258)) 
    plt.title("Accumulated partial regression weight square (Pr)", fontsize=BIGFONT)

    plt.savefig('../fig/stem_features.png', dpi=120, bbox_inches='tight')

    plt.show()

if __name__ == "__main__":
    main()


