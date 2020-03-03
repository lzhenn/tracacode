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
    casename="mangkhut" 
    wrfout_path="../data/1911-COAWST/"+casename+"/wrfout_d02"
    g_font=0.02
    
    imerg_path="/disk/hq247/yhuangci/lzhenn/data/1911-COAWST/obv/3B-DAY.MS.MRG.3IMERG.20180916-S000000-E235959.V06.nc4"
    imerg_in=addfile(imerg_path,"r")
    obv_pr=imerg_in->precipitationCal(0,:,:)

    printVarSummary(obv_pr)
    
    ; get in ibtrck data
    tck_file="../data/1911-COAWST/"+casename+"/trck.cma.simple"
    tc_loc  =   asciiread(tck_file,(/22,2/),"float") ; (n,0)--lat (n,1)--lon
    dims=dimsizes(tc_loc) 
    dim_tc=dims(0)
 

    
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)
   
    ctrl_in      = addfile (wrfout_path, "r")   ; note the "s" of addfile
    
    ; get slp
     ctrl_var1  = wrf_user_getvar(ctrl_in,"RAINNC", -1)  
 
   
    ;ctrl_var2  = wrf_user_getvar(ctrl_in,"U10", -1)  
	;ctrl_var3  = wrf_user_getvar(ctrl_in,"V10", -1)  
    

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

    ctrl_var1(1:lentime-1,:,:)=ctrl_var1(1:lentime-1,:,:)-ctrl_var1(0:lentime-2,:,:)
    
    ctrl_var1_acc=ctrl_var1(0,:,:)
    ctrl_var1_acc=dim_sum_n_Wrap(ctrl_var1(72:120,:,:),0)

    tc_track_path="../data/1911-COAWST/"+casename+"/trck.cpl"
    rec_tc = asciiread(tc_track_path,(/lentime,3/),"float"); (0)--lat, (1)--lon, (2)--slp

    ; parser lat lon
    lat2d = wrf_user_getvar(ctrl_in,"XLAT",  1)
    lon2d = wrf_user_getvar(ctrl_in,"XLONG", 1)
    latmax=max(lat2d)
    latmin=min(lat2d)
    lonmin=min(lon2d)
    lonmax=max(lon2d)
    ; lets find the TC center!

 
    

res                   = True              ; plot mods desired
;---Resources for filled contour plot
  
  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
  res@cnLevels =    (/0.1, 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 14, 16, 20, 25, 30, 40, 50/)
   
  res@gsnMaximize          = True
  res@gsnFrame = False
  res@gsnDraw = False
  res@cnFillOn             = True  
  res@cnLinesOn            = False
  res@cnLevelSpacingF      = 2.           ; NCL chose 4.0
  res@lbOrientation        = "Vertical"

;---Necessary for contours to be overlaid correctly on WRF projection
  res@tfDoNDCOverlay       = True
  res@gsnAddCyclic         = False
  res@cnFillMode           = "CellFill" ; Raster Mode
  res@gsnSpreadColors      = True               ; use full color map
  res@gsnRightString = "mm/hr"
  res@gsnStringFontHeightF = g_font 
  res@gsnMaximize      = True       ; fill up the page
  res@gsnPaperOrientation = "portrait"

  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = 0.02              ; make labels smaller
  res@tmYLMajorLengthF = 0.01
  res@tmXBMajorLengthF = 0.01
  res@lbLabelStride = 2  
  res@tmXBLabelFontHeightF = g_font
  res@tmYLLabelFontHeightF = g_font
  res@mpGridAndLimbOn        = True             ; Turn on lat/lon grid
  res@mpGridLineDashPattern  = 2                ; Dashed lines
  res@mpGridSpacingF         = 5.0 
  res@mpGridLineThicknessF   = 2.0
  res@mpGridLineColor        = "Gray80"


  res@mpOutlineOn             = True  ; Use outlines from shapefile
    res@mpGeophysicalLineColor = "gray10"
    res@cnFillDrawOrder         = "PreDraw"
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
  
  pres_wrf=pres
  pres_wrf@gsLineColor="blue"



  tres  = True
  tres@txFontHeightF = 0.015
  tres@txJust="TopLeft"
  tlat=13.0
  tlon=-33.0
 
  obv_polyres=polyres
  obv_polyres@gsMarkerIndex     = 16          ; polymarker style
  obv_polyres@gsMarkerSizeF     = 9.          ; polymarker size

res = wrf_map_resources(ctrl_in,res)

time_frame = 0
do while(time_frame .lt. lentime)
    ;---Set map resources based on projection on WRF output file

    ;************************************************
    ; create plot
    ;************************************************
    
    wks_type="png"
    wks_type@wkWidth=800
    wks_type@wkHeight=800
    wks = gsn_open_wks(wks_type,"../fig/mangkhut/d02_precip_180916_acc_simulate_"+casename)      ; send graphics to PNG file
    
    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
    res@cnLevels =    (/1, 2, 5, 10, 20, 30, 40, 50, 60, 70, 80, 100, 120, 150, 200, 250, 300, 400, 500/)
   
    gsn_define_colormap(wks,"precip2_17lev")
    res@gsnLeftString="COAWST 20180916 00Z-24Z Accum Precip"
    ;---Call plotting routine which draws contours over a map
    obv_pr:=obv_pr(lat|:,lon|:)
    plot = gsn_csm_contour_map(wks,ctrl_var1_acc,res)
    chinamap = add_china_map(wks,plot,cnres)
   
    ;Obv Track
    res_lines=True
    res_lines@gsLineColor       = "black"
    res_lines@gsLineDashPattern = 0.
    res_lines@gsLineThicknessF  = 3.                    ; line thicker
    
    yy := tc_loc(:,1) 
    xx := tc_loc(:,0) 
    dum1=gsn_add_polyline(wks,plot,yy,xx,res_lines)              ; N

    do ii =0, dim_tc-1
        dum1@$unique_string("xx")$    = gsn_add_polymarker(wks,plot,yy(ii),xx(ii),obv_polyres)
    end do

    dum_track=gsn_add_polyline(wks,plot, rec_tc(:,1) , rec_tc(:,0),pres)

    ;overlay(plot, plotv)
    draw(plot)
    frame(wks)
    time_frame=time_frame+1
    ;delete(wks)
    break
end do
end
