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
    wrfout_path="/disk/v092.yhuangci/lzhenn/1911-COAWST/ERA5_C2008/wrfout_d02"
    imerg_path="/disk/v092.yhuangci/lzhenn/1911-COAWST/obv/hfhr-gpm/"  
    g_font=0.02

    fr_strt=32-5
    fr_end=59-5
    ctrl_in      = addfile (wrfout_path, "r")   ; note the "s" of addfile
    ; parser lat lon
    lat2d = wrf_user_getvar(ctrl_in,"XLAT",  1)
    lon2d = wrf_user_getvar(ctrl_in,"XLONG", 1)
    latmax=max(lat2d)
    latmin=min(lat2d)
    lonmin=min(lon2d)
    lonmax=max(lon2d)

    
    all_fn=systemfunc("ls "+imerg_path+"/*")  
    imerg_in=addfiles(all_fn,"r")
    obv_pr=imerg_in[:]->precipitationCal(fr_strt:fr_end,:,:)
    obv_pr:=obv_pr(time|:,lat|:,lon|:)
    yyyymmddhh=cd_calendar(obv_pr&time, -3)
    print(yyyymmddhh)
    do ii = 0,(fr_end-fr_strt+1)/2-1
        obv_pr(ii,:,:)=obv_pr(2*ii,:,:)*0.5+obv_pr(2*ii+1,:,:)*0.5
    end do
    obv_pr:=obv_pr(0:(fr_end-fr_strt+1)/2-1,:,:)
     ; get in wrf tc track data
    ;0-timestamp 1-cat 2-lat 3-lon 4-minSLP 4-maxWS 5-uRadius 6-vRadius
    case_tc = asciiread("/disk/v092.yhuangci/lzhenn/1911-COAWST/cma.trck.mangkhut", (/52,6/),"integer")
    ;print(case_tc(:,0))
    ; shift to +xxxH to Init
    ;case_tc(:,0)=case_tc(:,0)-(/case_tc(0,0)/)
    
    ; interplote to hourly position
    fine_time_day=ispan(2018090700,2018091700,100)
    fine_time_hr=ispan(0,24,1)
    fine_time=new(dimsizes(fine_time_day)*dimsizes(fine_time_hr),"integer")
    nn=0
    do ii = 0, dimsizes(fine_time_day)-1
        do jj = 0, dimsizes(fine_time_hr)-1
            fine_time(nn)=fine_time_day(ii)+fine_time_hr(jj)
            nn=nn+1
        end do
    end do
    fine_time:=fine_time(0:dimsizes(fine_time)-13)
    fine_lat = linint1_Wrap (case_tc(:,0),case_tc(:,2), False, fine_time, 0)
    fine_lon = linint1_Wrap (case_tc(:,0),case_tc(:,3), False, fine_time, 0)
;    #216-->230 
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
  res@mpMinLatF=latmin
  res@mpMaxLatF=latmax
  res@mpMinLonF=lonmin
  res@mpMaxLonF=lonmax
  wks_type="png"
  wks_type@wkWidth=800
  wks_type@wkHeight=800
  
  polyres                   = True
  polyres@gsMarkerIndex     = 14          ; polymarker style
  polyres@gsMarkerSizeF     = 12.          ; polymarker size
  polyres@gsMarkerThicknessF     = 3.          ; polymarker size
  polyres@gsMarkerColor     = "Black"          ; polymarker size


  obv_polyres=polyres
  obv_polyres@gsMarkerIndex     = 16          ; polymarker style
  obv_polyres@gsMarkerSizeF     = 9.          ; polymarker size

;res = wrf_map_resources(ctrl_in,res)


; tc box radius
boxR=30

var_comp=(/obv_pr(0,0:2*boxR,0:2*boxR)/)
obv_pr:=obv_pr
var_comp=0
time_frame=216
lentime=231-1

fr_now=0

do while(time_frame .lt. lentime)
    ;---Set map resources based on projection on WRF output file

    ;************************************************
    ; create plot
    ;************************************************
    
    
  
    ;---Call plotting routine which draws contours over a map
    tc_lon=fine_lon(time_frame)/10.
    tc_lat=fine_lat(time_frame)/10.
    cor_x1=closest_val(tc_lat, obv_pr&lat)+10
    cor_y1=closest_val(tc_lon, obv_pr&lon)
    print(fine_time(time_frame))
    var_comp=var_comp+obv_pr(fr_now,cor_x1-boxR-10:cor_x1+boxR-10,cor_y1-boxR:cor_y1+boxR)
    time_frame=time_frame+1
    fr_now=fr_now+1

    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
    res@cnLevels =    (/0.1, 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 14, 16, 20, 25, 30, 40, 50/)
    printVarSummary(obv_pr)
end do
wks = gsn_open_wks(wks_type,"/disk/hq247/yhuangci/lzhenn/project/1911-COAWST/fig/box_comp_imerg")      ; send graphics to PNG file
gsn_define_colormap(wks,"precip2_17lev")
res@gsnLeftString="Imerg GPM Comp Hourly Pr"
var_comp=var_comp/(fr_now-1)
plot = gsn_csm_contour(wks,var_comp,res)
draw(plot)
frame(wks)

end
