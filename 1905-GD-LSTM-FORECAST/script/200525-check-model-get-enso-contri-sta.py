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
    result_in_file='/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/json_base/south_china_result.json'

#----------------------------------------------------
# Main function
#----------------------------------------------------
    
    with open(result_in_file) as f:
        result_dic=json.load(f)
    

    feat_list=['nino34_lag'+str(itm) for itm in range(1,25)]

    nino_dict={key:0 for key in feat_list}

    nsta=0
    for idx, itm in result_dic.items():
        nino_list = list(set(itm['w_name']).intersection(set(feat_list)))
        nsta=nsta+1
        if len(nino_list) >0:
            print(idx)
            for itm in nino_list:
                nino_dict[itm]=nino_dict[itm]+1

    print(sorted(nino_dict.items(), key=lambda d: d[1]))
if __name__ == "__main__":
    main()


