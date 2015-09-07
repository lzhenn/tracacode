;*************************************************************
;Aim: Take and draw SEN - CON PTENDT diff
;Mission:
;   1. Read data from experiments data
;   2. Post process
;   3. Output the processed data
;   4. Draw PTENDT 2D and Profile figure
;                       Zhenning Li
;                       2015-02-05
;Last Edited:
;   2015-02-05  Create
;*************************************************************


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;global variables
   g_pver = 26
   g_res  = "f19"
   ;Define parameters
   g_data_path = "../data/pre/"+g_res+"/" 
   g_ctrl_case = "historical_force_96-05"
   g_sen_case = "rcp45_force_26-35"
   g_out_fn="../data/pro/f19/PTENDT_DIFF_SCS_pos_mon.bin" ;output filename
   g_fig_name="CAM4_HEATDIFF_PTENDT_takeout_lv20"
   g_fig_name2="CAM4_HEATDIFF_PTENDT_takeout_profile"
   g_fig_title="CAM4 Heat Diff at about 600hPa"

    latS=-30.
    latN=30.
    lonW=0.
    lonE=360.

; ==============================================================
; Mission 1. Open the file: Read data 
; ==============================================================
   all_files = systemfunc ("ls "+g_data_path+g_ctrl_case+"/*cam.h0.000[6-9]*.nc "+g_data_path+g_ctrl_case+"/*cam.h0.00[1-3]*.nc")
   ;all_files = systemfunc ("ls ../HEATCTRL/ctrl_mon/*cam.h0.000[6-7]*.nc")
   setfileoption("nc","SuppressClose",False) ; close too many files

   ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile

   ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)



   all_files2 = systemfunc ("ls "+g_data_path+g_sen_case+"/*cam.h0.000[6-9]*.nc "+g_data_path+g_sen_case+"/*cam.h0.00[1-3]*.nc")
   ;all_files2 = systemfunc ("ls ../HEATSEN/sen_mon/*cam.h0.000[6-7]*.nc")
   setfileoption("nc","SuppressClose",False)

   exp_in      = addfiles (all_files2, "r")   ; note the "s" of addfile

   ListSetType (exp_in, "cat")             ; concatenate or "merge" (default)


; ==============================================================
; Mission 2. Post process CTRL and SEN datasets
; ==============================================================
;------------------Below to change the variable---------------------    
   ctrl_var  = ctrl_in[:]->PTENDT
   exp_var   = exp_in[:]->PTENDT

   avg_ctrl = clmMonTLLL(ctrl_var)
   avg_exp  = clmMonTLLL(exp_var)
   diff_avg_o = avg_ctrl(:,:,{latS:latN},{lonW:lonE})
   diff_avg_o = (avg_exp(:,:,{latS:latN},{lonW:lonE}) - avg_ctrl(:,:,{latS:latN},{lonW:lonE}))
   printVarSummary(diff_avg_o)
   diff_avg = diff_avg_o(month|:,lon|:,lat|:,lev|:) 
   
   ;---------below to get rid of heat<0 points-------
   ;diff_avg=where(diff_avg < 0,0,diff_avg)

    ctrl_var_season = month_to_season (ctrl_var, "JJA")
    exp_var_season = month_to_season (exp_var, "JJA")

	avg_ctrl0 = dim_avg_n_Wrap(ctrl_var_season,0)
    avg_exp0  = dim_avg_n_Wrap(exp_var_season,0)

	avg_ctrl_area=wgt_areaave_Wrap(avg_ctrl0(:,{latS:latN},{lonW:lonE}),1.0,1.0,0)
	avg_exp_area=wgt_areaave_Wrap(avg_exp0(:,{latS:latN},{lonW:lonE}),1.0,1.0,0)

    avg_ctrl_area=where(avg_ctrl_area < 0,0,avg_ctrl_area)
    avg_exp_area=where(avg_exp_area < 0,0,avg_exp_area)



; ==============================================================
; Mission 3. Output the processed data
; ==============================================================

   system("rm -f "+g_out_fn)
   setfileoption("bin","WriteByteOrder","BigEndian") ;bigendian for fortran read
   fbinrecwrite(g_out_fn,-1,diff_avg&lat)
   fbinrecwrite(g_out_fn,-1,diff_avg&lon)
   fbinrecwrite(g_out_fn,-1,diff_avg)
   print(diff_avg(:,{120},{25},19))


