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


#-------------------------------------
# Function Definition Part
#-------------------------------------
def main():

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------

    # Result Input File
    result_in_file='../testdata/result_81-07.json'

    # South China Input
    sta_file='../testdata/south_china_station.csv'


    # Out File
    out_file='../testdata/south_china_result.csv'

    # Least Start Year 
    start_year=1981
    
    # End Year
    end_year=2007

    # Var Name 
    var_name='TEM' 

#----------------------------------------------------
# Main function
#----------------------------------------------------
    
    sta_pt=pd.read_csv(sta_file,  index_col=0)
    with open(result_in_file) as f:
        result_dic=json.load(f)
    n_sta=len(result_dic)

    nyears=(end_year-start_year+1)
    
    sign_mtx=np.zeros((12*nyears,n_sta))
    
    ii=0
    for idx, itm in result_dic.items():
        try:
            sign_mtx[:,ii]=np.array(itm['sign_matrix'])
            ii=ii+1
        except:
            continue
    n_sta=ii
    sign_mtx=sign_mtx[:,0:n_sta]
    print(sign_mtx.shape)
    for ii in range(0,12):
        print(sum(sum(sign_mtx[ii::12,:]))/(n_sta*nyears))
    exit()
    
    # plot baseline and predictions
    obv=scaler.inverse_transform(dataset)
    plt.plot(obv[:])
    plt.plot(trainPredictPlot[:])
    plt.plot(testPredictPlot[:])
    plt.legend(['obs','train_fcst','test_fcst'], loc='best', ncol=2 )
    plt.show()
    savefig('../fig/test.png')
    




if __name__ == "__main__":
    main()




