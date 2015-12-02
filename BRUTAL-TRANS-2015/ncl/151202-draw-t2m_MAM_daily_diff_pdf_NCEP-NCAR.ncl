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
;	t2m--------------Air Temperature (K, TLL)
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_strt_yr=1948
    g_lst_yr=1993

    g_data_path = "/home/yangsong3/data/observation/NCEP_NCAR/daily/air.2m1948-2014/"

    g_font = 0.035

    g_latS=-90.
    g_latN=90.
    g_lonW=0.
    g_lonE=360.
    ; create an array of desired pressure levels:

    g_fig_name    = "dtr_diff_t2m_pdf_NCEP-NCAR"    

    g_fig_title   =  "MAM diff T2M PDF"

;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================


;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

;  plot_sh = new((/1/),graphic)
;  plot_V = new((/2/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")



	;************************************************ 
	; plotting parameters
	;************************************************

	res               = True                    ; plot mods desired

    res@gsnFrame         = False
    res@gsnDraw  = False
             
    res@vpXF     = 0.15

    res@vpWidthF = 0.8
    res@vpHeightF= 0.3


	;res@trYMinF            = 0.9*min(var1_season_scmean)                ; Y axis limits
	;res@trYMaxF            = 1.1*max(var1_season_scmean)

	res@trYMinF            = 1e-5                ; Y axis limits
	res@trYMaxF            = 50 
	res@trXMinF  = -30                   ; min value on x-axis
	res@trXMaxF  = 30                  ; max value on x-axis
	res@xyYStyle     = "Log"
    res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    res@tiYAxisString = "pdf (%)"
	;res@tmXBValues = ispan(0,dimsizes(var1_season_scmean)-1,5) ;interval
	;res@tmXBLabels = ispan(1979,2013,5)         ;tick label
	;res@xyMonoLineColor    = False             ; want colored lines
	;res@xyLineColors       = (/"blue","brown","darkgreen","red","black"/) ; colors chosen
	;res@xyLineThicknesses	 = (/2.0,2.0,2.0,4.0,5.0/)      ; line thicknesses
	;res@xyDashPatterns	 = (/1.,0.,0.,0.,1./)      ; make all lines solid
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
    res@gsnXYBarChart            = True              ; Create bar plot
    res@gsnXYBarChartOutlineOnly = True

    opt=True
    opt@bin_min=-30
    opt@bin_max=30
    opt@bin_nice="nice"
    
    land_in     = addfile ("/home/yangsong3/data/observation/NCEP_NCAR/land_sea_mask/land.nc", "r")   ; note the "s" of addfile
    lsmask  = land_in->land(0,:,:)

    do nyr = g_strt_yr, g_lst_yr
        ;print(nyr+" is processing")
	    wks   = gsn_open_wks ("png","../fig/"+g_fig_name+nyr)                 ; open workstation
        g_strt_day = nyr*10000+3*100+1
        g_lst_day = nyr*10000+5*100+31
        
        ctrl_in1     = addfile (g_data_path+"air.sig995."+nyr+".nc", "r")   ; note the "s" of addfile
        time_hist    = ctrl_in1->time
        yyyymmdd  = cd_calendar(time_hist,-2)
        istrt   = ind(yyyymmdd .eq. g_strt_day)
        ilast   = ind(yyyymmdd .eq. g_lst_day)
        t2m  =ctrl_in1->air(istrt:ilast,:,:)
        lsmask_cfm = conform(t2m,lsmask,(/1,2/))
        t2m  = where(lsmask_cfm .gt. 0.5, t2m, t2m@_FillValue)
        dtr_t2m = t2m 
        ;dtr_t2m = dtrend_n(t2m, False, 0)
        dtr_diff_t2m = dtr_t2m(0:90,:,:)
        dtr_diff_t2m = dtr_t2m(1:91,:,:)-dtr_t2m(0:90,:,:)
        pdf_diff_t2m = pdfx(dtr_diff_t2m(:,{30:60},:),50,opt)
        pdf_diff_t2m@_FillValue=999
        pdf_diff_t2m = where(pdf_diff_t2m .lt. 1e-7, pdf_diff_t2m@_FillValue, pdf_diff_t2m) 
        ;plot
   
        res@gsnCenterString = g_fig_title
        res@gsnLeftString = nyr

        plot =gsn_csm_xy(wks, pdf_diff_t2m@bin_center, pdf_diff_t2m, res) 
        draw(plot)
        frame(wks)
        
        pdf_diff_t2m = where(pdf_diff_t2m@bin_center .gt. -10, pdf_diff_t2m@_FillValue,pdf_diff_t2m)
        print(nyr+":"+sum(pdf_diff_t2m))
        ;clean up
        delete([/wks, plot, time_hist, yyyymmdd/])
    end do
end

