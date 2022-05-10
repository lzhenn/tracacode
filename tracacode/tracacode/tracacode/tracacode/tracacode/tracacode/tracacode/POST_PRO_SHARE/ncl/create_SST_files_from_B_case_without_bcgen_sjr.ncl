load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

;---------------------------------------------------------------------------------------
; Creation of SST/ICE data files to drive an F compset with data coming from a B compset.
; modified by J.R.Sun
; Regrid the SST and sea-ice data from the B compset and create files in an appropriate format 
; to run with CAM
;  
; Needed input:
; This ncl script uses single variable timeseries of monthly mean SST and aice with multi-years.
; If not available you need to create SST and aice timeseries
;---------------------------------------------------------------------------------------


;---------------------------------------------------------------------------------------
; Step 1 and 2
; Create two consistent SST/SEAICE datasets
;---------------------------------------------------------------------------------------

    runname  = "B_2000_CAM5_CN"
    startyear = 231
    endyear = 280
    year_range="123101-128012"

    pop_temp_filename     = "./B_2000_CAM5_CN.pop.h.SST.temp_23101_28012.nc"
    cice_aice_filename = "./B_2000_CAM5_CN.cice.h.aice.temp_23101_28012.nc"
  
    out_file = "./sstice_"+year_range+"_noTwiddling.nc"

    midmonth_days=(/16,15,16,16,16,16,16,16,16,16,16,16/)
    midmonth_hours=(/12,00,12,00,12,00,12,12,00,12,00,12/)
    date_frac = (/1.0d*midmonth_hours/)/24.
    datesec = (/doubletointeger(date_frac*86400.)/)

    print((/"- Opening POP and CICE output files"/))

    focn  = addfile(pop_temp_filename,"r")
    fice = addfile(cice_aice_filename,"r")
  ;  ficesh = addfile(cice_aice_sh_filename,"r")
      
    numyears=endyear-startyear+1
    ntime    = numyears*12

    print((/"- Getting dimensions from "+year_range+" POP file..."/))
    dimnames = getvardims(focn)
    dims     = getfiledimsizes(focn)
    old_nlat = dims(ind(dimnames.eq."nlat"))
    old_nlon = dims(ind(dimnames.eq."nlon"))
    print(dims)
    delete(dimnames)
    delete(dims)

    print((/"- Getting dimensions from "+year_range+" ice  ..."/))
    dimnames = getvardims(fice)
    dims     = getfiledimsizes(fice)
    nlat1    = dims(ind(dimnames.eq."nj"))
