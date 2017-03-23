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
load "$NCL_SELFLIB/../shp/cnmap/cnmap.ncl"
;================================================
;Variables List:
;	var1--------------CO2
;	var2--------------CH4
;	var3--------------N2O
;	var4--------------f11
;	var5--------------f12
;================================================



begin
    
    ;grid file
    

    ;Resident time file
   

    ;Fig name
    g_fig_name="../fig/obv/traj_density/"
    
    ;Fig title
    fig_title="Traj density"

    ;
    g_font=0.025
    
    ; Backtrac time file
    n_pts=450

    ; Total integration period in an individual case
    total_int_hrs=96 

    g_latS=-10
    g_latN=45
    g_lonW=130
    g_lonE=60
    
    g_lvl=(/925, 850, 700, 600, 500, 200/)
    
    g_strt_year=1979
    
    ; lat lon data
    data_dir="/Users/zhenningli/data/obv/ERA-daily/uvw/ei.oper.an.pl.regn128sc.2012050900.nc"

    latlon_in   =  addfile(data_dir,"r")
    var = latlon_in->W_GDS4_ISBL(0,:,:)
       
    var=0


  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels



;  i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
;  j = NhlNewColor(wks,1,0.,0.)
;  res@mpLandFillColor       = "gray"            ; set land to be gray

;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)
;    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;    res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
;    res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)

 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = 100          ; set min contour level
 res@cnMaxLevelValF        = 3000          ; set max contour level
 res@cnLevelSpacingF       = 100          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

  res@gsnRightString = ""
  res@gsnStringFontHeightF = 0.03
  res@gsnMaximize      = True       ; fill up the page
  ;res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero
  
  res@cnFillMode           = "CellFill" ; Raster Mode

  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = 0.02              ; make labels smaller
  ;res@lbLabelStride = 1


  ;res@mpMinLatF            = 23       ; zoom in on map
  ;res@mpMaxLatF            = 24
  ;res@mpMinLonF            = 112
  ;res@mpMaxLonF            = 113


  res@mpMinLatF            = g_latS
  res@mpMaxLatF            = g_latN
  res@mpMinLonF            = g_lonE
  res@mpMaxLonF            = g_lonW


  res@mpGeophysicalLineThicknessF = 2.0 ;costal line thick
  res@tmXBTickSpacingF = 15
  res@tmYLTickSpacingF = 15

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


do lvlind=0, dimsizes(g_lvl)-1
    data_file_name1="/Users/zhenningli/data/CAL_SCSSM-2016/back_traj/every-year/pcl-latind-lonind-"+g_lvl(lvlind)+"hPa.nc"
    ;File IO
    ctrl_in = addfile(data_file_name1 ,"r")  ; open output netCDF file
    latid    = ctrl_in->latind
    lonid   = ctrl_in->lonind




    do i_day=-10,-10
        do curr_year= g_strt_year, 2012
           do hr = 0, 95     
                do pos=200,300
                    corx=latid({curr_year}, {i_day}, hr, pos)
                    cory=lonid({curr_year}, {i_day}, hr, pos)
                    var(corx,cory)=(/var(corx,cory)+1/)
                end do
            end do
            print(curr_year+" @ Day"+i_day+" "+g_lvl(lvlind)+"hPa done")
        end do

        wks = gsn_open_wks("png",g_fig_name+"traj-density_"+i_day+"Day"+g_lvl(lvlind)+"hPa")       ; open file to plot 
        gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
        
        res@gsnLeftString = "Day: "+i_day+" @ "+g_lvl(lvlind)+"hPa"
        ;    gsn_reverse_colormap(wks)
        plot = gsn_csm_contour_map(wks,var,res) ; dim1 = 0 for lvl = 0
        draw(plot)
        frame(wks)
        delete([/plot, wks/])
        var=0
    end do
end do 

end




