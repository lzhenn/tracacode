import cdsapi
import datetime

int_time_obj = datetime.datetime.strptime('20180912', '%Y%m%d')
end_time_obj = datetime.datetime.strptime('20180914', '%Y%m%d')
file_time_delta=datetime.timedelta(days=1)
curr_time_obj = int_time_obj

c = cdsapi.Client()

while curr_time_obj <= end_time_obj:
    c.retrieve(
        'reanalysis-era5-pressure-levels',
        {
            'product_type':'reanalysis',
            'format':'grib',
            'pressure_level':[
                '1','2','3',
                '5','7','10',
                '20','30','50',
                '70','100','125',
                '150','175','200',
                '225','250','300',
                '350','400','450',
                '500','550','600',
                '650','700','750',
                '775','800','825',
                '850','875','900',
                '925','950','975',
                '1000'
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
            ],
            'variable':[
                'geopotential','relative_humidity','specific_humidity',
                'temperature','u_component_of_wind','v_component_of_wind'
            ]
        },
        curr_time_obj.strftime('%Y%m%d')+'-pl.grib')
    curr_time_obj=curr_time_obj+file_time_delta