;    dims     = getfiledimsizes(ficenh)
;    nlat2    = dims(ind(dimnames.eq."nj"))
    ntottime = dims(ind(dimnames.eq."time"))
    print(dims)
    delete(dimnames)
    delete(dims)
    SEAICE_tmp = new((/ntime, old_nlat, old_nlon/), "float")    
  
    ; Variables for interpolation
    new_nlat = 180
    new_nlon = 360
    new_lat = ispan(-179,179,2)/2.
    new_lon = ispan(1,719,2)/2.
       
    ; Dimensions for variables in output files
    print((/"Setting up output file..."/))
    dimNames = (/"time", "lat", "lon"/)
    dimSizes = (/    ntime,  new_nlat,  new_nlon/)
    SST      = new(dimSizes, float)
    SEAICE   = new(dimSizes, float)
    ice_cov  = new(dimSizes, float)
    dimUnlim = (/  True, False, False/)
    date_out  = new(ntime, integer)
    date_frac_out = new(ntime, double)
    datesec_out   = new(ntime, integer)
    time_out      = new(ntime, double)
    time_out@information = "middle of month"
    time_out@calendar    = "365"
    time_out@units       = "days since 0001-01-01 00:00:00"
 
    ; Get SST from POP output, write to sst_cpl
    system("rm -f "+out_file)
    fout = addfile(out_file,"c")
    
    setfileoption(fout,"DefineMode", True)
    fatt = True
    fatt@title = "Monthly mean SST and ifrac from "+runname+" for years "+year_range
    fatt@creation_date = systemfunc("date")
    fileattdef(fout, fatt)
    
    filedimdef(fout, dimNames, dimSizes, dimUnlim)
    
    filevardef(fout, "time", "double", "time")
    filevardef(fout, "lon", "float",  "lon")
    filevardef(fout, "lat", "float", "lat")
    filevardef(fout, "date", "integer", "time")
    filevardef(fout, "datesec", "integer", "time")
    filevardef(fout, "date_frac", "double", "time")
    filevardef(fout, "SST_cpl", "float", (/"time", "lat", "lon"/))
    filevardef(fout, "SEAICE", "float", (/"time", "lat", "lon"/))
    filevardef(fout, "ice_cov", "float", (/"time", "lat", "lon"/))
    
    time_att          = 0
    time_att@information = "middle of month"
    time_att@calendar    = "gregorian"
    time_att@units    = "days since 0001-01-01 00:00:00"
    
    lon_att        = 0
    lon_att@long_name = "longitude"
    lon_att@units     = "degrees_east"
    
    lat_att        = 0
    lat_att@long_name = "latitude"
    lat_att@units     = "degrees_north"
    
    date_att    = 0
    date_att@units = "yyyymmdd"
    
    datesec_att    = 0
    datesec_att@units = "current seconds of current date"
    
    date_frac_att    = 0
    date_frac_att@units = "yyyymmdd.fraction_of_day"
    
    SST_att        = 0
    SST_att@long_name = "Sea-Surface temperature"
    SST_att@units     = "deg_C"
    
    SEAICE_att        = 0
    SEAICE_att@long_name = "Sea Ice Concentration"
    SEAICE_att@units     = "%"
    SEAICE_att@long_name = "Sea Ice Fraction"
    SEAICE_att@units     = "Fraction"

    ice_cov_att        = 0
    ice_cov_att@units     = "%"
    ice_cov_att@long_name = "Sea Ice Fraction"
    
    filevarattdef(fout, "time", time_att)
    filevarattdef(fout, "lon", lon_att)
    filevarattdef(fout, "lat", lat_att)
    filevarattdef(fout, "date", date_att)
    filevarattdef(fout, "datesec", datesec_att)
    filevarattdef(fout, "date_frac", date_frac_att)
    filevarattdef(fout, "SST_cpl", SST_att)
    filevarattdef(fout, "SEAICE", SEAICE_att)
    filevarattdef(fout, "ice_cov", ice_cov_att)
    setfileoption(fout, "DefineMode", False)
  
    print((/"Writing Time Variable for years "+year_range/))
    do t=0,ntime-1
       monthind=mod(t,12)
       years=floattointeger((startyear+floor(t/12)))
       days=midmonth_days(monthind)
       hours=midmonth_hours(monthind)
       time_out(t) = cd_inv_calendar( years, monthind+1, days, hours, 00, 00,  "days since 0001-01-01 00:00", 0 )
       date_out(t)=cd_calendar(time_out(t),-2)
       date_frac_out(t) = date_frac(monthind)
       datesec_out(t) = datesec(monthind)
    end do
   
    print((/"Regrid SST..."/)) 
    ; get starting and endind indicies for startyear and endyear
    ; monthly averaged pop files are dated on the first time step of the following month
    ; ie jan averaged file will have a date time stamp of Feb 01

    utc_date = cd_calendar(focn->time,0)
    print(utc_date(:,0))
    print(utc_date(:,1))
    print(utc_date(:,2))
    ;print(cd_calendar(focn->time,0))
    startind=(ind(utc_date(:,0).eq.startyear.and.utc_date(:,1).eq.01.and.utc_date(:,2).eq.17))
    endind=(ind(utc_date(:,0).eq.endyear.and.utc_date(:,1).eq.12.and.utc_date(:,2).eq.17))

    print("startind="+startind)
    print("endind="+endind)
    print(utc_date(startind,:))
    print(utc_date(endind,:))
    print(focn->time(startind))
    print(focn->time(endind))

    delete(utc_date)
    SST = (/ESMF_regrid_with_weights(focn->SST(startind:endind,:,:),"map_gx1v6_to_1x1d_bilin_da_100716.nc", False)/)
    SEAICE_tmp = where(ismissing(focn->SST(startind:endind,:,:)), focn->SST(startind:endind,:,:), 0.)
    SEAICE_tmp(startind:endind,:,:) = fice->aice(startind:endind,:,:)
    print((/"Regrid Ice..."/))
    SEAICE = (/ESMF_regrid_with_weights(SEAICE_tmp,"map_gx1v6_to_1x1d_bilin_da_100716.nc", False)/)
   

    ; printMinMax(SST, True)
     

    print((/"Consistency processing..."/))
    ; Corrections for data consistency
    ; 1) If SST < -1.8 or ice frac >= 90%, SST = -1.8
    SST = where(SST.le.-1.8, -1.8, SST)
    SST = where(SEAICE.gt.90., -1.8, SST)

    ; 2) min ice frac is 0%, max ice_frac is 100%
    SEAICE = where(SEAICE.lt.0., 0., SEAICE)
    SEAICE = where(SEAICE.gt.100., 100., SEAICE)

    ; 3) Hurrell et al correction to SST (if 0.15 < ice frac < 0.9)
    SST_max = 9.328*(0.729-(SEAICE/100.)^3)-1.8
    SST = where((SEAICE.gt.15.).and.(SEAICE.lt.90.).and.(SST.gt.SST_max), SST_max, SST)

    ; 4) No sea ice if SST > 4.97
    SEAICE = where(SST.gt.4.97, 0., SEAICE)

    ; 5) Hurrell et al correction to ice frac (if -1.8 < SST < 4.97)
    ice_max = 100.*(0.729-(SST+1.8)/9.328)^(1./3.)
    SEAICE = where((SST.gt.-1.8).and.(SST.lt.4.97).and.(SEAICE.gt.ice_max), ice_max, SEAICE)
    
    print((/"Filling in missing values in SST and SEAICE..."/))
    poisson_grid_fill(SST, True, 1, 500, 0.01, 0.6, 0)
    poisson_grid_fill(SEAICE, True, 1, 500, 0.01, 0.6, 0)
    
    print((/"Writing File:"+ out_file/))
    fout->time = (/time_out/)
    fout->date = (/date_out/)
    fout->datesec = (/datesec_out/)
    fout->date_frac = (/date_frac_out/)
    fout->lon = (/new_lon/)
    fout->lat = (/new_lat/)
    fout->SST_cpl= (/SST/)
    fout->SEAICE = (/SEAICE/)
    fout->ice_cov = (/SEAICE/100./)

end
  



