#!/usr/bin/python
# -*- coding: UTF-8 -*- 

#--------------User defined parameters--------------
# Inventory type (options: ARINV/MBINV/PTINV)
inv_type="ARINV"

# Inventory file path
inv_path="../data/obv/2005/mobile/pathv1_hk_mobile.txt"

# Pollutant ID
pt_id=1

# Headlines
headlines=6

# Output file path
opt_path="../data/obv/2005/mobile/pathv1_hk_mobile-reduced-50pt.txt"

# Scaling factor
scale_f=0.5

#---------------Operation----------------------
fr = open(inv_path, "r")
fw = open(opt_path, "w")
lines = fr.readlines()
ii=0
for item in lines:
    ii=ii+1
    if  ii <= headlines:
        print item
        fw.write(item)
    else:
        scl_itm=float(item[15:25])*scale_f
        item_rec=item[:15]+"%10s"% scl_itm+item[25:]
        fw.write(item_rec)
fr.close()
fw.close()
