# First example using shapefile and shapely:
import shapefile
from shapely.geometry import Polygon, Point, MultiPolygon

polygon = shapefile.Reader('../../UTILITY-2016/shp/PRD/PRD.shp') 
polygon = polygon.shapes()  
point = Point(119.0,23.0)
shpfilePoints = []
for shape in polygon:
    shpfilePoints = shape.points 
    polygon = shpfilePoints 
    poly = Polygon(polygon)

    # point in polygon test
    if poly.contains(point):
        print 'inside'
    else:
        print 'OUT'
