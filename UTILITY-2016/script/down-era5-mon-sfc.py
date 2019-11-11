import cdsapi
c = cdsapi.Client()

var='10m_u_component_of_wind'

for year in range(1978,2019):
    for mon in ['01','02','03','04','05','06','07','08','09','10','11','12']:
        timestamp=year*100+int(mon)
        if timestamp < 197901:
            print(str(timestamp)+' downloaded')
            continue 
        try:
            c.retrieve(
                'reanalysis-era5-single-levels-monthly-means',
                    {
                'variable':[
                '10m_u_component_of_wind','10m_v_component_of_wind','2m_dewpoint_temperature',
                '2m_temperature','mean_sea_level_pressure','mean_wave_direction',
                'mean_wave_period','sea_surface_temperature','significant_height_of_combined_wind_waves_and_swell',
                'surface_pressure','total_precipitation'
                    ],  
                    
                    "product_type": "reanalysis",
                    'year':str(year),
                    'month':mon,
                    'format':'grib'
                },
                'sfc'+str(year)+mon+'.grib')
        except:
            # just another try...
            c.retrieve(
                'reanalysis-era5-single-levels-monthly-means',
                    {
                'variable':[
                '10m_u_component_of_wind','10m_v_component_of_wind','2m_dewpoint_temperature',
                '2m_temperature','mean_sea_level_pressure','mean_wave_direction',
                'mean_wave_period','sea_surface_temperature','significant_height_of_combined_wind_waves_and_swell',
                'surface_pressure','total_precipitation'
                    ],  
                    
                    "product_type": "reanalysis",
                    'year':str(year),
                    'month':mon,
                    'format':'grib'
                },
                'sfc'+str(year)+mon+'.grib')

