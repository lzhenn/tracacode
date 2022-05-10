;***********************************************************;
;                                                           ;
;  This script is a example to plot contours on China map.  ;
;  Written by Liu Pei(CUIT) and Huang Yongjie(IAP/CAS)      ;
;  DEC 19, 2012.                                            ;
;                                                           ;
;***********************************************************;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/cnmap/cnmap.ncl"

begin

   f=addfile("pres.mon.ltm.nc","r")
   pres= f->pres(0,:,:) 

;>=========================================================<
 wks       = gsn_open_wks("png","china_boundary") 
 gsn_define_colormap( wks ,"gui_default")  
 
        
 res                         = True            
 res@tiMainString            ="china_map" 
 res@gsnMaximize             = True
 res@gsnDraw                 = False
 res@gsnFrame                = False

;>--------------------------------------------<
;            set for the map 
;>--------------------------------------------<
 res@mpMinLatF               = 21.5                         
 res@mpMaxLatF               = 24
 res@mpMinLonF               = 112.
 res@mpMaxLonF               = 115.

 res@mpFillOn                = True
 res@mpOutlineOn             = False  ; Use outlines from shapefile
 res@cnFillDrawOrder         = "PreDraw"
 res@mpDataBaseVersion       = "MediumRes"
 res@mpDataSetName           = "Earth..4"
 res@mpAreaMaskingOn         = True
 res@mpMaskAreaSpecifiers    = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
 res@mpLandFillColor         = "white"
 res@mpInlandWaterFillColor  = "white"
 res@mpOceanFillColor        = "white"
; res@mpOutlineBoundarySets   = "NoBoundaries"
;>--------------------------------------------<
; set for the plot

 res@cnFillOn                = True               
 res@cnLinesOn               = False             
 res@cnLevelSpacingF         = 20.             
 res@gsnSpreadColors         = True         
 res@lbLabelAutoStride       = True               
 map=gsn_csm_contour_map(wks,pres,res) 

;>============================================================<
;                      add China map
;>------------------------------------------------------------<
 cnres           = True
 cnres@china     = False       ;draw china map or not
 cnres@river     = False       ;draw changjiang&huanghe or not
 cnres@province  = True       ;draw province boundary or not
 cnres@nanhai    = False       ;draw nanhai or not 
 cnres@diqu      = True       ; draw diqujie or not

 chinamap = add_china_map(wks,map,cnres)
;>============================================================<

draw(map)
frame(wks)
end  
