#!/usr/bin/env python
from ecmwfapi import ECMWFDataServer
server = ECMWFDataServer()
for ii in range(1979,2020):
    parser_list=[str(100*ii+imon)+'01' for imon in range(1,7)]
    date_str='/'.join(parser_list)
    print(date_str)
    server.retrieve({
        "class": "ei",
        "dataset": "interim",
        "date": date_str,
        "expver": "1",
        "grid": "1.00/1.00",
        "levtype": "sfc",
        "param": "34.128",
        "stream": "moda",
        "type": "an",
        "target": str(ii)+".interim.sst.grib",
    })
