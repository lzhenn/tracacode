; ===========================================
;   Draw longitude-time (Hovmueller) plot of
;precip related to MJO.
;
;
;                       Modified by L_Zealot
;                                2016-04-04
;
; ===========================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"    
; ===========================================
begin
    ; time window : include enough buffer
    latS    =  -10.            ; arbitrary
    latN    =   10.
    lonL    =  0.
    lonR    = 360.


    pName  = "PRECT"        ; name of variable on precipitation file
    dirp   = "../data/model/pro/"
    all_files = systemfunc("ls "+dirp+"*PRECT*") 
    setfileoption("nc","SuppressClose",False) ; close too many files
    f      = addfiles(all_files, "r")  
    ListSetType(f,"cat")

    precip   = f[:]->PRECT(:,{latS:latN},{lonL:lonR})    ; get chi
    precip   = precip*86400*1000
    
    time    = f[:]->time                          ; time:units = "hours since 1-1-1 00:00:0.0"                               
    TIME    = cd_calendar(time, 0)          ; type float 
    year    = toint( TIME(:,0) )
    month   = toint( TIME(:,1) )
    day     = toint( TIME(:,2) ) 
    ddd     = day_of_year(year, month, day) 
    yyyyddd = year*1000 + ddd                                  ; needed for input

    hClmDay    = clmDayTLL(precip, yyyyddd)     ; daily climatology at each grid point                                      
    ;***********************************************************
    ; Compute smoothed daily climatology using 2 harmonics  
    ;***********************************************************
    hClmDay_sm = smthClmDayTLL(hClmDay, 2)  
    ;remove annual cycle
    precip_rm_ann = precip
    do ii=0,4
        precip_rm_ann(ii*365:(ii+1)*365-1,:,:) = precip(ii*365:(ii+1)*365-1,:,:)-hClmDay_sm(0:364,:,:)
    end do
    
    precip_band = dim_avg_n_Wrap(precip_rm_ann,1)
    
    wks = gsn_open_wks ("eps", "../fig/mjo-hov-unfiltered" )            ; open ps file
    gsn_define_colormap(wks,"BlWhRe")             ; choose colormap

    res                      = True               ; plot mods desired
    res@cnFillOn             = True               ; turn on color fill

    ;---This resource not needed in V6.1.0
    res@gsnSpreadColors      = True               ; use full range of colors

    res@cnLevelSelectionMode = "ManualLevels"     ; manual contour levels
    res@cnMinLevelValF       = -10.         ; min level
    res@cnMaxLevelValF       =  10.               ; max level
    res@cnLevelSpacingF      = 2.                 ; contour level spacing
    res@cnFillMode           = "CellFill"
    res@cnLinesOn = False
    res@cnLineLabelsOn = False
    ;res@vpHeightF = 0.8
    ;res@vpWidthF = 0.4
    res@gsnLeftString = ""
    res@gsnRightString = ""
    res@gsnCenterString = "Model: Day 180-1625 Pr (unfiltered)"
    plot = gsn_csm_hov(wks, precip_band(180:1625,:), res) 

end
