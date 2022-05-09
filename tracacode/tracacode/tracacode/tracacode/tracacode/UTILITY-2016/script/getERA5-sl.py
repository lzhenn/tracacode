import cdsapi
import datetime

int_time_obj = datetime.datetime.strptime('20180912', '%Y%m%d')
end_time_obj = datetime.datetime.strptime('20180914', '%Y%m%d')
file_time_delta=datetime.timedelta(days=1)
curr_time_obj = int_time_obj
c = cdsapi.Client()
while curr_time_obj <= end_time_obj:
    c.retrieve(
        'reanalysis-era5-single-levels',
        {
            'product_type':'reanalysis',
            'format':'grib',
            'variable':[
                '10m_u_component_of_wind','10m_v_component_of_wind','2m_dewpoint_temperature',
                '2m_temperature','land_sea_mask','mean_sea_level_pressure',
                'sea_ice_cover','sea_surface_temperature','skin_temperature',
                'snow_depth','soil_temperature_level_1','soil_temperature_level_2',
                'soil_temperature_level_3','soil_temperature_level_4','surface_pressure',
                'volumetric_soil_water_layer_1','volumetric_soil_water_layer_2','volumetric_soil_water_layer_3',
                'volumetric_soil_water_layer_4'
            ],
            'date':curr_time_obj.strftime('%Y%m%d'),
            'area':'40/90/0/140',
            'time':[
                '00:00','01:00','02:00',
                '03:00','04:00','05:00',
                '06:00','07:00','08:00',
                '09:00','10:00','11:00',
                '12:00','13:00','14:00',
                '15:00','16:00','17:00',
                '18:00','19:00','20:00',
                '21:00','22:00','23:00',
            ]
        },
        curr_time_obj.strftime('%Y%m%d')+'-sl.grib')
    curr_time_obj=curr_time_obj+file_time_delta