; ==============================================================
; Mission 4. Prepare the figure data
; ==============================================================
	wks = gsn_open_wks("eps","../fig/"+g_fig_name)
	gsn_define_colormap(wks,"NCV_blu_red")            ; choose colormap
	;gsn_reverse_colormap(wks)           ; Reverse the color map.
	gsnSpreadColors = True	
	plot = new ( 1 , graphic)

	hres =True
	hres@gsnDraw                  = True
	hres@gsnFrame                 = True
	
	hres@gsnAddCyclic         = False        ; plotted data are not cyclic
	hres@mpFillOn             = False        ; turn off map fill
	hres@mpMinLatF            = latS         ; zoom in on map
	hres@mpMaxLatF            = latN
	hres@mpMinLonF            = lonW
	hres@mpCenterLonF         = 180.
	hres@mpMaxLonF            = lonE
	hres@cnFillOn             = True         ; turn on color fill
	hres@cnLinesOn            = False              ; turn off contour lines
	hres@cnLineLabelsOn       = False              ; turn off line labels
	;hres@gsnRightString   = "m/s & Pa/s" 

	hres@cnLevelSelectionMode     = "ManualLevels"   ; manual contour levels
	hres@cnMinLevelValF           =  -0.05             ; minimum level
	hres@cnMaxLevelValF           =  0.05            ; maximum level
	hres@cnLevelSpacingF          =  0.0025            ; contour spacing
	;hres@lbLabelBarOn        = False           ; turn off individual cb's
	

	;hres@tmXBLabelStride = 2		; For global, = 2

	
	hres@tmXBLabelFontHeightF = 0.025
	hres@tmYLLabelFontHeightF = 0.025
	hres@gsnStringFontHeightF = 0.02
	hres@tiMainFontHeightF= 0.02
  	hres@tmXBMajorThicknessF = 5.0
	hres@tmYLMajorThicknessF = 5.0
	hres@tmXBMinorThicknessF = 4.0
	hres@tmYLMinorThicknessF = 4.0
	hres@tmBorderThicknessF = 4.0
	hres@mpGeophysicalLineThicknessF = 3.5	;costal line thick 4.0 fine for png
	

	hres@gsnLeftString    = "JJA Heating Rate"
	hres@gsnRightString   = "K/kg/s" 


	hres@tiMainString    = g_fig_title
    diff_back = diff_avg(month|:,lev|:,lat|:,lon|:)
    diff_back_JJA = month_to_season(diff_back,"JJA")
    printVarSummary(diff_back_JJA)
    plot = gsn_csm_contour_map(wks,diff_back_JJA(0,19,:,:),hres)	

;--------------------------------figure----------------------------------
    wks1 = gsn_open_wks("eps","../fig/"+g_fig_name2)           


    resxy                   = True                      ; plot mods desired
    resxy@gsnXRefLine       = 0.0                       ; draw ref line
    resxy@trYReverse        = True                      ; reverse Y-axis
    resxy@xyLineThicknesses = (/4.0,4.0/)           
    resxy@xyLineColors      = (/"blue","red"/)          ; change line colors
    resxy@trYMinF           = 0.0
    resxy@trYMaxF           = 1000.0

    resxy@pmLegendDisplayMode    = "Always"             ; turn on legend
    resxy@xyExplicitLegendLabels = (/"CON","SEN"/)
    resxy@pmLegendSide           = "Top"                ; Change location of 
    resxy@pmLegendParallelPosF   = .65                  ; move units right
    resxy@pmLegendOrthogonalPosF = -0.35                ; move units down
    resxy@lgPerimOn = False
    resxy@pmLegendWidthF         = 0.12                   ; Change width and
    resxy@pmLegendHeightF        = 0.12                   ; height of legend.
    resxy@lgLabelFontHeightF     = .020                    ; change font height

    resxy@tiMainString	     = "Vertical Heating Rate Profile (K/kg/s)"

    y = ctrl_var_season(:1,:,0,0)			   ;take out the dimision style
    y(0,:) = (/ avg_ctrl_area /);*86400
    y(1,:) = (/ avg_exp_area /);*86400
    y@long_name = ""
    plt  = gsn_csm_xy (wks1,y,avg_ctrl_area&lev,resxy) 

end








