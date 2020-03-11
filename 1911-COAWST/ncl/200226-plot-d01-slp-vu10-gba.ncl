;*******************************************************
; lcnative_2.ncl
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
begin
;************************************************
; open file and read in data
;************************************************
    casename="mangkhut" 
    wrfout_path="../data/1911-COAWST/"+casename+"/wrfout_d01"
    g_font=0.02
    
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)


    
    
    ; get wrf fully coupled nc data
    
    all_files=systemfunc("ls "+wrfout_path+"*")
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
    flen=dimsizes(all_files)

    do ii = 0, flen-1
        ; get slp
        ctrl_var1  := wrf_user_getvar(ctrl_in[ii],"slp", -1)  
        dims:=dimsizes(ctrl_var1)
        dim_t=dims(0)
        dim_y=dims(1)
        dim_x=dims(2)
     
       
        ;ctrl_var2  = wrf_user_getvar(ctrl_in,"U10", -1)  
        ;ctrl_var3  = wrf_user_getvar(ctrl_in,"V10", -1)  
        
        
        
        ; parser time
        time0 := wrf_user_getvar(ctrl_in,"Times", -1)
        xtime := wrf_times_c( time0, 1 ) 
        ;xtime = xtime+8 
        lc_date:=cd_calendar(xtime, 0)
        year   = tointeger(lc_date(:,0))    ; Convert to integer for
        month  = tointeger(lc_date(:,1))    ; use sprinti 
        day    = tointeger(lc_date(:,2))
        hour   = tointeger(lc_date(:,3))
        minute = tointeger(lc_date(:,4))
        second = lc_date(:,5)

        date_str = month_abbr(month)+sprinti(" %0.2i ", day) + sprinti("%0.2iZ", hour) +sprinti("%0.2i:00", minute)
        lentime=dimsizes(xtime)

        ; parser lat lon
        lat2d = wrf_user_getvar(ctrl_in,"XLAT",  1)
        lon2d = wrf_user_getvar(ctrl_in,"XLONG", 1)
        ctrl_var1@lat2d = lat2d
        ctrl_var1@lon2d = lon2d
        
        ; lets find the TC center!
        rec_tc=new((/3,dim_t/), typeof(ctrl_var1)) ; (0)--lat, (1)--lon, (2)--slp
        do tt = 0, dim_t-1
            tmp1D      = ndtooned(ctrl_var1(tt,:,:))
            indices  = ind_resolve(minind(tmp1D),(/dim_y,dim_x/))
            id_y=indices(0,0)
            id_x=indices(0,1)
            rec_tc(0,tt)=lat2d(id_y,id_x)
            rec_tc(1,tt)=lon2d(id_y,id_x)
            rec_tc(2,tt)=min(tmp1D)
            ;print("lat: "+rec_tc(0,tt)+" lon: "+rec_tc(1,tt)+" minSLP= "+min(tmp1D))
            print(rec_tc(0,tt)+" "+rec_tc(1,tt)+" "+min(tmp1D))
        end do
    end do
    exit
    
  res                   = True              ; plot mods desired
;---Resources for filled contour plot
  res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
  res@cnMinLevelValF        = 940.          ; set min contour level
  res@cnMaxLevelValF        = 1000.          ; set max contour level
  res@cnLevelSpacingF      = 2.        
  
  res@gsnMaximize          = True
  res@gsnFrame = False
  res@gsnDraw = False
  res@cnFillOn             = True  
  res@cnLinesOn            = False
  res@lbOrientation        = "Vertical"

