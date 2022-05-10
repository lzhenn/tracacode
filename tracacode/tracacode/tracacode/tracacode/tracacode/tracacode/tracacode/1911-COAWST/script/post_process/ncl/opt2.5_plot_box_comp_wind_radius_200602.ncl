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
    if (.not. isvar("comp1_tstrt")) then 
        comp1_tstrt="2019091516"
    end if 
    if (.not. isvar("comp1_tend")) then 
        comp1_tend="2019091602"
    end if 

    varname="UV10"
    
    fig_prefix="d0"+tostring(i_dom)+"_UV10_acentrosymmetric_NW-SE_"
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
    istrt   = ind(lc_date .eq. toint(comp1_tstrt))
    ilast   = ind(lc_date .eq. toint(comp1_tend))

    
    ; get in wrf tc track data
    ;0-timestamp 1-lat 2-lon 3-minSLP 4-maxWS 5-uRadius 6-vRadius
    case_tc = asciiread(wrfout_path+"/trck."+casename+".d0"+i_dom,(/lentime,7/),"float")
    ; parser lat lon
    lat2d = wrf_user_getvar(ctrl_in,"XLAT",  0)
    lon2d = wrf_user_getvar(ctrl_in,"XLONG", 0)
  

    ; get rain
    ;ctrl_var1  = wrf_user_getvar(ctrl_in,"RAINC", -1)  
  	ctrl_var2  = wrf_user_getvar(ctrl_in,"U10", -1)  
  	ctrl_var3  = wrf_user_getvar(ctrl_in,"V10", -1)  
    ;ctrl_var1  = (ctrl_var1+ctrl_var2)
 
    dims:=dimsizes(ctrl_var2)
    dim_t=dims(0)
    dim_y=dims(1)
    dim_x=dims(2)
    
    ; parser lat lon
    lat2d = wrf_user_getvar(ctrl_in,"XLAT",  1)
    lon2d = wrf_user_getvar(ctrl_in,"XLONG", 1)
    ctrl_var2@lat2d = lat2d
    ctrl_var2@lon2d = lon2d

    ctrl_var3@lat2d = lat2d
    ctrl_var3@lon2d = lon2d
    ;ctrl_var1=(/ctrl_var1-273.15/)   

  res=True 
;---Resources for filled contour plot
    
  res@gsnMaximize          = True
  res@gsnFrame = False
  res@gsnDraw = False
  res@cnFillOn             = True  
  res@cnLinesOn            = False
  ;res@cnLevelSpacingF      = 2.           ; NCL chose 4.0
  res@lbOrientation        = "Vertical"

;---Necessary for contours to be overlaid correctly on WRF projection
  res@tfDoNDCOverlay       = True
  res@gsnAddCyclic         = False
  res@cnFillMode           = "CellFill" ; Raster Mode
  res@gsnSpreadColors      = True               ; use full color map
  res@gsnRightString = "%"
  res@gsnStringFontHeightF = g_font 
  res@gsnMaximize      = True       ; fill up the page
  res@gsnPaperOrientation = "portrait"
  res@cnFillMode           = "CellFill" ; Raster Mode

  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = 0.02              ; make labels smaller
  res@tmYLMajorLengthF = 0.01
  res@tmXBMajorLengthF = 0.01
  ;res@lbLabelStride = 1  
  res@tmXBLabelFontHeightF = g_font
  res@tmYLLabelFontHeightF = g_font


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


  
  
  wks_type="png"
  wks_type@wkWidth=800
  wks_type@wkHeight=800

; tc box radius
boxR=80

var_comp2=ctrl_var2(0,0:2*boxR,0:2*boxR)
var_comp3=ctrl_var3(0,0:2*boxR,0:2*boxR)
dis_array=ctrl_var2(0,0:2*boxR,0:2*boxR)
var_comp2=0
var_comp3=0
do ii=0,2*boxR
    do jj=0,2*boxR
        dis_array(ii,jj)=round(sqrt((ii-boxR)*(ii-boxR)+(jj-boxR)*(jj-boxR)),0)
    end do
end do



time_frame=istrt
do while(time_frame .lt. ilast)
    ;---Set map resources based on projection on WRF output file

    ;************************************************
    ; create plot
    ;************************************************
    
    wks = gsn_open_wks(wks_type,fig_path+"/"+fig_prefix+casename+"_box_comp_radius_asymmetric")      ; send graphics to PNG file
    
  
    gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
    res@gsnLeftString=casename+" Comp"
    ;---Call plotting routine which draws contours over a map
    tc_lon=case_tc(time_frame,2)
    tc_lat=case_tc(time_frame,1)
     
    point=getind_latlon2d(lat2d,lon2d,tc_lat,tc_lon)
    cor_x1=point(0,0)
    cor_y1=point(0,1)
    ; (0,0)->(0,1)->(1,1)->(1,0)        
    ;box_x=(/cor_x1-boxR, cor_x1-boxR, cor_x1+boxR, cor_x1+boxR, cor_x1-boxR/)
    ;box_y=(/cor_y1-boxR, cor_y1+boxR, cor_y1+boxR, cor_y1-boxR, cor_y1-boxR/)

    var_comp2=var_comp2+ctrl_var2(time_frame,cor_x1-boxR:cor_x1+boxR,cor_y1-boxR:cor_y1+boxR)
    var_comp3=var_comp3+ctrl_var3(time_frame,cor_x1-boxR:cor_x1+boxR,cor_y1-boxR:cor_y1+boxR)

    time_frame=time_frame+1
end do

;---Resources for filled contour plot
res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
res@cnMinLevelValF        = -8.          ; set min contour level
res@cnMaxLevelValF        = 8.          ; set max contour level
res@cnLevelSpacingF       = 0.5          ; set contour interval
 
var_comp2=var_comp2/(ilast-istrt+1)
var_comp3=var_comp3/(ilast-istrt+1)
windspeed=wind_speed(var_comp2, var_comp3)

windspeed_rmean=windspeed
windspeed_rmean=-999
windspeed_rmean@_FillValue=-999
var_cir=windspeed
var_cir=-999
var_cir@_FillValue=-999
cir_mean=var_cir(0,0:boxR)
do ii = 0,boxR
    var_cir=where(dis_array .eq. ii, windspeed, var_cir@_FillValue) ; get a circle
    cir_mean(ii)=wgt_areaave(var_cir,1.0,1.0,0)
    windspeed_rmean=where(dis_array .eq. ii, cir_mean(ii), windspeed_rmean)
end do
; write out radius data, use $project/script/200606-compare-radius.py to plot series map
asciiwrite (wrfout_path+"/"+varname+".radius", cir_mean)
windspeed=windspeed-windspeed_rmean





mean_var=wgt_areaave_Wrap(windspeed,1.0,1.0,0)
res@gsnRightString = "m/s"
plot = gsn_csm_contour(wks,windspeed,res)
;---Resources for the polyline

polyres                   = True
polyres@gsMarkerIndex     = 13          ; polymarker style
polyres@gsMarkerSizeF     = 16.          ; polymarker size
polyres@gsMarkerThicknessF     = 8.          ; polymarker size
polyres@gsMarkerColor     = "Black"          ; polymarker size

dum1    = gsn_add_polymarker(wks,plot,boxR,boxR,polyres)

draw(plot)
frame(wks)
 
end
