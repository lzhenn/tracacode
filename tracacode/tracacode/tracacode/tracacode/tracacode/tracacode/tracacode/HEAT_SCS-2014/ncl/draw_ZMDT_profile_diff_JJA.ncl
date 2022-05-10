;*************************************************************
;Aim: For draw ZMDT (ZM scheme deep-convection) Profile 
;
;Mission:
;   1. Read data from post model datasets
;   2. Post-post process to deserved results 
;   3. Draw the ZMDT Profile
;                       Zhenning Li
;                       2014-11-09
;Last Edited:
;   2014-11-07  Create
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List:
;	var1--------------ZMDT
;================================================

;ESAT ASIA
;	latS   =  -20.
;	latN   =  60. 
;	lonL   =  20.
;	lonR   =  220.
;GLOBAL
	latS   =  0.
	latN   =  30. 
	lonW   =  110.
	lonE   =  150.



; create an array of desired pressure levels:
	season      =   "JJA"
    nsmp        =   20 ;number of samples for significance test

    ctrl_name   =   "HEATCTRL"
	exp_names   =   (/"HEATING","HEATSEN"/)
    year_leap   =   10
    run_period  =   "0001-0030"
	
        
    cp_ctrl_name    =   "B_CON"
    cp_exp_names    =   (/"B_brch"/)
    cp_year_start    =   18 
    cp_year_end      =   48 
    cp_nsmp          =  cp_year_end-cp_year_start
    cp_run_period   =   "0150-0199"
    cp_ctrl_run_period   =   "0150-0199"

    global_font = 0.025

    fig_name    =   "../../fig/Heat_paper/HEAT2_CAM4_profile_ZMDT_JJA"
    fig_title   =   "Latent Heating Rate"

;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	ctrl_file1   = "../../F/post_data/"+ctrl_name+".ZMDT.hybrid.mon."+run_period+".nc"
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	
	ctrl_var3  = ctrl_in1->ZMDT(year_leap*12:,:,:,:)			; p for unify the var name
    ctrl_var3  = ctrl_var3*86400
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================


	ctrl_var3_season = month_to_season(ctrl_var3, season)

	ctrl_var3_season_clim = dim_avg_n_Wrap(ctrl_var3_season,0)

	avg_ctrl_area=wgt_areaave_Wrap(ctrl_var3_season_clim(:,{latS:latN},{lonW:lonE}),1.0,1.0,0)

    y=ctrl_var3_season(:4,:,0,0)
    y(0,:)= (/avg_ctrl_area/)


	do i = 0,dimsizes(exp_names)-1
    ;*************************For F_Compset Heat***********************************

    ; ==============================================================
    ; Mission 1. Open the file: Read only the user specified period
    ; ==============================================================

        exp_file1   = "../../F/post_data/"+exp_names(i)+".ZMDT.hybrid.mon."+run_period+".nc"
        exp_in1     = addfile (exp_file1, "r")   ; note the "s" of addfile
        
        exp_var3  = exp_in1->ZMDT(year_leap*12:,:,:,:)			; p for unify the var name
        exp_var3  = exp_var3*86400    
    ; ==============================================================
    ; Mission 2. post-post process data to deserved results
    ; ==============================================================

        exp_var3_season = month_to_season (exp_var3, season)

        exp_var3_season_clim = dim_avg_n_Wrap(exp_var3_season,0)

	    avg_exp_area=wgt_areaave_Wrap(exp_var3_season_clim(:,{latS:latN},{lonW:lonE}),1.0,1.0,0)
        y(i+1,:)=(/avg_exp_area/)
	end do

;*************************For B_Compset Ctrl***********************************

;; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	cp_ctrl_file1   = "../../couple/post_data/"+cp_ctrl_name+".ZMDT.hybrid.mon."+cp_ctrl_run_period+".nc"
	cp_ctrl_in1     = addfile (cp_ctrl_file1, "r")   ; note the "s" of addfile
	
	cp_ctrl_var3  = cp_ctrl_in1->ZMDT(cp_year_start*12:cp_year_end*12-1,:,:,:)			; p for unify the var name
    cp_ctrl_var3  = cp_ctrl_var3*86400
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================

	cp_ctrl_var3_season = month_to_season (cp_ctrl_var3, season)

	cp_ctrl_var3_season_clim = dim_avg_n_Wrap(cp_ctrl_var3_season,0)

	cp_avg_ctrl_area=wgt_areaave_Wrap(cp_ctrl_var3_season_clim(:,{latS:latN},{lonW:lonE}),1.0,1.0,0)
    
    y(3,:)=(/cp_avg_ctrl_area/)

	do i = 0,dimsizes(cp_exp_names)-1

    ;*************************For B_Compset Heat***********************************

    ; ==============================================================
    ; Mission 1. Open the file: Read only the user specified period
    ; ==============================================================

        cp_exp_file1   = "../../couple/post_data/"+cp_exp_names(i)+"2.ZMDT.hybrid.mon."+cp_run_period+".nc"
        cp_exp_in1     = addfile (cp_exp_file1, "r")   ; note the "s" of addfile
        
        cp_exp_var3  = cp_exp_in1->ZMDT(cp_year_start*12:cp_year_end*12-1,:,:,:)			; p for unify the var name
        cp_exp_var3  = cp_exp_var3*86400    
    ; ==============================================================
    ; Mission 2. post-post process data to deserved results
    ; ==============================================================
        cp_exp_var3_season = month_to_season (cp_exp_var3, season)

        cp_exp_var3_season_clim = dim_avg_n_Wrap(cp_exp_var3_season,0)


	    cp_avg_exp_area=wgt_areaave_Wrap(cp_exp_var3_season_clim(:,{latS:latN},{lonW:lonE}),1.0,1.0,0)
    
        y(4,:)=(/cp_avg_exp_area/)
	end do

        y(:,:8)    =   -999
        y(:,25)    =   0. 
        y_fig       =   y
        y_fig(1,:)  =   y(2,:)  ;SEN
        y_fig(2,:)  =   y(3,:)  ;CP_CON
        y_fig(3,:)  =   y(4,:)  ;CP_HEAT
        y_fig(4,:)  =   y(1,:)  ;HEAT
        y_fig@_FillValue=-999 
        printVarSummary(y)

