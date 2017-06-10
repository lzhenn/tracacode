#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
#
#       L_Zealot
#       Feb 28, 2017
#
#
import json
inv_path='/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/HKUST_yeq-2016/resident-time_output/data/hysplit/prd/'

#Parser
with open(inv_path+'inner_point.json', 'r') as f:
    inner_pt_dic = json.load(f)

   
fr2=open(inv_path+'inner_point.txt','w')
for item in inner_pt_dic.values():
    fr2.write('%8.3f %8.3f\n' % (item[0], item[1]))
fr2.close()


