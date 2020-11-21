;*******************************************************
; lcnative_2.ncl
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCL_SELFLIB/../shp/cnmap/cnmap.ncl"
begin
;************************************************
; open file and read in data
;************************************************

; Assign default settings if lack of argument pass
    if (.not. isvar("i_dom")) then 
        i_dom=1
    end if 
    if (.not. isvar("wrfout_path")) then 
        wrfout_path="/users/b145872/project-dir/app/COAWST-sandy-wrf/WRF/run/"
    end if 
    if (.not. isvar("casename")) then 
        casename="mangkhut-wrfonly" 
    end if 
    if (.not. isvar("fig_path")) then 
        wrfout_path="/users/b145872/project-dir/app/COAWST-sandy-wrf/WRF/run/"
    end if 
    if (.not. isvar("trck_path")) then 
        trck_path="/disk/v092.yhuangci/lzhenn/1911-COAWST/cma.trck.mangkhut"
    end if 
    if (.not. isvar("tstrt")) then 
        tstrt="2019091516"
    end if 
    if (.not. isvar("tend")) then 
        tend="2019091602"
    end if 



    fig_prefix="d0"+tostring(i_dom)+"_trck_"
    g_font=0.02
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)
    
    ; get in ibtrck data
    ncol=6
    tc_loc = readAsciiTable(trck_path,ncol,"float", 1) ; tc_loc(nrec, ncol) 
    dims=dimsizes(tc_loc) 
    dim_tc=dims(0)
 

   
   ; get wrf nc data
    wrfout_fn=wrfout_path+"/wrfout_d0"+tostring(i_dom)
    ctrl_in      = addfile (wrfout_fn, "r")   ; note the "s" of addfile
    
    ; parser time
    time0 = wrf_user_getvar(ctrl_in,"Times", -1)
    xtime = wrf_times_c( time0, 1 ) 
    ;xtime = xtime+8 
    lc_date=cd_calendar(xtime, 0)
    year   = tointeger(lc_date(:,0))    ; Convert to integer for
    month  = tointeger(lc_date(:,1))    ; use sprinti 
    day    = tointeger(lc_date(:,2))
    hour   = tointeger(lc_date(:,3))
    minute = tointeger(lc_date(:,4))
    second = lc_date(:,5)

    date_str = month_abbr(month)+sprinti(" %0.2i ", day) + sprinti("%0.2iZ", hour) +sprinti("%0.2i:00", minute)
    lentime=dimsizes(xtime)
  
    lc_date:=cd_calendar(xtime, -3)
    istrt   = ind(lc_date .eq. toint(tstrt))
    ilast   = ind(lc_date .eq. toint(tend))

    ; get in wrf tc track data
    ;0-timestamp 1-lat 2-lon 3-minSLP 4-maxWS 5-uRadius 6-vRadius
    case_tc = asciiread(wrfout_path+"/trck."+casename+".d0"+i_dom,(/lentime,7/),"float")
    ; parser lat lon
    lat2d = wrf_user_getvar(ctrl_in,"XLAT",  0)
    lon2d = wrf_user_getvar(ctrl_in,"XLONG", 0)
  

  res                   = True              ; plot mods desired
  
  res@gsnMaximize          = True
  res@gsnFrame = False
  res@gsnDraw = False

;---Necessary for contours to be overlaid correctly on WRF projection
  res@tfDoNDCOverlay       = True
  res@gsnRightString = ""
  res@gsnStringFontHeightF = g_font 
  res@gsnPaperOrientation = "portrait"

  res@tmYLMajorLengthF = 0.01
  res@tmXBMajorLengthF = 0.01
  res@tmXBLabelFontHeightF = g_font
  res@tmYLLabelFontHeightF = g_font
  res@mpGridAndLimbOn        = True             ; Turn on lat/lon grid
  res@mpGridLineDashPattern  = 2                ; Dashed lines
  res@mpGridSpacingF         = 5.0 
  res@mpGridLineThicknessF   = 2.0
  res@mpGridLineColor        = "Gray80"

  res@mpOutlineOn             = True  ; Use outlines from shapefile
  res@mpGeophysicalLineColor = "gray10"
  res@mpDataBaseVersion       = "MediumRes"
  res@mpDataSetName           = "Earth..4"
  res@mpAreaMaskingOn         = True
  res@mpMaskAreaSpecifiers    = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
  res@mpLandFillColor         = "white"
  res@mpInlandWaterFillColor  = "white"

