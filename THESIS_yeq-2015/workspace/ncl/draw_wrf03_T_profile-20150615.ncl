;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl" ; WRF_Times2Udunits_c   


begin

   lat0=23.406
   lon0=112.183
;------------------------------------------------------
;open file
;------------------------------------------------------
   f= addfile ("../data/wrf3", "r")
   lat       = f->XLAT(0,:,:)
   lon       = f->XLONG(0,:,:)
   pos0      =getind_latlon2d(lat,lon,lat0,lon0)
   pos      = pos0(0,:)
   print(lat(pos(0),pos(1))+" "+lon(pos(0),pos(1)))
   p_purt = f->P(40:88,:,pos(0),pos(1))
   p_b = f->PB(40:88,:,pos(0),pos(1))
   p_purt= p_b+p_purt
   tempjm = f->T(40:88,:,pos(0),pos(1))
   temp_base = f->T00(40:88)
   temp_base_cfm = conform_dims(dimsizes(tempjm),temp_base,0)
   tempjm = tempjm+temp_base_cfm
   tempjm = wrf_tk(p_purt,tempjm)
   Time   = WRF_Times2Udunits_c(f->Times, 0)  ; convert to "hours since"
   printVarSummary(tempjm)
  
  ;********************************************************
   ; assign the staggard eta values as a vertical "coordinate array" for T 
   ;********************************************************
   znu     = f->ZNU(0,:)                 ; znw(bottom_top_stag)
   tempjm&bottom_top = znu               

   plot = new ( 1, "graphic" )
   wks = gsn_open_wks("eps","../fig/vertical_temp")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200"); select color map
   ;gsn_draw_colormap(wks)  

   res                       = True            ; plot mods desired
   ;res@gsnMaximize           = True            ; uncomment to maximize size
   res@gsnSpreadColors       = True            ; use entire color map
   res@cnFillOn              = True            ; turn on color
   res@cnLinesOn             = False           ; turn off contour lines
   res@lbLabelAutoStride     = True            ; let NCL determine label spacing
   res@lbOrientation         = "vertical"      ; vertical label bar
   res@trYReverse            = True            ; reverse y axis
   res@gsnLeftString       = "Temperature Profile"
   res@gsnRightString      = "degC"
   res@tiXAxisString         = "Hours since 2014-10-26 00:00 (UTC+8)"
   ;res@tmXBValues=ispan(0,48,12)
   res@tmXBLabels=ispan(0,48,12)
   ;res@gsnSpreadColorStart   = 2               ; use the "amwg" portion
   ;res@gsnSpreadColorEnd     = 17              ; of the merged colormap

   temp_profile=tempjm(bottom_top|:,Time|:)
   temp_profile= temp_profile-273.15
   plot                      = gsn_csm_contour(wks,temp_profile(0:15,:),res)
end
