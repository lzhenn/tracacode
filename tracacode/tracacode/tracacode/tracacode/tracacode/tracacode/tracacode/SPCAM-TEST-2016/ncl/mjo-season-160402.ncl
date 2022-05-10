;******************************************************
; mjoclivar_8.ncl
;
; Concepts illustrated:
;   - Rearranging longitude data to span -180 to 180
;
; List not finished.
;
;
;                           Modified by L_Zealot
;                                     2016-04-03
;
;******************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"    

;******************** MAIN **********************************
begin
    casename = "SP_AMIP"
    yr0    = "2000"
    yr1    = "2001"
    twStrt = 20000701        ; include enough temporal buffer for filter
    twLast = 20010930        ; at least 100 days on each side of season

    cwStrt = 20001101        ; correlation window for specified season 
    cwLast = 20010531       

    pName  = (/"PRECC","PRECL"/)        ; name of variable on precipitation file
    dirp   = "../data/model/pro/"+casename+"/"
    filp1   = (/casename+".cam.h1.YEAR."+yr0+".daily.PRECC.nc",casename+".cam.h1.YEAR."+yr1+".daily.PRECC.nc"/)
    filp2   = (/casename+".cam.h1.YEAR."+yr0+".daily.PRECL.nc",casename+".cam.h1.YEAR."+yr1+".daily.PRECL.nc"/)

    uName  = "U"        ; name of variable on U-anomaly file
    diru   = "../data/model/pro/"+casename+"/"
    filu   = (/casename+".cam.h1.YEAR."+yr0+".daily.U.nc",casename+".cam.h1.YEAR."+yr1+".daily.U.nc"/)

    nameRegion = "IO"        ; Indian Ocean base region
    latS_IO    = -10.
    latN_IO    =   5. 
    lonL_IO    =  75.
    lonR_IO    = 100. 

    latS_IO    = -10 
    latN_IO    =  10
    lonL_IO    = 0 
    lonR_IO    = 360 


    latS_globe = -30.        ; global subset
    latN_globe =  30. 

    latn       =  10.        ; lat band for (lag,lon) Fig 5
    lats       = -10.

    lonl       =  80.        ; lon band for (lag,lat) Fig 6
    lonr       = 100.

    pltName    = "mjo-"+casename       ; output plot name         
    pltType    = "eps"        ; x11, ps, eps, pdf, png 
    pltDir     = "../fig"        ; output plot directory

    ;************************************************
    ; create Lanczos BandPass Filter
    ;************************************************
    ihp   = 2                             ; bpf=>band pass filter
    nWgt  = 201
    sigma = 1.0                           ; Lanczos sigma
    fca   = 1./100.                       ; MJO clivar
    fcb   = 1./20.
    wgt   = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )

    ;************************************************************
    ; PRECIPITATION:
    ;     time indices corresponding to the desired time window
    ;     Read user specified period
    ;************************************************************
    setfileoption("nc","SuppressClose",False) ; close too many files
    f      = addfiles(dirp+filp1, "r")  
    f2      = addfiles(dirp+filp2, "r")  
    ListSetType(f,"cat")
    date_p = cd_calendar(f[0]->time, -2)   ; entire file
    iStrt  = ind(date_p.eq.twStrt)      ; desired dates
    date_p = cd_calendar(f[1]->time, -2)   ; entire file
    iLast  = ind(date_p.eq.twLast)+365
    delete(date_p)
    ; P(time,lat,lon)
    if (getfilevartypes(f[0],pName(0)) .eq. "short") then
        P  = short2flt( f[:]->$pName(0)$(iStrt:iLast,{latS_globe:latN_globe},:)) 
    else
        P  = f[:]->$pName(0)$(iStrt:iLast,{latS_globe:latN_globe},:) 
        P2  = f2[:]->$pName(1)$(iStrt:iLast,{latS_globe:latN_globe},:) 
        P =P+P2
    end if

    if (P&lon(0) .lt. 0) then  ; test if -180 to +180
        P = lonFlip( P )       ; make 0 to 360 to match U        
    end if

    ;printVarSummary( P )
    ;printMinMax(P, True)

    time_p = P&time                     ; clarity
    date_p = cd_calendar(time_p, -2 )   ; yyyymmdd

    wyIO   = f[:]->lat({latS_IO:latN_IO})  
    wyIO   = cos(0.017459*wyIO)         ; spatial wgt

    ;************************************************************
    ; U ANOMALIES:
    ;     time indices corresponding to the desired time window
    ;     Read user specified period
    ;************************************************************

    f      = addfiles(diru+filu, "r")  
    ListSetType(f,"cat")
    date_u = cd_calendar(f[0]->time, -2)     ; entire file
    iStrt  = ind(date_u.eq.twStrt)        ; desired dates
    date_u = cd_calendar(f[1]->time, -2)     ; entire file
    iLast  = ind(date_u.eq.twLast)+365
    delete(date_u)
    ; U(time,lat,lon)
    if (getfilevartypes(f[0],uName) .eq. "short") then
        U  = short2flt( f[:]->$uName$(iStrt:iLast,{latS_globe:latN_globe},:)) 
    else
        U  = f[:]->$uName$(iStrt:iLast,{850},{latS_globe:latN_globe},:) 
    end if

    ;printVarSummary( U )
    ;printMinMax(U, True)

    time_u = U&time                     ; clarity
    date_u = cd_calendar(time_u , -2 )  ; yyyymmdd

    wyU    = f[:]->lat({latS_IO:latN_IO})
    wyU    = cos(0.017459*wyU)          ; MJO Clivar says cos(lat) wgting

    ;************************************************
    ; make sure dates agree
    ;************************************************

    if (.not.all(date_p.eq.date_u)) then
        print("date mismatch: exit")
        exit
    end if

    ;************************************************
    ; Create wgted area average of the base IO precip series  (time)
    ; Really, no need to area weight here .... area is very small.
    ;************************************************

    PIO    = wgt_areaave_Wrap(P(:,{latS_IO:latN_IO},{lonL_IO:lonR_IO}), wyIO, 1., 0) ; (time)

    PIOF   = wgt_runave_Wrap( PIO, wgt, 0 )                        ; apply filter
    ;************************************************
    ; Create LAT average of the global Precip and U series  (time,lon)
    ; Really, no need to area weight here
    ;************************************************

    P_timeLon   = dim_avg_Wrap(P( time|:,lon|:,{lat|lats:latn}) )  ; (time,lon)
    U_timeLon   = dim_avg_Wrap(U( time|:,lon|:,{lat|lats:latn}) )  ; (time,lon)

    P_timeLonF  = wgt_runave_leftdim( P_timeLon, wgt, 0 )          ; apply filter
    U_timeLonF  = wgt_runave_leftdim( U_timeLon, wgt, 0 )

    ;************************************************
    ; Create LON average of the global Precip and U series  (time,lat)
    ; Really, no need to area weight here
    ;************************************************

    P_timeLat   = dim_avg_Wrap(P( time|:,lat|:,{lon|lonl:lonr}) )  ; (time,lat)
    U_timeLat   = dim_avg_Wrap(U( time|:,lat|:,{lon|lonl:lonr}) )  ; (time,lat)

    P_timeLatF  = wgt_runave_leftdim( P_timeLat, wgt, 0 )         ; apply filter
    U_timeLatF  = wgt_runave_leftdim( U_timeLat, wgt, 0 )

    ;*****************************************************
    ; Calculate the cross-correlations at +/- 'mxlag' lags
    ;*****************************************************
    optXcor   = False
    mxlag     = 25

    iStrt  = ind(date_u.eq.cwStrt)        ; desired correlation dates
    iLast  = ind(date_u.eq.cwLast)     
    ; -----                                 ; unfiltered
    ccr_p_LagLon  = mjo_xcor_lag_season(PIO(iStrt:iLast), P_timeLon(iStrt:iLast,:) \
    ,mxlag, optXcor)

    ccr_u_LagLon  = mjo_xcor_lag_season(PIO(iStrt:iLast), U_timeLon(iStrt:iLast,:) \
    ,mxlag, optXcor)

    ccr_p_LagLat  = mjo_xcor_lag_season(PIO(iStrt:iLast), P_timeLat(iStrt:iLast,:) \
    ,mxlag, optXcor)

    ccr_u_LagLat  = mjo_xcor_lag_season(PIO(iStrt:iLast), U_timeLat(iStrt:iLast,:) \
    ,mxlag, optXcor)
    ; -----                                 ; Filtered
    ccr_p_LagLonF = mjo_xcor_lag_season(PIOF(iStrt:iLast), P_timeLonF(iStrt:iLast,:)\
    ,mxlag, optXcor)

    ccr_u_LagLonF = mjo_xcor_lag_season(PIOF(iStrt:iLast), U_timeLonF(iStrt:iLast,:)\
    ,mxlag, optXcor)

    ccr_p_LagLatF = mjo_xcor_lag_season(PIOF(iStrt:iLast), P_timeLatF(iStrt:iLast,:)\
    ,mxlag, optXcor)

    ccr_u_LagLatF = mjo_xcor_lag_season(PIOF(iStrt:iLast), U_timeLatF(iStrt:iLast,:)\
    ,mxlag, optXcor)

    ;************************************************
    ; plot 
    ;************************************************

    optPlot                  = True
    optPlot@gsnLeftString    = "precip (color)"    
    optPlot@gsnCenterString  =  cwStrt+"-"+cwLast 
    optPlot@gsnRightString   = "U (lines)"  
    optPlot@smth9            = 0.25                ; local spatial smoothing

    ;************************************************
    ; plot unfiltered
    ;************************************************
    optPlot@tiMainString     = "Figure 5: Model:  one season; unfiltered"
    pltNameLagLon = pltName+".LagLon_unfiltered"          
    mjo_xcor_lag_plot_ovly(ccr_p_LagLon, ccr_u_LagLon, pltType, pltDir, pltNameLagLon, optPlot)

    optPlot@tiMainString     = "Figure 6: Model: one season; unfiltered"
    pltNameLagLat = pltName+".LagLat_unfiltered"          
    mjo_xcor_lag_plot_ovly(ccr_p_LagLat, ccr_u_LagLat, pltType, pltDir, pltNameLagLat, optPlot)

    ;************************************************
    ; plot filtered
    ;************************************************

    optPlot@tiMainString     = "Figure 5: Model: one season; filtered"
    pltNameLagLon = pltName+".LagLon_filtered"          
    mjo_xcor_lag_plot_ovly(ccr_p_LagLonF, ccr_u_LagLonF, pltType, pltDir, pltNameLagLon, optPlot)

    optPlot@tiMainString     = "Figure 6: Model: one season; filtered"
    pltNameLagLat = pltName+".LagLat_filtered"          
    mjo_xcor_lag_plot_ovly(ccr_p_LagLatF, ccr_u_LagLatF, pltType, pltDir, pltNameLagLat, optPlot)
end
