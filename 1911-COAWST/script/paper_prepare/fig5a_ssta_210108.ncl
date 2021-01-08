;*******************************************************
; lcnative_2.ncl
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/roms/ROMS_utils.ncl"
begin
;************************************************
; open file and read in data
;************************************************
  
    
    g_font=0.018
    casename="TY2001" 
    base_path="/home/metctm1/array/data/1911-COAWST/"
    fig_prefix="fig5a_droms_ssta_area_" 

    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)
   
    wrfout_path=base_path+casename+"/wrfout_d02"
    ocean_path=base_path+"/TY2001/gba_ocean_his.nc"
   
    ; --------Ocean grid file
    ocn_in     = addfile(ocean_path, "r")
    lon2d=ocn_in->lon_rho
    lat2d=ocn_in->lat_rho
    
    vert_ly=ocn_in->s_rho
    zlays=dimsizes(vert_ly)
    roms_time=ocn_in->ocean_time
    sea_mask=ocn_in->mask_rho
    lentime_roms=dimsizes(roms_time)
    
    ; ---------parser time from wrf
    grid_in = addfile(wrfout_path,"r")
    time0 = wrf_user_getvar(grid_in,"Times", -1)
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
    ;date_str:=date_str(::2) ; consisitent with the ocn output
    lentime_wrf=dimsizes(xtime)
    ; ---------parser time from wrf
 
    ; get in ibtrck data
    tck_file=base_path+"hko.trck.mangkhut"
    ncol=5
    tc_loc = readAsciiTable(tck_file,ncol,"float", 1) ; tc_loc(nrec, ncol) 
    dims=dimsizes(tc_loc) 
    dim_tc=dims(0)
   
    ; get in SEN tc track data
    ;0-timestamp 1-lat 2-lon 3-minSLP 4-maxWS 5-uRadius 6-vRadius
    sen_tc =asciiread(base_path+casename+"/trck."+casename+".d01",(/lentime_wrf,7/),"float")
    sen_tc:=transpose(sen_tc)
 
    ; get in CTRL tc track data 
    ;0-timestamp 1-lat 2-lon 3-minSLP 4-maxWS 5-uRadius 6-vRadius
    ctrl_tc = asciiread(base_path+"WRFONLY/trck.WRFONLY.d01",(/lentime_wrf,7/),"float")
    ctrl_tc:=transpose(ctrl_tc)
    
    count_tc=0
    ctrl_istrt=0 ; count no tc frames
    do ii=0, lentime_wrf-1
        if (ctrl_tc(4, ii) .gt. 0) then
            if (count_tc .eq. 0) then ;first time
                ctrl_istrt=ii
            end if
            count_tc=count_tc+1
        end if
    end do
    ctrl_iend=ctrl_istrt+count_tc-1


        
  res                   = True              ; plot mods desired
;---Resources for filled contour plot
  res@gsnMaximize          = True
  res@gsnFrame = False
  res@gsnDraw = False
  res@cnFillOn             = True  
  res@cnLinesOn            = False
  res@cnLevelSpacingF      = 2.           ; NCL chose 4.0