;---Necessary for contours to be overlaid correctly on WRF projection
  res@tfDoNDCOverlay       = True
  res@gsnAddCyclic         = False
  res@cnFillMode           = "CellFill" ; Raster Mode
  res@gsnSpreadColors      = True               ; use full color map
  res@gsnRightString = "hPa"
  res@gsnStringFontHeightF = g_font 
  res@gsnMaximize      = True       ; fill up the page
  res@gsnPaperOrientation = "portrait"

  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = 0.02              ; make labels smaller
  res@tmYLMajorLengthF = 0.01
  res@tmXBMajorLengthF = 0.01
  ;res@lbLabelStride = 1  
  res@tmXBLabelFontHeightF = g_font
  res@tmYLLabelFontHeightF = g_font
  res@mpGridAndLimbOn        = True             ; Turn on lat/lon grid
  res@mpGridLineDashPattern  = 2                ; Dashed lines
  res@mpGridSpacingF         = 5.0 
  res@mpGridLineThicknessF   = 2.0
  res@mpGridLineColor        = "Gray80"


  res@mpOutlineOn             = True  ; Use outlines from shapefile
  
  res@mpGeophysicalLineColor      = "Black"
  res@mpLimbLineColor             = "Black"
  res@mpNationalLineColor         = "Black"
  res@mpPerimLineColor            = "Black"
  res@mpUSStateLineColor          = "Black"
  ;res@mpOutlineOn             = True  ; Use outlines from shapefile
  res@mpOutlineBoundarySets = "National" ;Turns on country boundaries.
  res@mpGeophysicalLineColor = "gray30"
  ;pres@cnFillDrawOrder         = "PreDraw"
  res@mpGeophysicalLineThicknessF=2.0
  res@mpOutlineBoundarySets     = "GeophysicalAndUSStates"; turn on states
  res@mpDataBaseVersion         = "MediumRes"             ; select database
  res@mpDataSetName             = "Earth..2"
  ;res@mpLandFillColor         = "gray80"
  ;res@mpOceanFillColor         = "Blue"
  ;res@mpInlandWaterFillColor  = "Skyblue"

  
  polyres                   = True
  polyres@gsMarkerIndex     = 14          ; polymarker style
  polyres@gsMarkerSizeF     = 12.          ; polymarker size
  polyres@gsMarkerThicknessF     = 3.          ; polymarker size
  polyres@gsMarkerColor     = "Black"          ; polymarker size

  obv_polyres=polyres
  obv_polyres@gsMarkerIndex     = 16          ; polymarker style
  obv_polyres@gsMarkerSizeF     = 9.          ; polymarker size


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
 
  resv                         = True               ; plot mods desired
  resv@vcGlyphStyle            = "WindBarb"         ; choose wind barbs
;  resv@lbOrientation           = "vertical"         ; vertical label bar
  resv@gsnDraw = False
  resv@gsnFrame = False
  resv@vcRefMagnitudeF         = 5.                ; make vectors larger
  resv@vcRefLengthF            = 0.015              ; ref vec length
  resv@vcMinDistanceF          = 0.03              ; thin out windbarbs
  resv@vcWindBarbLineThicknessF = 3.
  resv@vcWindBarbColor = "grey50"
  resv@vcWindBarbTickLengthF   = 0.5                ; length of the barb tick
  resv@vcWindBarbTickSpacingF  = 0.3                ; distance between ticks
  resv@vcRefAnnoOn             = False              ; turn off ref wind barb
  resv@gsnLeftString = ""
  resv@gsnRightString= ""
  resv@gsnAddCyclic            = False              ; regional data


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
    wks = gsn_open_wks(wks_type,"../fig/sandy/"+casename+"_d01_SLP_"+sprinti("%0.3iFrm", time_frame))      ; send graphics to PNG file
    gsn_define_colormap(wks,"wind_17lev")
    gsn_reverse_colormap(wks)
    res@gsnLeftString="SLP @ "+date_str(time_frame)
    ;---Call plotting routine which draws contours over a map
    plot = gsn_csm_contour_map(wks,ctrl_var1(time_frame,:,:),res)
  
    ; center
    ;dum1    = gsn_add_polymarker(wks,plot,tc_loc(3,1),tc_loc(3,0),polyres)
    dum1    = gsn_add_polymarker(wks,plot,rec_tc(1,time_frame),rec_tc(0,time_frame),polyres)
    dum_text    = gsn_add_text(wks,plot,sprintf("Center SLP: %3.1f hPa", rec_tc(2, time_frame)),tlon,tlat,tres)
    if (time_frame .gt. 0) then
        dum_track=gsn_add_polyline(wks,plot, rec_tc(1, 0:time_frame) , rec_tc(0,0:time_frame),pres)
    end if

    ;Obv Track
    res_lines=True
    res_lines@gsLineColor       = "black"
    res_lines@gsLineDashPattern = 0.
    res_lines@gsLineThicknessF  = 3.                    ; line thicker
    
    yy := tc_loc(:,1) 
    xx := tc_loc(:,0) 
    obv_track=gsn_add_polyline(wks,plot,yy,xx,res_lines)              ; N

    do ii =0, dim_tc-1
        dum1@$unique_string("xx")$    = gsn_add_polymarker(wks,plot,yy(ii),xx(ii),obv_polyres)
    end do

    ; wrf only track
    yy := wrf_tc(:,1) 
    xx := wrf_tc(:,0) 
    wrf_track=gsn_add_polyline(wks,plot,yy,xx,pres_wrf)              ; N


    ;overlay(plot, plotv)
    draw(plot)
    frame(wks)
    time_frame=time_frame+1
    ;delete(wks)
    ;break
end do
end
