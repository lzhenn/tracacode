;************************************************************
;Aim: Regression SST anomaly from TCP_index, and insert these 
;     anomalies to clim SST
;     
;
;Mission:
;   1. Read index data from ascii file, read sst data
;   2. Post process
;       2.1 Regression NINO3
;       2.2 Departure NINO3 signal from Anomaly pattern
;       2.3 Detrend
;       2.4 Regression TCP
;
;   3. Draw patterns 
;   4. Output SST forcing field
;                       Zhenning Li
;                       2015-01-18
;Last Edited:
;   2015-01-18  Create
;*************************************************************

begin
    data_file_in   =   "/users/yangsong3/CESM/input/ocn/pop/gx1v6/grid/region_mask_20090205.ieeei4"

    setfileoption("bin","ReadByteOrder","BigEndian")
    
    idx = fbindirread (data_file_in, 0, -1, "integer")
    print(idx)
    exit
    bath = 25
    setfileoption("bin","ReadByteOrder","LittleEndian")
    fbindirwrite(data_file_out, bath)
end
