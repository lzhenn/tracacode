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
   casename="sen"
   fhis    = "../data/1911-COAWST/joe_tc_"+casename+"/ocean_joe_tcs_his.nc"
   finit    = "../data/1911-COAWST/joe_tc_"+casename+"/joe_tc_ocean_init.nc"
                     

;***********************************************
; Read file date and use ROMS_utils.ncl
;***********************************************


   init =  addfile(finit, "r")
   var = init->temp(0,:,:,:)
   dims=dimsizes(var)
   dim_x=dims(2)
   dim_z=dims(0)


   his   =  addfile (fhis,"r")

   latlonin= addfile("../data/1911-COAWST/joe_tc_ctrl/wrfout_d01.nc","r")
   lon2d = latlonin->XLONG(0,:,:)
   lat2d = latlonin->XLAT(0,:,:)
   depth   = roms_get_depth(his)

   depth@lat2d = lat2d
   depth@lon2d = lon2d


; interp var(z,x) cross_section
    nbins=100
    dh=min(depth)/nbins
    print(dh)
    var_int=new((/nbins,dim_x/),typeof(var))
    var_int@_FillValue=-999
    var_int=-999
    var_int!0="depth"
    depth_array=fspan(min(depth),0,nbins)
    var_int&depth=depth_array(::-1)
    var_int!1="lon"
    var_int&lon=lon2d(0,:)
    do zz=0, nbins-1
        do ii=0,dim_x-1
            x=depth(:,0,ii)
            y=var(:,0,ii)
            if zz*dh .gt. min(x) then
                var_int(zz,ii)=tofloat(ftcurv(x,y,zz*dh))
            end if
        end do
   end do
;************************************************
; create plot
;************************************************
   wks_type = "png"        ; or "ps"
  ;wks_type@wkWidth = 800 
  ;wks_type@wkHeight= 800 
  ;wks_type@wkOrientation = "Portrait"
   wks  = gsn_open_wks (wks_type, "../fig/roms_depth_temp")         ; open workstation
    gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
;---Set plotting parameters

 res                   = True                      ; plot mods desired
 res@gsnFrame          = False                      ; don't advance frame yet
 res@gsnDraw          = False                      ; don't advance frame yet
 res@xyLineThicknessF = (/  1.0/)          ; make second line thicker
 res@xyLineColor      = (/"gray30"/)          ; change line color
 res@xyDashPattern = 0
; plot  = gsn_csm_xy (wks,lon2d(0,:),depth(:,0,:),res) ; create plot
 
 res@gsnYRefLine=-1000.0
 res@gsnYRefLineColor      = "transparent"
 res@gsnAboveYRefLineColor = (/"gray60"/)
 res@gsnLeftString="ROMS Init Temp Profile"
 plot_xy  = gsn_csm_xy (wks,lon2d(0,:),depth(0,0,:),res) ; create plot
 
 res_fill=True
 res_fill@cnFillOn=True
 res_fill@cnLinesOn=False
 res_fill@cnLineLabelsOn=False
 res_fill@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res_fill@cnMinLevelValF        = 18         ; set min contour level
 res_fill@cnMaxLevelValF        = 32          ; set max contour level
 res_fill@cnLevelSpacingF       = 0.5          ; set contour interval
 res_fill@gsnSpreadColors      = True
 res_fill@lbLabelBarOn = True 
 res_fill@lbOrientation="Vertical"

 res_fill@tmYLMode          = "Explicit"                ; explicit labels
 res_fill@tmYLValues        = (/-10, -50, -100, -200, -300, -400, -500,-600, -700, -800, -900, -1000/)
 res_fill@tmYLLabels        = ""+res_fill@tmYLValues         ; make strings
 res_fill@trXMaxF = max(lon2d(0,:))
 res_fill@trXMinF = min(lon2d(0,:))
 res_fill@tmXBTickSpacingF =5
 res_fill@tiYAxisString = "Depth (m)"

 plot_sh = gsn_csm_contour(wks,var_int,res_fill)
 overlay(plot_sh,plot_xy)

 draw(plot_sh)
 frame(wks)
end