;--------------------------------figure----------------------------------
        wks = gsn_open_wks("eps",fig_name)           
	

        resxy                   = True                      ; plot mods desired
        resxy@gsnDraw           = False
        resxy@gsnFrame          = False
        
        
        resxy@gsnXRefLine       = 0.0                       ; draw ref line
        resxy@trYReverse        = True                      ; reverse Y-axis
        resxy@xyLineThicknesses = (/2.0,2.0,2.0,4.0,4.0/)           
        resxy@xyLineColors      = (/"red","red","blue","blue","red"/)          ; change line colors
        resxy@xyMonoDashPattern = False
        resxy@xyDashPatterns    = (/1,0,1,2,2/)
        resxy@trYMinF           = 0.0
        resxy@trYMaxF           = 1000.0
        

        ;resxy@pmLegendDisplayMode    = "Always"             ; turn on legend
        ;resxy@xyExplicitLegendLabels = (/"CON","SEN","CP_CON","CP_HEAT","HEAT"/)
        ;resxy@pmLegendSide           = "Top"                ; Change location of 
        ;resxy@pmLegendParallelPosF   = .65                  ; move units right
        ;resxy@pmLegendOrthogonalPosF = -0.35                ; move units down
        ;resxy@lgPerimOn = False
        ;resxy@pmLegendWidthF         = 0.12                   ; Change width and
        ;resxy@pmLegendHeightF        = 0.12                   ; height of legend.
        ;resxy@lgLabelFontHeightF     = .020                    ; change font height

        resxy@gsnStringFontHeightF = 0.025 
        ;resxy@gsnLeftString = "(c)"


        resxy@trXMinF =  -1.  ; axis min
        resxy@trXMaxF =  4.  ; axis min


        plot  = gsn_csm_xy (wks,y_fig,cp_exp_var3&lev,resxy) ; create plot


        resxy@xyMarkLineMode       = "MarkLines"  ; markers and lines
        resxy@xyMarkers            = (/16,16/)           ; filled dot
        resxy@xyMarkerSizeF        = (/0.0135,0.0135/)
        resxy@xyMarkerThicknessF   = (/0.6,0.6/)
        resxy@xyMarkerColors       = (/"blue","red"/)   

        delete(resxy@xyLineColors)
        delete(resxy@xyLineThicknesses)
        delete(resxy@xyDashPatterns)
        resxy@xyDashPatterns = (/2,2/)
        resxy@xyLineColors      = (/"blue","red"/) 
        resxy@xyLineThicknesses = (/4.,4./)  

        plot_h  = gsn_csm_xy (wks,y_fig(3:4,:),cp_exp_var3&lev,resxy) ; create plot


        overlay(plot,plot_h)

;--------------------------------------------------------------------------
  res_lines                   = True                  ; polyline mods desired
  res_lines@gsLineDashPattern = 0.                    ; solid line
  res_lines@gsLineThicknessF  = 2.                    ; line thicker
  res_lines@gsLineColor       = "black"                 ; line color
 
  res_text                    = True                  ; text mods desired
  res_text@txFontHeightF      = 0.02                 ; change text size
  res_text@txJust             = "CenterLeft"          ; text justification
 
 
  res_lines@gsLineColor       = "blue"
  res_lines@gsLineDashPattern = 1.
  yy = (/150.,150./)
  xx = (/2.1,2.6/)
  text_pos = 2.7
  dum5 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
  dum6 = gsn_add_text(wks,plot,"CON_CP",text_pos,150.,res_text); add text
 


  res_lines@gsLineColor       = "blue"
  res_lines@gsLineDashPattern = 2.
  res_lines@gsMarkerColor     = "blue"
  res_lines@gsMarkerIndex     = 16
  res_lines@gsMarkerSizeF     = 0.015
  yy = (/200.,200./)
  dum7 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
  dum8 = gsn_add_text(wks,plot,"HEAT_CP",text_pos,200.,res_text); add text
  dum77 = gsn_add_polymarker(wks,plot,xx,yy,res_lines)   

  res_lines@gsLineColor       = "red"
  res_lines@gsLineDashPattern = 0.
  yy = (/250.,250./)
  dum9 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
  dum10 = gsn_add_text(wks,plot,"SEN",text_pos,250.,res_text); add text


  res_lines@gsLineColor       = "red"
  res_lines@gsLineDashPattern = 1.
  yy = (/300.,300./)
  dum11 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
  dum12 = gsn_add_text(wks,plot,"CON",text_pos,300.,res_text); add text

  res_lines@gsLineColor       = "red"
  res_lines@gsLineDashPattern = 2.
  res_lines@gsMarkerColor     = "red"
  yy = (/350.,350./)
  dum13 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
  dum14 = gsn_add_text(wks,plot,"HEAT",text_pos,350.,res_text); add text
  dum113 = gsn_add_polymarker(wks,plot,xx,yy,res_lines)  




  draw(plot)
  frame(wks)
 
end

