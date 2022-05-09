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
import matplotlib.pyplot as plt
# sphinx_gallery_thumbnail_number = 2

#-------------------------------------
# Function Definition Part
#-------------------------------------


def main():

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------

    # Result Input File
    result_in_file='/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/json_base/whole_china_prec_result.json'

#----------------------------------------------------
# Main function
#----------------------------------------------------
    
    with open(result_in_file) as f:
        result_dic=json.load(f)
    
    score_acc=[]
    stas=[]
    nsta=0

    features=['Y_lag'+str(itm) for itm in range(1,25)]

    for idx, itm in result_dic.items():
        score_acc.append(itm['sign_score'])
        nsta=nsta+1
        if nsta%80 ==0:
            print("%4.2f" % np.mean(score_acc[nsta-12:nsta]))
    print("whole mean: %4.2f" % np.mean(score_acc))
if __name__ == "__main__":
    main()


