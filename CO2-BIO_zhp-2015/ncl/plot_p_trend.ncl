load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

pfname="../data/model/pre/p_ascii.txt"
tfname="../data/model/pre/t_ascii.txt"

nrow=144
mcol=96


;prob=readAsciiTable(pfname,(/nlat,mlon/),"float",-1)
;tred=readAsciiTable(tfname,(/nlat,mlon/),"float",-1)
dp=asciiread(pfname,(/nrow,mcol/),"float")
dt=asciiread(tfname,(/nrow,mcol/),"float")
dp@_FillValue = -9999.0
dt@_FillValue = -9999.0
nlat=mcol
mlon=nrow

tp=new((/nlat,mlon/),float,dp@_FillValue)
tt=new((/nlat,mlon/),float,dt@_FillValue)

tp=transpose(dp)
tt=transpose(dt)

tp(:,:)=tp(::-1,:)
tt(:,:)=tt(::-1,:)

printVarSummary(tp)
printVarSummary(tt)

printMinMax(tp,True)
printMinMax(tt,True)

rlat=180.0/nlat
rlon=360.0/mlon

lat=new((/nlat/),"float","No_FillValue")
lon=new((/mlon/),"float","No_FillValue")

do i=0,nlat-1
  lat(i) = 90.0 - i* rlat

end do

do i=0,mlon-1
  lon(i) = 0.0 + i*rlon
 
end do

lat!0="lat"
lat@units="degrees_north"
lat@long_name="latitude"

lon!0="lon"
lon@units="degrees_east"
lon@long_name="longitude"

tp!0="lat"
tp!1="lon"
tp&lat=lat
tp&lon=lon
tp@units="%"
tp@long_name="probility"
tp=mask(tp, tp .lt. 0.1, True)

tt!0="lat"
tt!1="lon"
tt&lat=lat
tt&lon=lon
tt@units=""
tt@long_name="trend"

wks=gsn_open_wks("eps","../fig/trend_p")
;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


;-----------------------------------------------------------------------------

res = True
res@gsnDraw     = False
res@gsnFrame    = False

i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
  j = NhlNewColor(wks,1,0.,0.)
;  res@mpLandFillColor       = "gray"            ; set land to be gray

;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)
;    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;    res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
;    res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)

 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = -0.02        ; set min contour level
 res@cnMaxLevelValF        = 0.02          ; set max contour level
 res@cnLevelSpacingF       = 0.0025          ; set contour interval


res@gsnSpreadColors = True
res@gsnSpreadColorStart  = 2               ; start at color 17
res@gsnSpreadColorEnd    = 14                ; end at color 200


res@cnFillOn    =  True
res@cnLinesOn   =  False
;res@cnFillPalette = "BkBlAqGrYeOrReViWh200";"testcmap"
res@cnLineLabelsOn  =  False
res@gsnLeftString   = ""
res@gsnRightString  = ""
res@lbLabelAutoStride = True
res@cnLineLabelsOn   =  False
plot1=gsn_csm_contour_map(wks,tt,res)

res@cnFillOn   = False

;-------------------------------------------------
;-----------------------------------------------------
  res4                  = True       ; use plot options
  res4@cnFillOn         = True       ; Fill contours
  res4@cnLinesOn        = False;True      ; turn off contour lines
  res4@gsnFrame         = False
  res4@gsnDraw  = False
  res4@cnLineLabelsOn   = False      ; turn off contour line labels
  res4@cnLineThicknessF = 2
  res4@cnLineColor      = "black"
  res4@cnInfoLabelOn = False
  res4@cnMonoFillPattern    = True;False
  res4@cnFillPattern = 17
  res4@cnMonoFillScale = True
  res4@cnFillScaleF = 1.
  res4@cnMonoFillColor = True
  res4@cnFillColor  =  "black"
  res4@cnFillDotSizeF = 0.003
 
  res4@lbLabelBarOn = False;True   ; turn off the label bar
 
;  res4@cnLevelSelectionMode="ExplicitLevels"
;  res4@cnLevels = (/3000,1000/)
  res4@gsnLeftString      = ""
  res4@gsnRightString      = ""

plot_sh = gsn_csm_contour(wks,tp,res4)

overlay(plot1,plot_sh)
draw(plot1)
frame(wks)

end
