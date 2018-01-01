;*****************************************************
;Missions:
;   1. Read NINO3.4 SST from observation
;   2. Calculate the NINO3.4 index
;   3. Draw the Monthly Timeseries
;                   Zhenning Li
;                    2016-01-08
;*****************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;================================================
;Variables List:
;	var1--------------SST
;================================================



begin

    data_file_name1="../data/obv/SST/HadISST_sst-187001-201510.nc"
    
    fig_title="NINO3.4 INDEX Timeseries"
    
    yrstrt  = 195001 
    yrlast  = 201412


    fig_name="../fig/NINO34-Hadley-"+yrstrt+"-"+yrlast


;**********************************************************************************************
;MISSION.1	 Read data
;**********************************************************************************************


    ctrl_in1 = addfile(data_file_name1,"r")
    
    time = ctrl_in1->time
    
    yyyymm =floor( cd_calendar(time,-1))
    istrt = ind(yyyymm .eq. yrstrt)
    ilast = ind(yyyymm .eq. yrlast)
   
    delete(yyyymm)
    t    = time(istrt:ilast) 
    yyyy =floor( cd_calendar(t,4))
    ctrl_var1 = ctrl_in1->sst(istrt:ilast,:,:)
;**********************************************************************************************
;MISSION.2	 Post process
;**********************************************************************************************

    printVarSummary(ctrl_var1)
;--------------Proprocessing-----------
    ctrl_nino34 = wgt_areaave(ctrl_var1(:,{-5:5},{-170:-120}), 1.0, 1.0, 0)
    ctrl_rmean_nino34 = runave_Wrap(ctrl_nino34,3,0)
    ctrl_nino34_idx = rmAnnCycle1D(ctrl_rmean_nino34)
    print(ctrl_nino34_idx)
;**********************************************************************************************
;MISSION.3		Display timeseries 
;**********************************************************************************************



	;************************************************ 
	; plotting parameters
	;************************************************
	wks   = gsn_open_wks ("eps",fig_name)                 ; open workstation

	res               = True                    ; plot mods desired

             
    res@vpXF     = 0.15

    res@vpWidthF = 0.8
    res@vpHeightF= 0.3


	res@trYMinF            = min(ctrl_nino34_idx)-0.5                ; Y axis limits
	res@trYMaxF            = max(ctrl_nino34_idx)+0.5

    res@gsnCenterString = fig_title
	res@trXMinF  = 1                   ; min value on x-axis
	res@trXMaxF  = dimsizes(ctrl_nino34_idx)                   ; max value on x-axis
	res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    res@tiXAxisString = "Year"
	res@tmXBValues = ispan(1, 780, 120) ;interval
	res@tmXBLabels = ispan(1950,2014,10)         ;tick label
	res@xyMonoLineColor    = False             ; want colored lines
	res@xyLineColors       = (/"blue"/) ; colors chosen
	res@xyLineThicknesses	 = (/4.0/)      ; line thicknesses
	res@xyDashPatterns	 = (/0./)      ; make all lines solid
	res@tmXBMajorThicknessF = 5.0
	res@tmYLMajorThicknessF = 5.0
	res@tmXBMinorThicknessF = 4.0
	res@tmYLMinorThicknessF = 4.0
	res@tmBorderThicknessF = 4.0
	res@tmXBLabelFontHeightF =0.022
	res@tmYLLabelFontHeightF = 0.022
	; Note that a colon is the default function code. We recommend
	; setting default code to be a tilde (~) in your .hluresfile.
	; See: http://www.ncl.ucar.edu/Document/Graphics/hlures.shtml
	;
	 top_plot  = gsn_csm_xy (wks,ispan(1,780,1),ctrl_nino34_idx,res)   ; create plot
end




