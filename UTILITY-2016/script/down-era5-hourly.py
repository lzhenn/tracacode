import cdsapi
c = cdsapi.Client()

var='specific_humidity'

for year in range(1978,2004):
    for mon in ['01','02','03','04','05','06','07','08','09','10','11','12']:
        timestamp=year*100+int(mon)
        if timestamp < 197901:
            print(str(timestamp)+' downloaded')
            continue 
        try:
            c.retrieve(
                'reanalysis-era5-pressure-levels-monthly-means',
                {
                    "variable": var,
                    "product_type": "reanalysis",
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
                    'year':str(year),
                    'month':mon,
                    'format':'grib'
                },
                var+str(year)+mon+'pl.grib')
        except:
            # just another try...
            c.retrieve(
                            'reanalysis-era5-pressure-levels-monthly-means',
                            {
                                "variable": var,
                                "product_type": "reanalysis",
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
                                'year':str(year),
                                'month':mon,
                                'format':'grib'
                            },
                            var+str(year)+mon+'pl.grib')

