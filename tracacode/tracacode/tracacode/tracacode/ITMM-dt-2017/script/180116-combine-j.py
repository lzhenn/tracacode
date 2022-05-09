#! /usr/bin/env python
#  Deal with splined data 
#   
#               L_Zealot
#               Oct 16, 2017
#               Guangzhou, GD
#
import math
import os
import numpy as np
import pandas as pd
import datetime
import decimal
#-------------------------------------
# Function Definition Part
#-------------------------------------
def main():

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------

    # Station Number
    sta_num='67605'

    # Input File
    in_dir='/home/yangsong3/L_Zealot/project/ITMM-dt-2017/data/ITMM-dt-2017/17-18new/'+sta_num+'/J/pro_data/'

    out_dir= in_dir
    
    # Species
    species=['H2O2','HCHO_M','HCHO_R','HONO','NO3_M','NO3_R','NO2','O1D']

    # Correct Algrithm
    #   C1 -- Both j and splined
    #   C2 == Only j
    corr_algthm='C1' 

#----------------------------------------------------
# Main function
#----------------------------------------------------
    # Parser hourly data
    pt_all=pd.read_csv(in_dir+get_file_name(sta_num, corr_algthm, species[0], 'Hour'), parse_dates=True, skiprows=1, names=['time',species[0]], index_col='time')
    for pos, spe in enumerate(species):
        pt=pd.read_csv(in_dir+get_file_name(sta_num, corr_algthm, spe, 'Hour'), parse_dates=True, skiprows=1, names=['time',spe], index_col='time')
        pt_all[spe]=pt 
    writer = pd.ExcelWriter(out_dir+get_outfile_name(sta_num, 'Hour'))
    pt_all.to_excel(writer, 'hourly J')
    writer.save()

    # Parser daily data
    writer1 = pd.ExcelWriter(out_dir+get_outfile_name(sta_num, 'Daily'))
    for pos, spe in enumerate(species):
        pt=pd.read_csv(in_dir+get_file_name(sta_num, corr_algthm, spe, 'Daily'), parse_dates=True, skiprows=1, names=['time', '10H', '12H', '14H', '16H', 'max'], index_col='time')
        pt.to_excel(writer1, spe)
    writer1.save()


    # Parser monthly data
    writer1 = pd.ExcelWriter(out_dir+get_outfile_name(sta_num, 'Mon'))
    for pos, spe in enumerate(species):
        pt=pd.read_csv(in_dir+get_file_name(sta_num, corr_algthm, spe, 'Mon'), parse_dates=True, skiprows=1, names=['time', '10H', '12H', '14H', '16H', 'max'], index_col='time')
        pt.to_excel(writer1, spe)
    writer1.save()
    writer1 = pd.ExcelWriter(out_dir+get_outfile_name(sta_num, 'Mon_Std'))
    for pos, spe in enumerate(species):
        pt=pd.read_csv(in_dir+get_file_name(sta_num, corr_algthm, spe, 'Mon_Std'), parse_dates=True, skiprows=1, names=['time', '10H', '12H', '14H', '16H', 'max'], index_col='time')
        pt.to_excel(writer1, spe)
    writer1.save()

def get_file_name(sta_num, corr, spe, freq):
    fname='j'+spe+'_'+sta_num+'_'+corr+'_'+freq+'.csv'
    return fname

def get_outfile_name(sta_num, freq):
    fname='j'+'_'+sta_num+'_'+freq+'.xlsx'
    return fname


if __name__ == "__main__":
    main()