;>============================================================<
;                      add China map
;>------------------------------------------------------------<
  cnres           = True
  cnres@china     = False       ;draw china map or not
  cnres@river     = False       ;draw changjiang&huanghe or not
  cnres@province  = True       ;draw province boundary or notcnres@nanhai    = False       ;draw nanhai or not 
  cnres@nanhai    = False       ;draw nanhai or not 
  cnres@diqu      = False       ; draw diqujie or not


 
    
  polyres                   = True
  polyres@gsMarkerIndex     = 14          ; polymarker style
  polyres@gsMarkerSizeF     = 12.          ; polymarker size
  polyres@gsMarkerThicknessF     = 3.          ; polymarker size
  polyres@gsMarkerColor     = "Black"          ; polymarker size

  ;---Resources for the polyline
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 3.0            ; line thickness   
  pres@gsLineColor      = "red"         ; color of lines
  
  tres  = True
  tres@txFontHeightF = 0.015
  tres@txJust="TopLeft"
  tlat=18.0
  tlon=110.0
 
  obv_polyres=polyres
  obv_polyres@gsMarkerIndex     = 16          ; polymarker style
  obv_polyres@gsMarkerSizeF     = 9.          ; polymarker size

  sim_histres=polyres
  sim_histres@gsMarkerSizeF     = 7.          ; polymarker size
  sim_histres@gsMarkerIndex     = 7          ; polymarker style
  sim_histres@gsMarkerThicknessF   = 6          ; polymarker style
  sim_histres@gsMarkerColor = pres@gsLineColor

res = wrf_map_resources(ctrl_in,res)

time_frame=istrt
wks_type="png"
wks_type@wkWidth=800
wks_type@wkHeight=800

do while(time_frame .lt. ilast)
    ;---Set map resources based on projection on WRF output file

    ;************************************************
    ; create plot
    ;************************************************
    
    wks = gsn_open_wks(wks_type,fig_path+"/"+fig_prefix+sprinti("%0.3iFrm", time_frame))      ; send graphics to PNG file
    
;    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;    res@cnLevels =    (/0.1, 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 14, 16, 20, 25, 30, 40, 50/)
   
    gsn_define_colormap(wks,"precip2_17lev")
    res@gsnLeftString=casename+" Track @"+date_str(time_frame)
    ;---Call plotting routine which draws contours over a map
    plot = gsn_csm_map(wks, res)
  
    chinamap = add_china_map(wks,plot,cnres)
    ; center
    
    no_tc_count=0 ; count no tc frames
    if (case_tc(time_frame,4) .gt. 0) then
        dum1    = gsn_add_polymarker(wks,plot,case_tc(time_frame,2),case_tc(time_frame,1),polyres)
        ;dum_text    = gsn_add_text(wks,plot,sprintf("Center SLP: %3.1f degC", case_tc(2, time_frame)),tlon,tlat,tres)
        if (time_frame .gt. 0) then
            dum_track=gsn_add_polyline(wks,plot, case_tc(no_tc_count:time_frame,2) , case_tc(no_tc_count:time_frame,1),pres)
            dum_track@$unique_string("xx")$    = gsn_add_polymarker(wks,plot,case_tc(no_tc_count:time_frame,2) , case_tc(no_tc_count:time_frame,1),sim_histres)
        end if
    else
        no_tc_count=no_tc_count+1
    end if
    
    ;Obv Track
    res_lines=True
    res_lines@gsLineColor       = "black"
    res_lines@gsLineDashPattern = 0.
    res_lines@gsLineThicknessF  = 3.                    ; line thicker
    
    yy := tc_loc(:,3)/10 
    xx := tc_loc(:,2)/10 
    obv_track=gsn_add_polyline(wks,plot,yy,xx,res_lines)              ; N

    do ii =0, dim_tc-1
        yy@$unique_string("xx")$    = gsn_add_polymarker(wks,plot,yy(ii),xx(ii),obv_polyres)
    end do
    
    ;overlay(plot, plotv)
    draw(plot)
    frame(wks)
    time_frame=time_frame+1
    ;delete(wks)
end do
end
