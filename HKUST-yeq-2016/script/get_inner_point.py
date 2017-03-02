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
import datetime

start_time='2015-01-01 00:00:00'
end_time='2015-01-27 00:00:00'

# Integration step in Hour
int_step=12

# Number of points
npoints=16720

#Operation
int_time_obj = datetime.datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
end_time_obj = datetime.datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')
time_delta=datetime.timedelta(hours=int_step)

# parser path
inv_path='/home/yangsong3/data/model/L_Zealot/HKUST_yeq-2016/resident-time_output/data/hysplit/traj_200m/'



#Parser

polygon = shapefile.Reader('../../UTILITY-2016/shp/PRD/PRD.shp') 
polygon = polygon.shapes()  

pt_dic={}
fr = open(inv_path+'points', 'r')
point_list=fr.readlines()

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
            break

jsObj = json.dumps(pt_dic)  

fileObject = open(inv_path+'inner_point.json', 'w')  
fileObject.write(jsObj)  
fileObject.close()  













