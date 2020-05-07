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
    imerg_path="/disk/v092.yhuangci/lzhenn/1911-COAWST/obv/hfhr-gpm/"  
    all_fn=systemfunc("ls "+imerg_path+"/*")  
    imerg_in=addfiles(all_fn,"r")
    obv_pr=imerg_in[:]->precipitationCal(32:53,:,:)
    printVarSummary(obv_pr)
    do ii = 0,10
        obv_pr(ii,:,:)=obv_pr(2*ii,:,:)+obv_pr(2*ii+1,:,:)
    end do
    
    ; get in wrf tc track data
    ;0-timestamp 1-lat 2-lon 3-minSLP 4-maxWS 5-uRadius 6-vRadius
    case_tc = asciiread("/disk/v092.yhuangci/lzhenn/1911-COAWST/ERA5_C2008/trck.ERA5_C2008.d02", (/lentime,7/),"float")
    ; parser lat lon
  
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
  wks_type="png"
  wks_type@wkWidth=800
  wks_type@wkHeight=800

time_frame = 0
; tc box radius
boxR=24

var_comp=obv_pr(0,0:2*boxR,0:2*boxR)
var_comp=0
time_frame=0
lentime=10

sim_strt=27
sim_end=37

do while(time_frame .lt. lentime)
    ;---Set map resources based on projection on WRF output file

    ;************************************************
    ; create plot
    ;************************************************
    
    wks = gsn_open_wks(wks_type,"/disk/hq247/yhuangci/lzhenn/project/1911-COAWST/fig/box_comp")      ; send graphics to PNG file
    
  
    gsn_define_colormap(wks,"precip2_17lev")
    res@gsnLeftString="Imerg GPM Comp Hourly Pr"
    ;---Call plotting routine which draws contours over a map
    tc_lon=case_tc(time_frame,2)
    tc_lat=case_tc(time_frame,1)
     
    var_comp=var_comp+obv_pr(time_frame,cor_x1-boxR:cor_x1+boxR,cor_y1-boxR:cor_y1+boxR)
    time_frame=time_frame+1
end do
var_comp=var_comp/(lentime-27+1)
res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
res@cnLevels =    (/0.1, 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 14, 16, 20, 25, 30, 40, 50/)
plot = gsn_csm_contour(wks,var_comp,res)
draw(plot)
frame(wks)

end