;---Necessary for contours to be overlaid correctly on WRF projection
  res@tfDoNDCOverlay       = True
  res@gsnAddCyclic         = False
  res@cnFillMode           = "CellFill" ; Raster Mode
  res@gsnSpreadColors      = True               ; use full color map
  res@gsnRightString = "~S~o~N~C"
  res@gsnStringFontHeightF = g_font 
  res@gsnMaximize      = True       ; fill up the page
  res@gsnPaperOrientation = "portrait"

  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  res@tmYLMajorLengthF = 0.01
  res@tmXBMajorLengthF = 0.01
  ;res@lbLabelStride = 1  
  
  
  
  res@tmXBLabelFontHeightF = g_font
  res@tmYLLabelFontHeightF = g_font
  res@tmXBLabels=ispan(110,120,5)+"~S~o~N~E"
  res@tmYLLabels=ispan(15,25,5)+"~S~o~N~N"



  res@mpMinLatF=min(lat2d)
  res@mpMaxLatF=max(lat2d)
  res@mpMaxLonF=max(lon2d)
  res@mpMinLonF=min(lon2d)

  
  
  res@mpGridAndLimbOn        = True             ; Turn on lat/lon grid
  res@mpGridLineDashPattern  = 2                ; Dashed lines
  res@mpGridSpacingF         = 5.0 
  res@mpGridLineThicknessF   = 1.0
  res@mpGridLineColor        = "Gray30"

  res@mpGeophysicalLineColor = "gray10"
  res@mpDataBaseVersion       = "MediumRes"
  res@mpDataSetName           = "Earth..4"
  res@mpLandFillColor         = "gray80"

  res@mpGeophysicalLineThicknessF = 2.0
  res@cnFillDrawOrder         = "PreDraw"
  res@mpOutlineOn             = True  ; Use outlines from shapefile


  polyres                   = True
  polyres@gsMarkerIndex     = 14          ; polymarker style
  polyres@gsMarkerSizeF     = 12.          ; polymarker size
  polyres@gsMarkerThicknessF     = 3.          ; polymarker size
  polyres@gsMarkerColor     = "red"          ; polymarker size

  obv_polyres=polyres
  
  obv_polyres@gsMarkerColor     = "black"          ; polymarker size
  obv_polyres@gsMarkerIndex     = 16          ; polymarker style
  obv_polyres@gsMarkerSizeF     = 9.          ; polymarker size


  ;---Resources for the polyline
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 3.0            ; line thickness   
  pres@gsLineColor      = "red"         ; color of lines
  pres_wrf=pres
  pres_wrf@gsLineColor="blue"

  tres  = True
  tres@txFontHeightF = 0.018
  tres@txJust="CenterLeft"
  tlat=18.0
  tlon=110.0
 
  resv                         = True               ; plot mods desired
  resv@vcGlyphStyle            = "LineArrow"         ; choose wind barbs
;  resv@lbOrientation           = "vertical"         ; vertical label bar
  resv@gsnDraw = False
  resv@gsnFrame = False
  resv@vcRefMagnitudeF         = 4                ; make vectors larger
  resv@vcRefLengthF            = 0.02              ; ref vec length
  resv@vcMinDistanceF          = 0.025              ; thin out windbarbs
  resv@vcRefAnnoOn             = True              ; turn off ref wind barb
  resv@vcRefAnnoOrthogonalPosF = -1             ; move ref vector up
  resv@gsnLeftString = ""
  resv@gsnRightString= ""
  resv@gsnAddCyclic            = False              ; regional data

  resv@vcRefAnnoString1  = "4 m/s"
  resv@vcRefAnnoFontHeightF=g_font*0.7
  resv@vcRefAnnoString2  = ""
  resv@vcLineArrowThicknessF     = 2.0    ;thickness of vector
  resv@vcLineArrowHeadMinSizeF   = 0.004
  resv@vcLineArrowHeadMaxSizeF   = 0.004
 



    wks_type="pdf"
    
    res_lines=True
    res_lines@gsLineColor       = "black"
    res_lines@gsLineDashPattern = 0.
    res_lines@gsLineThicknessF  = 3.                    ; line thicker
    


