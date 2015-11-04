;*************************************************************
;Aim: draw Night-light data 
;     
;
;Mission:
;   1. Read data from EA night light dataset
;                       Zhenning Li
;                       2015-10-23
;Last Edited:
;   2015-10-23    Create
;*************************************************************



load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

    fig_name    =   "../../test_night_light"
    setfileoption("bin","ReadByteOrder","Native")       ; a033 default

    nx = 4200 
    ny = 4800

    lonL        =   100
    lonR        =   140
    latS        =   10
    latN        =   45


    lonL        =   108
    lonR        =   118
    latS        =   20
    latN        =   28

    var1_org = fbindirread("../../data/obv/F182013_EA.dat",0, (/ny,nx/), "integer")
    var1 = transpose(var1_org)
    var1!0      =   "lat"
    var1!1      =   "lon"
    var1&lat    =   fspan(10.,45.,nx)
    var1&lon    =   fspan(100.,140.,ny)
    var1&lat@units  =   "degrees_north"
    var1&lon@units  =   "degrees_east"

; ==============================================================
; Mission 2. Set the figure parameters
; ==============================================================
;-----------------------------------------------------------------------------
    wks = gsn_open_wks("eps",fig_name)  ; open a ps file
    ;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
    ;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

    plot_C = new((/1/),graphic)     ;contour

    gsn_define_colormap(wks,"GMT_hot")


    res                      = True     ; plot mods desired
    res@gsnDraw              = False    ; don't draw
    res@gsnFrame             = False    ; don't advance frame
    res@gsnSpreadColors      = True

    res@cnFillOn             = True     ; turn on color fill
    res@cnLinesOn            = False    ; turn of contour lines
    res@cnFillMode           = "CellFill" ; Raster Mode
    res@cnLinesOn            =  False       ; Turn off contour lines
    res@cnLineLabelsOn       =  False       ; Turn off contour lines
    res@lbLabelBarOn         = False        ; turn off individual cb's

    res@mpCenterLonF         = 0.           ; 210.
    res@mpFillOn             = False
    res@mpMaxLonF  = lonR
    res@mpMinLonF  = lonL

    res@mpMaxLatF  = latN
    res@mpMinLatF  = latS

    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        =  0          ; set min contour level
    res@cnMaxLevelValF        =  64          ; set max contour level
    res@cnLevelSpacingF       =  1          ; set contour interval

    printVarSummary(var1)
    plot_C(0)   =    gsn_csm_contour_map(wks,var1,res) ; create a default plot
    draw(plot_C)
    frame(wks)


end
