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
    thStrt  = 20101        ; Hov start time
    thLast  = 41231        ; Hov last  time
    spd     = 1               ; sample per day
    bpf     = (/20,100,201/)

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


    wgty    = latRegWgt(precip&lat, "double", 0)

    optHov  = False
    hov     = band_pass_hovmueller (precip, spd, bpf, wgty, optHov) 
    printVarSummary(hov)               ; (time,lon)
    printMinMax(hov, True)
 
    wks = gsn_open_wks ("eps", "../fig/mjo-hov-filtered" )            ; open ps file
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
    res@gsnLeftString = ""
    res@gsnRightString = ""
    res@gsnCenterString = "Model: Day 180-1625 Pr (filtered)"
    plot = gsn_csm_hov(wks, hov(180:1625,:), res) 


end
