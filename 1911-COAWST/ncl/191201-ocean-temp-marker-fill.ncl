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
   finit    = "../data/1911-COAWST/joe_tc_ctrl/joe_tc_ocean_init_org.nc"
   outfile = "roms_4"
   variable= "temp"
   rec     = 0
                     
   minValue = 15.0   ; manually set contour levels and spacing
   maxValue = 25.0
   step     =  0.2
   stride   =  10
 
    ;Countor Level for Stations
    cn_bins=30
  
;***********************************************
; Read file date and use ROMS_utils.ncl
;***********************************************
   his   =  addfile (fhis,"r")
   init =  addfile(finit, "r")
   var = init->temp(0,:,:,:)
   dims=dimsizes(var)
   dim_x=dims(2)
   dim_z=dims(0)
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
 res@trYMinF=-100

 res@vpHeightF = 0.1
 res@vpWidthF = 0.8
 
 res@gsnYRefLine=-1000.0
 res@gsnYRefLineColor      = "transparent"
 res@gsnAboveYRefLineColor = (/"gray60"/)
 res@gsnLeftString="ROMS Vertical Grid Section"
 plot  = gsn_csm_xy (wks,lon2d(0,:),depth(0,0,:),res) ; create plot

gsres=True
gsres@gsMarkerIndex=16
gsres@gsMarkerSizeF      = 0.015
gsres@gsMarkerThicknessF = 0.7


color_table="BlGrYeOrReVi200"
gsn_define_colormap(wks,color_table) ; choose a colormap
cmap = read_colormap_file(color_table)    ; returns 254 x 4 array
rgba = span_color_rgba(cmap,cn_bins)

minvar=min(var)
maxvar=max(var)

do jj = 0, dim_x-1
    do kk = 0, dim_z-1
        n_color=floattoint(floor(((var(kk,0,jj)-minvar)/(maxvar-minvar))*cn_bins))
        if n_color .gt. cn_bins-1 then
            n_color=cn_bins-1
        end if
        gsres@gsMarkerColor      = rgba(n_color,:)
        plot@$unique_string("fuck ncl")$ = gsn_add_polymarker(wks,plot,lon2d(0,jj),depth(kk,0,jj),gsres)
    end do
end do
plot2  = gsn_csm_xy (wks,lon2d(0,:),depth(0,0,:),res) ; create plot
overlay(plot, plot2)
draw(plot)
frame(wks)

end