time_frame = 23 
ampf=(lentime_roms-1)/(lentime_wrf-1)
;ampf=1
do while(time_frame .lt. lentime_roms)
    ;---Set map resources based on projection on WRF output file

    ;************************************************
    ; create plot
    ;************************************************
    ; get temp first layer
  	print(ampf*time_frame)
    ctrl_var1  = ocn_in->temp(ampf*time_frame,zlays-1,:,:)
  	ctrl_var2  := ocn_in->u(ampf*time_frame,zlays-1,:,:)
  	ctrl_var3  := ocn_in->v(ampf*time_frame,zlays-1,:,:)
    ctrl_var2:=u2rho(ctrl_var2)
    ctrl_var3:=v2rho(ctrl_var3)
    ctrl_var2=where(sea_mask .eq. 1, ctrl_var2, ctrl_var2@_FillValue)
    ctrl_var1@lat2d = lat2d
    ctrl_var1@lon2d = lon2d
    ctrl_var2@lat2d = lat2d
    ctrl_var2@lon2d = lon2d
    ctrl_var3@lat2d = lat2d
    ctrl_var3@lon2d = lon2d
    currspeed=sqrt(ctrl_var2*ctrl_var2+ctrl_var3*ctrl_var3)
    ctrl_var2=where(( currspeed.lt. 0.5),  ctrl_var2@_FillValue, ctrl_var2)

    r_mean=wgt_areaave_Wrap(ctrl_var1,1.0,1.0,0)
    ctrl_var1=(/ctrl_var1-r_mean/)


    print(date_str(time_frame)+"--> lat: "+sen_tc(1,time_frame)+" lon: "+sen_tc(2,time_frame)+" minSLP= "+sen_tc(3, time_frame))
    wks = gsn_open_wks(wks_type,"../../fig/paper/"+fig_prefix+sprinti("%0.3iFrm", time_frame))      ; send graphics to PNG file

    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        = -1.8          ; set min contour level
    res@cnMaxLevelValF        = 1.8        ; set max contour level
    res@cnLevelSpacingF       = 0.1          ; set contour interval
  


    gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
    ;gsn_reverse_colormap(wks)
    res@gsnLeftString="(a) SST Depart. & Surf. Curr. @ "+date_str(time_frame)
    ;---Call plotting routine which draws contours over a map
    plot = gsn_csm_contour_map(wks,ctrl_var1,res)
    plotv = gsn_csm_vector(wks, ctrl_var2,ctrl_var3, resv)



    ; Obv Track
    yy := tc_loc(:,2)/10.0
    xx := tc_loc(:,1)/10.0 
    obv_track=gsn_add_polyline(wks,plot,yy,xx,res_lines)              ; N

    do ii =0, dim_tc-1
        obv_track@$unique_string("xx")$    = gsn_add_polymarker(wks,plot,yy(ii),xx(ii),obv_polyres)
    end do

    ; Ctrl Track
    ctrl_track=gsn_add_polyline(wks,plot,ctrl_tc(2,ctrl_istrt:ctrl_iend), ctrl_tc(1, ctrl_istrt:ctrl_iend),pres_wrf)  

    ; SEN Track
    center_sen  = gsn_add_polymarker(wks,plot,sen_tc(2,time_frame),sen_tc(1, time_frame),polyres)
    sen_track   = gsn_add_polyline(wks, plot, sen_tc(2, 0:time_frame) , sen_tc(1,0:time_frame),pres)
    
    ; legends
    yy := (/107.0, 108.0/)
    xx := (/25.5, 25.5/)
    obv_lg = gsn_add_polyline(wks, plot, yy, xx, res_lines)
    obv_lg@leftDot=gsn_add_polymarker(wks, plot, yy(0), xx(0), obv_polyres)
    obv_lg@rightDot=gsn_add_polymarker(wks, plot, yy(1), xx(1), obv_polyres)
    obv_lg@txt=gsn_add_text(wks, plot, "HKO bestTrack", yy(1)+0.5, xx(1), tres)
    
    xx = xx - 0.7
    ctrl_lg = gsn_add_polyline(wks, plot, yy, xx, pres_wrf)
    ctrl_lg@txt=gsn_add_text(wks, plot, "WRFONLY", yy(1)+0.5, xx(1), tres)


    xx = xx - 0.7
    sen_lg = gsn_add_polyline(wks, plot, yy, xx, pres)
    sen_lg@txt=gsn_add_text(wks, plot, "TY2001", yy(1)+0.5, xx(1), tres)

    overlay(plot, plotv)
    draw(plot)
    frame(wks)
    time_frame=time_frame+1
    break
end do
end
