;***********************************************
; roms_4.ncl
;
; Concepts illustrated:
;   - Plotting ROMS data
;   - Drawing curly vectors
;   - Loading NCL functions from another script
;***********************************************
; Example of using a donated library: ROMS_utils.ncl
;
; Specifically: roms depth slice using roms_3d_interp
;***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;
; This file still has to be loaded manually
load "./ROMS_utils.ncl"

begin
;***********************************************
; User settings
;***********************************************
   date    = 20121002
;  path    = "/mnt/drobilica2/OPERATIONAL/ROMS/archive/"
   path    = "./"    ; new input directory
   fhis    = "../data/1911-COAWST/joe_tc_ctrl/ocean_joe_tcs_his.nc"
   outfile = "roms_4"
   variable= "temp"
   rec     = 0
                     
   minValue = 15.0   ; manually set contour levels and spacing
   maxValue = 25.0
   step     =  0.2
   stride   =  10
   
;***********************************************
; Read file date and use ROMS_utils.ncl
;***********************************************
   his   =  addfile (fhis,"r")

   latlonin= addfile("../data/1911-COAWST/joe_tc_ctrl/wrfout_d01.nc","r")
   lon2d = latlonin->XLONG(0,:,:)
   lat2d = latlonin->XLAT(0,:,:)
   depth   = roms_get_depth(his)

   depth@lat2d = lat2d
   depth@lon2d = lon2d
;************************************************
; create plot
;************************************************
   wks_type = "png"        ; or "ps"
  ;wks_type@wkWidth = 800 
  ;wks_type@wkHeight= 800 
  ;wks_type@wkOrientation = "Portrait"
   wks  = gsn_open_wks (wks_type, "../fig/roms_depth")         ; open workstation

;---Set plotting parameters

 res                   = True                      ; plot mods desired
 res@gsnFrame          = False                      ; don't advance frame yet
 res@gsnDraw          = False                      ; don't advance frame yet
 res@xyLineThicknessF = (/  1.0/)          ; make second line thicker
 res@xyLineColor      = (/"gray30"/)          ; change line color
 res@xyDashPattern = 0
 res@tmYLMode          = "Explicit"                ; explicit labels
 res@tmYLValues        = (/-10, -50, -100, -200, -300, -400, -500,-600, -700, -800, -900, -1000/)
 res@tmYLLabels        = ""+res@tmYLValues         ; make strings
 res@trXMaxF = max(lon2d(0,:))
 res@trXMinF = min(lon2d(0,:))
 res@tmXBTickSpacingF =5
 res@tiYAxisString = "Depth (m)"
 plot  = gsn_csm_xy (wks,lon2d(0,:),depth(:,0,:),res) ; create plot
 
 res@gsnYRefLine=-1000.0
 res@gsnYRefLineColor      = "transparent"
 res@gsnAboveYRefLineColor = (/"gray60"/)
 res@gsnLeftString="ROMS Vertical Grid Section"
 plot2  = gsn_csm_xy (wks,lon2d(0,:),depth(0,0,:),res) ; create plot
 
 overlay(plot,plot2)

 draw(plot)
 frame(wks)
end
