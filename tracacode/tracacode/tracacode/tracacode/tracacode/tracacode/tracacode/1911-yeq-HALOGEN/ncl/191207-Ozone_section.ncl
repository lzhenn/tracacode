;*************************************************************
;Aim: Cal MAM detrended T2m standard deviation
;
;Mission:
;   1. Read data from NCEP-DOE data
;   2. Post-post process
;   3. Output to yearly files
;                       Zhenning Li
;                       2015-05-05
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN 
;   2015-04-18  Change to caculate Q1
;   2015-04-18  Change to caculate daily Q1 in NCEP-DOE
;   2015-12-01  Change to fit T2M
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;======================================================
;Variables List:
;	var1--------------U (K, TLL)
;======================================================

;global variables
    g_font=0.02

    ; Center
    lonC=90.0
    latC=30.0
    max_h=10000.
    method="WE" ; NS or WE

    type = "without"
    mon = "jan"
    left_string = "(a) Jan"
    ;debug_profix= "2016010"
    debug_profix= ""

;Prepare the variables
    loc_in     = addfile ("/disk/hq247/yhuangci/resource/map_info/research_domains/27km/GRIDCRO2D.27km", "r")   ; note the "s" of addfile
    lat2d = loc_in->LAT(0,0,:,:)    ; (TSTEP, LAY, ROW, COL)
    lon2d = loc_in->LON(0,0,:,:)
    th    = loc_in->HT(0,0,:,:) 
    sizes = dimsizes(lat2d)
    point=getind_latlon2d(lat2d,lon2d,latC,lonC)
    cor_x=point(0,1)
    cor_y=point(0,0)


    height_fn = systemfunc("ls /disk/v092.yhuangci/halogen_output/mcip_dir/"+mon+"/METCRO3D*"+debug_profix+"*")
    data_fn = systemfunc("ls /disk/hq247/yhuangci/analy/halogen/result/data/cmaq/"+type+"/"+mon+"/COMBINE_*"+debug_profix+"*.nc")
    u_fn  =systemfunc("ls /disk/v092.yhuangci/halogen_output/mcip_dir/"+mon+"/METDOT3D*"+debug_profix+"*")
    ;-----------------------below for all files--------------------------
    
    
    height_in = addfiles(height_fn,"r")
    ListSetType (height_in, "join")
    height = height_in[:]->ZF
    height_mean = dim_avg_n_Wrap(height,0)  ; esm mean
    height_mean := dim_avg_n_Wrap(height_mean,0) ; time mean
    
    specie_in = addfiles(data_fn,"r")
    ListSetType (specie_in, "join")
    var = specie_in[:]->O3
    var@lat2d=lat2d
    var@lon2d=lon2d
    var = var*1000
    var:=dim_avg_n_Wrap(var,0)  ; esm mean
    var:=dim_avg_n_Wrap(var,0)  ; temperal mean

    ;u_in = addfiles(u_fn ,"r")
    ;ListSetType (u_in, "join")
    ;u_wind  = wrf_user_getvar(u_in,"UWIND", -1)
    ;u_wind :=u_wind(:,0:23,0:24,0:219,0:289) 
    ;u_mean = dim_avg_n_Wrap(u_wind,0)
    ;u_mean := dim_avg_n_Wrap(u_mean,0)

    ;-----------------------upper for all files--------------------------
    
    ;-----------------------below for one-day file test--------------------------
    ;day_rank=9 
    ;height_in = addfile(height_fn(day_rank),"r")
    ;height = height_in->ZF(0:23,:,:,:)
    ;height_mean = dim_avg_n_Wrap(height,0)
    ;specie_in = addfile(data_fn(day_rank),"r")
    ;var = specie_in->BR(0:23,:,:,:)
    ;var := dim_avg_n_Wrap(var,0) 
    ;height_mean@lat2d=lat2d
    ;height_mean@lon2d=lon2d
    ;var@lat2d=lat2d
    ;var@lon2d=lon2d
    ;-----------------------upper for one-day file test--------------------------
    dims=dimsizes(var)
    dim_z=dims(0)
    dim_y=dims(1)
    dim_x=dims(2)
    ; adjust height (terrain+layer)
    do ii= 0, dim_z-1
        height_mean(ii,:,:)= height_mean(ii,:,:)+th
    end do
    ; interp var(z,x) cross_section
    nbins=100
    dh=max(height_mean)/nbins
    var_int=new((/nbins, dim_y, dim_x/),typeof(var))
    var_int@_FillValue=-999
    var_int!0="height"
    height_array=fspan(0,max(height_mean),nbins)
    var_int&height=height_array
    do jj=0,dim_y-1
        do ii=0,dim_x-1
            x=height_mean(:,jj,ii)
            base=th(jj,ii)
            y=var(:,jj,ii)
            var_int(:,jj,ii)=tofloat(ftcurv(x,y,height_array))
            var_int(:,jj,ii)=where(height_array .lt. base, var_int@_FillValue,var_int(:,jj,ii))
        end do
    end do

; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================
  g_fig_name = "fig/Fig4_Ozone_section_"+mon
  wks = gsn_open_wks("png",g_fig_name)  ; open a ps file

  plot = new((/1/),graphic)

  gsn_define_colormap(wks,"rainbow") ; choose a colormap 
;-----------------------------------------------------------------------------
  res                  = True       ; use plot options
  res@gsnFrame         = False
  res@gsnDraw  = False
 
  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels

  res@tmYRMode = "Automatic"
  res@gsnSpreadColors      = True               ; use full color map

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

;  res@gsnMaximize      = True       ; fill up the page
;  res@gsnAddCyclic   = True;False
;  res@gsnPaperOrientation = "portrait"
;  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero

  cn_level=0.005
;  res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
;  res@cnMinLevelValF        = 0          ; set min contour level
;  res@cnMaxLevelValF        = 0.1         ; set max contour level
;  res@cnLevelSpacingF       = cn_level         ; set contour interval

;  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

;  res@gsnMaximize      = True       ; fill up the page
;  res@gsnAddCyclic   = True;False
;  res@gsnPaperOrientation = "portrait"
;  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero
res@gsnLeftString =  left_string
res@gsnRightString = "Ozone (ppb)"
;res@gsnYAxisIrregular2Log = True  
    res@tiYAxisString     = "Height (km)"
  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  ;res@lbLabelStride = 1
;  res@tmXBTickSpacingF = 15
;  res@tmYLTickSpacingF = 15
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = g_font
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = g_font
; res@tmYLLabelFontQuality =

resv                         = True               ; plot mods desired
resv@lbOrientation           = "vertical"         ; vertical label bar
resv@gsnDraw = False
resv@gsnFrame = False
resv@vcRefMagnitudeF         = 5.                ; make vectors larger
resv@vcRefLengthF            = 0.003              ; ref vec length
resv@vcMinDistanceF          = 0.02              ; thin out windbarbs
resv@vcRefAnnoOn             = False              ; turn off ref wind barb
resv@vcGlyphStyle = "lineArrow"

res@tmYLLabelsOn = True
res@tmYLValues = height_array 
res@tmYLLabels = height_array/1000

  h_idx=0
  do ii =0, nbins-1
    if height_array(ii) .gt. max_h then
        h_idx=ii
        break
    end if
  end do
  ;var_section!1="lon"
  ;var_section&lon=lon2d(center_x,0:288)
  res@tmXBMode = "Explicit"
  res@tmXBValues = ispan(0,289,50)
  if method .eq. "WE" then
    var_section=var_int(:h_idx,cor_y,:)
    res@tmXBLabels = round(lon2d(cor_y,::50),0)+"E"
  else
    var_section=var_int(:h_idx,:,cor_x)
    res@tmXBLabels = round(lat2d(::50, cor_x),0)+"E"
  end if



  plot = gsn_csm_contour(wks, var_section, res ) 
  
  ;w_section=u_section
  ;w_section=0.0
  ;plotv = gsn_vector(wks,u_section,w_section,resv)
  ;printVarSummary(u_section)

  ;overlay(plot,plotv)

  draw(plot)
  frame(wks)
 
end

