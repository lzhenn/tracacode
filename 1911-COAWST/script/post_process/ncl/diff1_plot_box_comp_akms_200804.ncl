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
    if (.not. isvar("pre_dir")) then 
        pre_dir="/users/b145872/project-dir/app/COAWST-sandy-wrf/WRF/run/"
    end if 
    if (.not. isvar("case_sen")) then 
        case_sen="mangkhut-wrfonly" 
    end if 
    if (.not. isvar("case_ctrl")) then 
        case_ctrl="mangkhut-wrfonly" 
    end if 
    if (.not. isvar("fig_path")) then 
        fig_path="/users/b145872/project-dir/app/COAWST-sandy-wrf/WRF/run/"
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

    varname="AKMS"


    fig_prefix="d0"+tostring(i_dom)+"_"+varname+"_"
    g_font=0.02
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)
    
    ; get in ibtrck data
    ncol=6
    tc_loc = readAsciiTable(trck_path,ncol,"float", 1) ; tc_loc(nrec, ncol) 
    dims=dimsizes(tc_loc) 
    dim_tc=dims(0)
 

   
   ; get wrf nc data
    wrfout_ctrl=pre_dir+"/"+case_ctrl+"/wrfout_d0"+tostring(i_dom)
    wrfout_sen=pre_dir+"/"+case_sen+"/wrfout_d0"+tostring(i_dom)

    ctrl_in      = addfile (wrfout_ctrl, "r")   ; note the "s" of addfile
    sen_in      = addfile (wrfout_sen, "r")   ; note the "s" of addfile
    
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
    case_tc_ctrl = asciiread(pre_dir+"/"+case_ctrl+"/trck."+case_ctrl+".d0"+i_dom,(/lentime,7/),"float")
    case_tc_sen = asciiread(pre_dir+"/"+case_sen+"/trck."+case_sen+".d0"+i_dom,(/lentime,7/),"float")

    ; parser lat lon
    lat2d = wrf_user_getvar(ctrl_in,"XLAT",  0)
    lon2d = wrf_user_getvar(ctrl_in,"XLONG", 0)
  

    ; get rain
    ;ctrl_var1  = wrf_user_getvar(ctrl_in,"RAINC", -1)  
  	ctrl_var2  = wrf_user_getvar(ctrl_in,varname, -1)  
  	sen_var2  = wrf_user_getvar(sen_in,varname, -1)  
    lsmask=wrf_user_getvar(ctrl_in,"LANDMASK",0)
    ;ctrl_var1  = (ctrl_var1+ctrl_var2)
 
    dims:=dimsizes(ctrl_var2)
    dim_t=dims(0)
    dim_y=dims(1)
    dim_x=dims(2)
    
    ; parser lat lon
    ctrl_var2@lat2d = lat2d
    ctrl_var2@lon2d = lon2d

    ;ctrl_var1=(/ctrl_var1-273.15/)   

  res=True 
;---Resources for filled contour plot
  res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
  res@cnMinLevelValF        = -1e-2          ; set min contour level
  res@cnMaxLevelValF        = 1e-2          ; set max contour level
  res@cnLevelSpacingF       = 1e-3          ; set contour interval
  
  
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

  res@tmYLMode          = "Explicit"                ; explicit labels
  res@tmYLValues        = ispan(0,160,40)
  res@tmYLLabels        = 3*(res@tmYLValues)+" km"         ; make strings
  res@tmXBMode          = "Explicit"                ; explicit labels
  res@tmXBValues        = ispan(0,160,40)
  res@tmXBLabels        = 3*(res@tmYLValues)+" km"         ; make strings
  
 

  
  
  wks_type="png"
  wks_type@wkWidth=800
  wks_type@wkHeight=800

; tc box radius
boxR=80

var_comp2_ctrl=ctrl_var2(0,0:2*boxR,0:2*boxR)
var_comp2_ctrl=0

var_comp2_sen=sen_var2(0,0:2*boxR,0:2*boxR)
var_comp2_sen=0

time_frame=istrt

do while(time_frame .lt. ilast)
    ;---Call plotting routine which draws contours over a map
    tc_lon_ctrl=case_tc_ctrl(time_frame,2)
    tc_lat_ctrl=case_tc_ctrl(time_frame,1)
    
    tc_lon_sen=case_tc_sen(time_frame,2)
    tc_lat_sen=case_tc_sen(time_frame,1)
     
    point_ctrl=getind_latlon2d(lat2d,lon2d,tc_lat_ctrl,tc_lon_ctrl)
    point_sen=getind_latlon2d(lat2d,lon2d,tc_lat_sen,tc_lon_sen)

    cor_x1_ctrl=point_ctrl(0,0)
    cor_y1_ctrl=point_ctrl(0,1)
    cor_x1_sen=point_sen(0,0)
    cor_y1_sen=point_sen(0,1)
    ; (0,0)->(0,1)->(1,1)->(1,0)        
    ;box_x=(/cor_x1-boxR, cor_x1-boxR, cor_x1+boxR, cor_x1+boxR, cor_x1-boxR/)
    ;box_y=(/cor_y1-boxR, cor_y1+boxR, cor_y1+boxR, cor_y1-boxR, cor_y1-boxR/)
    ctrl_var2(time_frame,:,:)=where(lsmask .eq. 1, ctrl_var2@_FillValue, ctrl_var2(time_frame,:,:))
    sen_var2(time_frame,:,:)=where(lsmask .eq. 1, sen_var2@_FillValue, sen_var2(time_frame,:,:))
    var_comp2_ctrl=var_comp2_ctrl+ctrl_var2(time_frame,cor_x1_ctrl-boxR:cor_x1_ctrl+boxR,cor_y1_ctrl-boxR:cor_y1_ctrl+boxR)
    var_comp2_sen=var_comp2_sen+sen_var2(time_frame,cor_x1_sen-boxR:cor_x1_sen+boxR,cor_y1_sen-boxR:cor_y1_sen+boxR)
    time_frame=time_frame+1
end do

wks = gsn_open_wks(wks_type,fig_path+"/"+fig_prefix+"diff_box_comp")      ; send graphics to PNG file
gsn_define_colormap(wks,"MPL_BrBG")
;res@gsnLeftString=varname+" "+case_sen+"-"+case_ctrl
res@gsnLeftString=varname+" ERA5_C2008-ERA5_WRFROMS"
var_comp2_ctrl=var_comp2_ctrl/(ilast-istrt+1)
var_comp2_sen=var_comp2_sen/(ilast-istrt+1)
diff_var=var_comp2_sen-var_comp2_ctrl

mean_var=wgt_areaave_Wrap(diff_var,1.0,1.0,0)
res@gsnRightString = sprintf(" %5.1f m/s", mean_var)
plot = gsn_csm_contour(wks,diff_var,res)
draw(plot)
frame(wks)
 
end
