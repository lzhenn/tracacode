;********************************************************
; annotate_4.ncl
;
; Concepts illustrated:
;   - Plotting trajectories
;   - Attaching a custom legend to a map
;   - Attaching markers, text, and polylines to a map
;   - Changing the width and height of a legend
;   - Drawing filled dots on a map
;
; This script was contributed by Yongzuo Li from
; the University of Oklahoma.
; 
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;**************************************************
begin


;Backtrac time file
n_pts=144
int_step=1  ;hr
total_int_hrs=96
rec_len=total_int_hrs/int_step
data_file_name1="/Users/zhenningli/data/CAL_SCSSM-2016/back_traj/clim/Day5.0_96hr_925hPa.txt"
fig_dir="../fig/"

pt_record  =   asciiread(data_file_name1,(/n_pts*rec_len,5/),"float") ; get the first file's lat lon and value

;pt_record [0]--pt idx [1]--timestamp [2]--lat [3]--lon [4]--plevel

;********************************************
   wks      = gsn_open_wks("png",fig_dir+"annotate")       ; send graphics to PNG file

   res             = True
   res@gsnDraw     = False                         ; don't draw
   res@gsnFrame    = False                         ; don't advance frame
   res@gsnMaximize = True

   res@mpFillOn              = False
   res@mpPerimOn             = True
   res@mpOutlineBoundarySets = "GeophysicalAndUSStates"
   res@pmTickMarkDisplayMode = "Always"

   res@mpLimitMode = "LatLon"        ; select subregion
   res@mpMinLatF   = -10
   res@mpMaxLatF   = 30                
   res@mpMinLonF   = 50 
   res@mpMaxLonF   = 110

   res@tmYROn      = False     ; turn off right and top tickmarks
   res@tmXTOn      = False

   res@tiMainString      = "Air Partical Track"  ; title
   res@tiMainFontHeightF = 0.02

   map = gsn_csm_map_ce(wks,res)                  ; create map

; Add trajectory lines.
   pres                  = True               ; polyline resources
   pres@gsLineThicknessF = 1.0                ; line thickness
   pres@gsLineColor      = "black"

; Add markers to the trajectories.
   mres                = True         ; marker resources for best track
   mres@gsMarkerIndex  = 16           ; marker style (filled circle)
   mres@gsMarkerSizeF  = 4.0          ; marker size
   mres@gsMarkerColor  = "blue"      ; maker color
   do ii = 0, n_pts-1
        gsn_polyline(wks,map,pt_record(ii::n_pts,3),pt_record(ii::n_pts,2),pres)      ; draw the traj
        gsn_polymarker(wks,map,pt_record(ii,3),pt_record(ii,2),mres)
   end do
   draw(map)                                           
   frame(wks)                                         
  
end
