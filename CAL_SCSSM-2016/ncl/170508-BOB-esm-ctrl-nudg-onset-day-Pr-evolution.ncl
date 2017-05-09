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
load "$NCL_SELFLIB/file_io.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin

;======================================================
;Variables List:
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_var_name = (/"PRECC","PRECL","FLUT"/)
    g_data_ctrl_path ="/Users/zhenningli/data/CAL_SCSSM-2016/ensemble/ctrl"
    g_data_nudg_path ="/Users/zhenningli/data/CAL_SCSSM-2016/nudging_test"

    g_font = 0.025
    
    ;Andaman Sea convection
    g_latS=0.
    g_latN=30.
    g_lonW=70
    g_lonE=120.

    ; create an array of desired pressure levels:
    g_fig_name = "../fig/obv/nudg_rainfall_day"
    g_fig_rank = (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(m)","(n)"/)        
    npos_year = 0
    nneg_year = 0

;Prepare the variables
    ctrl_in_files = systemfunc("ls "+g_data_ctrl_path+"/*ESMc_0*"+g_var_name(2)+"*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in     = addfiles (ctrl_in_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in, "join")
    var  =ctrl_in[:]->$g_var_name(2)$
    var_areamean=wgt_areaave_Wrap(var(:,1:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
 
 
    nudg_in_files = systemfunc("ls "+g_data_nudg_path+"/*ESMn[3-4]*"+g_var_name(2)+"*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    nudg_in     = addfiles (nudg_in_files, "r")   ; note the "s" of addfile
    ListSetType (nudg_in, "join")
    var_nudg  =nudg_in[:]->$g_var_name(2)$
   
    var_nudg_areamean=wgt_areaave_Wrap(var_nudg(:,:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)

    var_mean=dim_avg_n_Wrap(var_areamean,0)  
    var_nudg_mean=dim_avg_n_Wrap(var_nudg_areamean,0)  

    var_onset=var_areamean
    var_nudg_onset=var_nudg_areamean

    day_strt=80
    var_onset_M2J=var_onset(:,day_strt:)
    var_nudg_onset_M2J=var_nudg_onset(:,day_strt:)

    var_onset_M2J=where(var_onset_M2J .lt. 236, 1, 0)
    var_nudg_onset_M2J=where(var_nudg_onset_M2J .lt. 236, 1, 0)
    var_onset_M2J=dim_acumrun_n(var_onset_M2J,6,1,1)
    var_nudg_onset_M2J=dim_acumrun_n(var_nudg_onset_M2J,6,1,1)
    
    dim_esm=dimsizes(var_onset)
    dim_esm:=dim_esm(0)
    

    dim_nudg=dimsizes(var_nudg_onset)
    dim_nudg:=dim_nudg(0)
    
    onset_esm=var_onset(:,0)
    onset_nudg=var_nudg_onset(:,0)

    do ii=0,dim_esm-1
        idate= get1Dindex(var_onset_M2J(ii,:), 6)
        onset_esm(ii)=(day_strt+idate-5)
    end do

    do jj=0, dim_nudg-1
        idate= get1Dindex(var_nudg_onset_M2J(jj,:), 6)
        onset_nudg(jj)=(day_strt+idate-5)
    end do


    ctrl_in_files := systemfunc("ls "+g_data_ctrl_path+"/*ESMc_0*"+g_var_name(0)+"*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in     := addfiles (ctrl_in_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in, "join")
    var  =ctrl_in[:]->$g_var_name(0)$
    
    ctrl_in_files := systemfunc("ls "+g_data_ctrl_path+"/*ESMc_0*"+g_var_name(1)+"*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in     := addfiles (ctrl_in_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in, "join")
    var2  =ctrl_in[:]->$g_var_name(1)$ 

    var=1000*86400*(var+var2)

    nudg_in_files := systemfunc("ls "+g_data_nudg_path+"/*n[3-4]*"+g_var_name(0)+"*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    nudg_in     := addfiles (nudg_in_files, "r")   ; note the "s" of addfile
    ListSetType (nudg_in, "join")
    var_nudg=nudg_in[:]->$g_var_name(0)$

    nudg_in_files := systemfunc("ls "+g_data_nudg_path+"/*n[3-4]*"+g_var_name(1)+"*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    nudg_in     := addfiles (nudg_in_files, "r")   ; note the "s" of addfile
    ListSetType (nudg_in, "join")
    var2_nudg=nudg_in[:]->$g_var_name(1)$
    var_nudg=1000*86400*(var_nudg+var2_nudg)
    
    delete([/var2, var2_nudg/])

    var=runave_n_Wrap(var,3,0,1)
    var_nudg=runave_n_Wrap(var_nudg,3,0,1)

    var_comp=var(:,0:14,:,:)
    var_nudg_comp=var_nudg(:,0:14,:,:)

    dim_onset=dimsizes(onset_nudg)
    do ii=0,dim_onset-1
        onsetday=floattoint(onset_esm(ii))
        var_comp(ii,:,:,:)=var(ii,onsetday-8:onsetday+6,:,:)
        onsetday=floattoint(onset_nudg(ii))
        var_nudg_comp(ii,:,:,:)=var_nudg(ii,onsetday-8:onsetday+6,:,:)
    end do
    
    var_comp:=dim_avg_n_Wrap(var_comp,0)
    var_nudg_comp:=dim_avg_n_Wrap(var_nudg_comp,0)



 wks = gsn_open_wks("png",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")

  plot = new((/8/),graphic)


 res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels

 ; i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
 ; j = NhlNewColor(wks,1,0.,0.)
;  res@mpLandFillColor       = "gray"            ; set land to be gray

;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)
;    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;    res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
;    res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)

 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = 4.0 ; set min contour level
 res@cnMaxLevelValF        = 16.0         ; set max contour level
 res@cnLevelSpacingF       = 1.0         ; set contour interval
 res@mpDataBaseVersion    = "MediumRes"
;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)

  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

  res@gsnMaximize      = True       ; fill up the page
  res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero

  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  ;res@lbLabelStride = 1

  res@mpFillOn   = False     ; turn off gray continents
  res@mpGeophysicalLineThicknessF = 2
  res@mpGeophysicalLineColor      = "black";"white" 
  res@mpFillDrawOrder="PostDraw"
  res@mpCenterLonF = 180.
  res@mpMaxLatF  = g_latN
  res@mpMinLatF  = g_latS
  res@mpMaxLonF  = g_lonE
  res@mpMinLonF  = g_lonW

;  res@mpShapeMode = "FreeAspect" 

;  res@vpWidthF = 0.8
;  res@vpHeightF = 0.6

;  res@tmXBMajorOutwardLengthF = -0.
;  res@tmYLMajorOutwardLengthF = -0.
;  res@tmYRMajorOutwardLengthF = -0.
  
;  res@tmXBMinorOutwardLengthF = -0.
;  res@tmYLMinorOutwardLengthF = -0.
;  res@tmYRMinorOutwardLengthF = -0.
    
     ; now change the size of the tickmark labels
  res@tmXBTickSpacingF = 15
  res@tmYLTickSpacingF = 15
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =
;-----------------------------------------------------------------------------
  res@gsnRightString=""
 
    do ii =0,7
        jj=(ii*2-8)
        res@gsnLeftString=g_fig_rank(ii)
        res@gsnCenterString="Day: "+jj
        plot(ii) = gsn_csm_contour_map_ce(wks,var_nudg_comp(2*ii,:,:),res)
    end do
        gsn_panel(wks,plot,(/4,2/),False)


end
