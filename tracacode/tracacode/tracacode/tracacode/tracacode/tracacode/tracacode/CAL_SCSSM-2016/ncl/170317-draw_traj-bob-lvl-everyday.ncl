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
n_pts=450

g_strt_year=1979

; Integration timestep
int_step=1 

; Total integration period in an individual case
total_int_hrs=96 

; Individual record length 
rec_len=total_int_hrs/int_step


;Plvl
plvl_list=(/1000, 925, 850, 700, 600, 500, 200/)
onset_day=(/125,136,133,134,143,108,136,123,119,119,128,105,110,132,134,114,126,112,133,132,93,100,115,114,127,118,123,107,116,112,99,134,113,119/)
left_shift_day=-10
right_shift_day=6


latS=-10
latN=30
lonW=70
lonE=120
fig_dir="../fig/obv/traj/every-year/"


res             = True
res@gsnDraw     = False                         ; don't draw
res@gsnFrame    = False                         ; don't advance frame
res@gsnMaximize = True
res@gsnStringFontHeightF=0.035
res@mpFillOn              = False
res@mpPerimOn             = True
res@pmTickMarkDisplayMode = "Always"

res@mpLimitMode = "LatLon"        ; select subregion
res@mpMinLatF   = latS
res@mpMaxLatF   = latN              
res@mpMinLonF   = lonW
res@mpMaxLonF   = lonE
res@tiMainFontHeightF = 0.015 

res@tmYROn      = False     ; turn off right and top tickmarks
res@tmXTOn      = False
; Add trajectory lines.
pres                  = True               ; polyline resources
pres@gsLineThicknessF = 1.0                ; line thickness

; Add markers to the trajectories.
mres                = True         ; marker resources for best track
mres@gsMarkerIndex  = 16           ; marker style (filled circle)
mres@gsMarkerSizeF  = 4.0          ; marker size
mres@gsMarkerColor  = "darkgreen"      ; maker color


do curr_year= g_strt_year, g_strt_year+dimsizes(onset_day)-1
    do jj=0,dimsizes(plvl_list)-1
        plvl=plvl_list(jj)
        do i_day=left_shift_day, right_shift_day
           curr_day_stamp=yyyyddd_to_yyyymmdd(curr_year*1000+onset_day(curr_year-g_strt_year)+i_day)
           print("processing "+curr_day_stamp+"@"+plvl+"hPa")
           data_file_name1="/Users/zhenningli/data/CAL_SCSSM-2016/back_traj/every-year/"+curr_day_stamp+"00-"+plvl+"hPa.txt"
           pt_record  =   asciiread(data_file_name1,(/n_pts*rec_len,5/),"float") ; get the first file's lat lon and value
           ;pt_record [0]--pt idx [1]--timestamp [2]--lat [3]--lon [4]--plevel
           wks      = gsn_open_wks("png",fig_dir+curr_day_stamp+"00_"+i_day+"Day_"+plvl+"hPa.txt")       ; send graphics to PNG file
           
           res@tiMainString      = curr_day_stamp+" Air Parcel Track ( Day "+(i_day)+" 00Z , "+plvl+"hPa)"  ; title
           map = gsn_csm_map_ce(wks,res)                  ; create map

           do ii = 0, n_pts-1
                if avg(pt_record(ii::n_pts,4)) .lt. plvl-20 then
                    pres@gsLineColor      = "red"
                else if avg(pt_record(ii::n_pts,4)) .gt. plvl+20 then
                    pres@gsLineColor      = "blue"
                else
                    pres@gsLineColor      = "black"
                end if
                end if
                gsn_polyline(wks,map,pt_record(ii::n_pts,3),pt_record(ii::n_pts,2),pres)      ; draw the traj
                gsn_polymarker(wks,map,pt_record(ii,3),pt_record(ii,2),mres)
           end do
           draw(map)                                           
           frame(wks)                                  
           delete([/map, wks/])
        end do
    end do
end do
end
