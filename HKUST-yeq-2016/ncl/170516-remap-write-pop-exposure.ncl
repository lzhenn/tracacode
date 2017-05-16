;*****************************************************
;Missions:
;   1. Read ggas data of RCP4.5 forcing field
;   2. Calculate 2026-2035 mean
;   3. Draw the Monthly Timeseries of CO2
;                   Zhenning Li
;                    2015-01-22
;*****************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_SELFLIB/../shp/cnmap/cnmap.ncl"
;================================================
;Variables List:
;	var1--------------CO2
;	var2--------------CH4
;	var3--------------N2O
;	var4--------------f11
;	var5--------------f12
;================================================



begin
    
    ;grid file
    grid_fn="/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/HKUST_yeq-2016/gridsys/GRIDCRO2D_3km"
    
    ;Resident time file
    data_file_name1="/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/HKUST_yeq-2016/resident-time_output/data/hysplit/prd/population/exposure/"
   
    ;Output file 
    pdata_fn     = data_file_name1+"/exposure.nc"  ; open output netCDF file

    ;Fig name
    g_fig_name="../fig/exposure"
    
    ;Fig title
    fig_title="Exposure"

    ;Time
    time_unit="hours since 2015-01-01 00:00:0.0"

    g_font=0.025
    ;Number of points
    n_pts=16720
;---------------Read data-------------------
    all_res_files = systemfunc ("ls "+data_file_name1+"/exp_*"); ../"+case_name+"/"+exedir+"/*cam.h0.002[0-4]*")

    len_time=dimsizes(all_res_files)

;---------------Read lat-lon config-------------------
    latlon_in   =  addfile(grid_fn,"r")
    lat2d = latlon_in->LAT(0,0,:,:)
    lon2d = latlon_in->LON(0,0,:,:)
    grid_dim=dimsizes(lat2d) 
    var1=new((/len_time,grid_dim(0),grid_dim(1)/), float)  ; just get the gridsystem, resident time
    var1@long_name="Population Exposure to Air Mass"
    var1@units="pop*hr"
    var1!0="time"
    var1!1="corx"
    var1!2="cory"
    var1&time=ispan(0,24*(len_time-1),24)
    var1&time@units=time_unit
    var1&corx=ispan(1,grid_dim(0),1)
    var1&cory=ispan(1,grid_dim(1),1)
    printVarSummary(var1)
    ; Organize points in to var1
    do ii= 0, len_time-1
        pt_record  =   asciiread(all_res_files(ii),(/n_pts,5/),"float") ; get the first file's lat lon and value
        print("Deal with exposure "+(ii+1)+"/"+(len_time))
        do jj=0, n_pts-1
            var1(ii,floattoint(pt_record(jj,0)),floattoint(pt_record(jj,1)))=(/pt_record(jj,4)/)
        end do


    end do
    
;************************************************
; High Efficiency to Write the file
;************************************************

;Get dimsize
    dims=dimsizes(var1)
    ntime=dims(0)
    ncorx=dims(1)
    ncory=dims(2)
    
;Set fileoption    
    system("rm "+pdata_fn)
    fout = addfile(pdata_fn ,"c")  ; open output netCDF file
    setfileoption(fout,"DefineMode",True)

;Set All field attribution
    fileAtt     = True
    fileAtt@creation_date=systemfunc("date")
    fileattdef(fout,fileAtt)

;Define Coordinate
    dimNames    =(/"time","corx","cory"/)
    dimSizes    =(/-1,ncorx,ncory/)
    dimUnlim    =(/True,False,False/)
    filedimdef(fout,dimNames,dimSizes,dimUnlim)

;Define var, type and dim
    filevardef(fout,"time",typeof(var1&time),getvardims(var1&time))
    filevardef(fout,"corx",typeof(var1&corx),getvardims(var1&corx))
    filevardef(fout,"cory",typeof(var1&cory),getvardims(var1&cory))
    filevardef(fout,"exposure",typeof(var1),getvardims(var1))

;Define Attribute
    filevarattdef(fout,"exposure",var1)
    filevarattdef(fout,"time",var1&time)
    
    fout->time=(/var1&time/)
    fout->corx=(/var1&corx/)
    fout->cory=(/var1&cory/)
    fout->exposure=(/var1/)

    ; make time and UNLIMITED dimension      ; recommended  for most applications
;    filedimdef(fout,"time",-1,True) 
end




