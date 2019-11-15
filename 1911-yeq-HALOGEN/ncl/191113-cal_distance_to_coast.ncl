;*****************************************************
;Missions:
;   1. Read ggas data of RCP4.5 forcing field
;   2. Calculate 2026-2035 mean
;   3. Draw the Monthly Timeseries of CO2
;                   Zhenning Li
;                    2015-01-22
;*****************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/disk/hq247/yhuangci/resource/ncl-resource/cnmap-zhenning/cnmap.ncl"
;================================================
;Variables List:
;	var1--------------CO2
;	var2--------------CH4
;	var3--------------N2O
;	var4--------------f11
;	var5--------------f12
;================================================



begin
    
mon="apr"
type="with"

species=(/"CL2","CL","HOCL","CLO","FMCL","HCL","CLNO2","CLNO3","BR","BRO",\
          "HOBR","HBR","BR2","BRNO3","BRNO2","FMBR","CH3BR","MB3","MB2","MB2C",\
          "MBC2","MBC","DMS","MSA","BRCL","I","IO","HI","I2","HOI",\
          "INO","INO2","INO3","OIO","I2O4","I2O2","I2O3","CH3I","ICL","IBR",\
          "MI2","MIB","MIC"/)
;
g_font=0.02


;grid file
grid_fn="/disk/hq247/yhuangci/resource/map_info/research_domains/27km/GRIDCRO2D.27km"
latlon_in   =  addfile(grid_fn,"r")
lat2d = latlon_in->LAT(0,0,:,:)
lon2d = latlon_in->LON(0,0,:,:)

;File IO
ocean_fn=addfile("./ocean_27km_01.ncf","r")
coast_grid=ocean_fn->OPEN(0,0,:,:)
dis_coast_grid=coast_grid
dis_coast_grid@units=1
dis_coast_grid@var_desc="nearest distance to the coast, negative on land, positive on ocean"
dis_coast_grid@long_name="nearest distance to the coast, negative on land, positive on ocean"
printVarSummary(dis_coast_grid)
dims = dimsizes(coast_grid)
nx=dims(0)
ny=dims(1)

; maximum search radius
rmax=nx/2



; cal the distance of grid to coastal grid
do ii=0,nx-1
    do jj=0,ny-1

        tgt_grid=coast_grid(ii,jj)
        if ((tgt_grid-0) .lt. 1e-5) then
            tgt_grid=-1
        else if (abs(tgt_grid-1) .lt. 1e-5) then
            tgt_grid=1
        else
            tgt_grid=0
        end if
        end if
        
        if (.not.(tgt_grid .eq. 0)) then
            find_flag=False
            do ir = 1, rmax
                do ix=0, nx-1
                    do jy=0, ny-1
                        if (ix-ii)^2+(jy-jj)^2 .lt. ir^2 then
                            if (coast_grid(ix,jy) .gt. 0) .and. (coast_grid(ix,jy) .lt. 1) then
                                print(ii+","+jj+"-->"+ix+","+jy)
                                dis_coast_grid(ii,jj)=ir*tgt_grid
                                find_flag=True
                            end if
                        end if
                        if find_flag then
                            break
                        end if
                    end do
                    if find_flag then
                        break
                    end if
                end do
                if find_flag then
                    break
                end if
            end do
        end if
    end do
end do

out_fn=addfile("./dis_to_coast_27km.ncf","r")
out_fn->dis_to_coast=dis_coast_grid
exit





  g_fig_name="./temp_marine"
  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels


 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = -5          ; set min contour level
 res@cnMaxLevelValF        = 5           ; set max contour level
 res@cnLevelSpacingF       = 0.5         ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

  res@gsnRightString = ""
  res@gsnMaximize      = True       ; fill up the page
  res@gsnAddCyclic   = False
  res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero
  
  ;res@cnFillMode           = "CellFill" ; Raster Mode

  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = 0.02              ; make labels smaller
  ;res@lbLabelStride = 1


  ;res@mpMinLatF            = 23       ; zoom in on map
  ;res@mpMaxLatF            = 24
  ;res@mpMinLonF            = 112
  ;res@mpMaxLonF            = 113
  
  res@gsnScale = True
  res@mpMinLatF            = min(lat2d)        ; zoom in on map
  res@mpMaxLatF            = max(lat2d)
  res@mpMinLonF            = min(lon2d)
  res@mpMaxLonF            = max(lon2d)

  res@mpGeophysicalLineThicknessF = 2.0 ;coastal line thick
  res@tmXBTickSpacingF = 2
  res@tmYLTickSpacingF = 2

res@tmXBLabelFontHeightF =g_font
res@tmYLLabelFontHeightF = g_font
res@gsnStringFontHeightF = g_font
res@tiMainFontHeightF= g_font
;res@lbLabelFontHeightF = 0.02
;res@pmLabelBarOrthogonalPosF = .12           ; move label bar down
res@tmXBMajorThicknessF = 2.0
res@tmYLMajorThicknessF = 2.0
res@tmXBMinorThicknessF = 2.0
res@tmYLMinorThicknessF = 2.0
res@tmBorderThicknessF = 2.0
res@tmYLMajorLengthF = 0.002

res@mpFillOn                = True
res@mpOutlineOn             = True  ; Use outlines from shapefile
;res@cnFillDrawOrder         = "PreDraw"
res@mpDataBaseVersion       = "MediumRes"
res@mpDataSetName           = "Earth..4"
res@mpAreaMaskingOn         = True
res@mpMaskAreaSpecifiers    = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
res@mpLandFillColor         = "white"
res@mpInlandWaterFillColor  = "white"
;res@mpOceanFillColor        = "white"
;res@mpOutlineBoundarySets   = "NoBoundaries"
;                      add China map
;>------------------------------------------------------------<
  cnres           = True
  cnres@china     = False       ;draw china map or not
  cnres@river     = False       ;draw changjiang&huanghe or not
  cnres@province  = True       ;draw province boundary or notcnres@nanhai    = False       ;draw nanhai or not 
  cnres@nanhai    = False       ;draw nanhai or not 
  cnres@diqu      = False       ; draw diqujie or not

    wks = gsn_open_wks("png",g_fig_name)       ; open file to plot 
    ;gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
    ;gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
    gsn_define_colormap(wks,"BlRe")
    res@gsnCenterString=""
    res@gsnLeftString=""
    res@gsnRightString="Jul"
;    gsn_reverse_colormap(wks)
    plot = gsn_csm_contour_map(wks,var_mean,res) ; dim1 = 0 for lvl = 0
    chinamap = add_china_map(wks,plot,cnres)
    draw(plot)
    frame(wks)



end




