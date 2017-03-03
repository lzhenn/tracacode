#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
#
#       L_Zealot
#       Feb 28, 2017
#
#
import json

inv_path='./'

#Parser
with open(inv_path+'record.json', 'r') as f:
    pt_dic = json.load(f)

pt_list=[]
n=0
fr=open('record.txt','w')
for item in pt_dic.values():
    lat=item['lat']
    lon=item['lon']
    value=item['value']
    fr.write('%8.3f %8.3f %4d\n' % (lat, lon, value))
    pt_list.append([item['lat'], item['lon'], item['value']])
    n=n+1
    
fr.close()
