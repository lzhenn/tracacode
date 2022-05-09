#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
#
#       L_Zealot
#       Feb 28, 2017
#
#
import json
import shapefile
from shapely.geometry import Polygon, Point, MultiPolygon


# Number of points
npoints=32224

# Out path
inv_path='/home/yangsong3/data/model/L_Zealot/HKUST_yeq-2016/resident-time_output/data/hysplit/fujian/'



#Parser

polygon = shapefile.Reader('../../UTILITY-2016/shp/Fujian/fujian.shp') 
polygon = polygon.shapes()  

pt_dic={}
fr = open(inv_path+'points-fujian-9km', 'r')
point_list=fr.readlines()

inner=0
for idx, point in enumerate(point_list):
    content=point.split()       # [4]--lat [5]--lon [6]--height
    pt_id =idx+1
    lat=float(content[4])
    lon=float(content[5])
    point = Point(lon,lat)
    for shape in polygon:
        shpfilePoints = shape.points 
        poly = Polygon(shpfilePoints)
        # point in polygon test
        if poly.contains(point):
            pt_dic[str(pt_id)]=[lat, lon]
            print(pt_dic[str(pt_id)])
            inner=inner+1
            break
print ('Total inner: %6d' % (inner))
jsObj = json.dumps(pt_dic)  

fileObject = open(inv_path+'inner_point.json', 'w')  
fileObject.write(jsObj)  
fileObject.close()  













