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
; Set resources


; Backtrac time file
type_code=(/"I","II","III"/)

; Integration timestep
int_step=1 
; Total integration period in an individual case
total_int_hrs=96 
; Judge step
judg_step=6

;number of clusters
n_pts=3

latS=5
latN=25
lonW=70
lonE=110

;Plvl
;plvl_list=(/1000, 925, 850, 700, 600, 500, 200/)
plvl_list=(/700/)
;plvl_list=(/850,825,800,775,750,500/)

fig_dir="../fig/Clim700traj_clst_A2"

data_file_name1="/Users/zhenningli/data/CAL_SCSSM-2016/back_traj/Cluster/Cmean1_3_A2.tdump"
pt_record  =   readAsciiTable(data_file_name1,12,"float",7) ; get the first file's lat lon and value
;pt_record [0]--pt idx  [9]--lat [10]--lon 



wks      = gsn_open_wks("png",fig_dir)       ; send graphics to PNG file
res             = True
res@gsnDraw     = False                         ; don't draw
res@gsnFrame    = False                         ; don't advance frame
res@gsnMaximize = True

res@mpFillOn              = False
res@mpGeophysicalLineThicknessF = 2
res@mpDataBaseVersion       = "MediumRes"
;res@mpDataSetName           = "Earth..4"
;res@mpOutlineBoundarySets = "GeophysicalAndUSStates"
res@pmTickMarkDisplayMode = "Always"

res@mpLimitMode = "LatLon"        ; select subregion
res@mpMinLatF   = latS
res@mpMaxLatF   = latN              
res@mpMinLonF   = lonW
res@mpMaxLonF   = lonE

res@tmYROn      = False     ; turn off right and top tickmarks
res@tmXTOn      = False

res@tiMainString      = "Air Parcel Cluster +2 Day (700 hPa)"
res@tiMainFontHeightF = 0.015

map = gsn_csm_map_ce(wks,res)                  ; create map

; Add trajectory lines.
pres                  = True               ; polyline resources
pres@gsLineColor      = "black"

; Add markers to the trajectories.
mres                = True         ; marker resources for best track
mres@gsMarkerIndex  = 12           ; marker style (filled circle)
mres@gsMarkerSizeF  = 20.0          ; marker size
mres@gsMarkerColor  = "black"      ; maker color
mres@gsMarkerThicknessF=5.0
;********************************************
colors=(/"blue","darkgreen","red"/)
gsn_polymarker(wks,map,pt_record(0,10),pt_record(0,9),mres)


res_text                    = True                  ; text mods desired
res_text@txFontHeightF      = 0.015                 ; change text size
res_text@txJust             = "BottomLeft"          ; text justification

pt_record:=pt_record(0:218,:)
do ii = 0, n_pts-1
    pres@gsLineThicknessF = 20.0*clst_ratio(ii)/100                ; line thickness
    pres@gsLineColor      = colors(ii)

    gsn_polyline(wks,map,pt_record(ii::n_pts,10),pt_record(ii::n_pts,9),pres)      ; draw the traj
    dum2 = gsn_add_text(wks,map,"Type "+type_code(ii)+": "+clst_ratio(ii)+"%",pt_record(144+ii,10),pt_record(144+ii,9),res_text); add text
end do
draw(map)
frame(wks)
end
