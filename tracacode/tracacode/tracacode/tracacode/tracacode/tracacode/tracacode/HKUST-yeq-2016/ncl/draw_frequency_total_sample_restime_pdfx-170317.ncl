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
    ;mon_name=(/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
    mon_name=(/"Mar","Apr","May"/)
   ; mon_name=(/"Jun","Jul","Aug"/)
    ;mon_name=(/"Sep","Oct","Nov"/)
    ;mon_name=(/"Jan","Feb","Dec"/)

    g_font=0.025

    fig_title="Resident Time"

    ;Fig name
    g_fig_name="../fig/frequency_restime-all-"+mon_name(0)+mon_name(1)+mon_name(2)
    
    ;File IO
    pdata_fn     = "/Users/zhenningli/data/HKUST-yeq-2016/fwd_traj/res_time_"+mon_name+".nc"  ; open output netCDF file
    ctrl_in = addfiles(pdata_fn ,"r")  ; open output netCDF file
    var1    = ctrl_in[:]->res_time


    opt=True
    opt@bin_min=0
    opt@bin_max=120
    opt@bin_nice="nice"
    
    nbars= 120
    pdf_var1 = pdfx(var1,nbars,opt)
    res                       = True                 ; plot mods desired         
    res@gsnDraw               = False
    res@gsnFrame              = False                ; don't advance frame yet
    res@gsnXYBarChart         = True                 ; turn on bar chart
    res@tiYAxisString = "pdf (%)"
    res@xyYStyle     = "Log"
    res@gsnYRefLine           = 0.              ; reference line   
    res@gsnAboveYRefLineColor = "blue"           ; above ref line fill red
    res@tmXBMode      = "Explicit" ; Define own tick mark labels. 
    res@tmXBValues=ispan(0,nbars,10)
    res@tmXBLabels=ispan(0,nbars,10)
    res@trYMinF            = 1e-5                ; Y axis limits   
    ;res@gsnXYBarChartBarWidth = 0.75                 ; change bar widths
    rgba  = span_color_indexes("matlab_jet",nbars)
    res@gsnXYBarChartColors = rgba
    res@tiXAxisString = "Resident Time" 
     wks = gsn_open_wks("png",g_fig_name)
    gsn_define_colormap(wks,"matlab_jet")
    pdf_var1@_FillValue=999
    pdf_var1=where(pdf_var1 .lt. 1e-5, pdf_var1@_FillValue,pdf_var1)
    print(pdf_var1)
    plot = gsn_csm_xy(wks,pdf_var1@bin_center,pdf_var1,res)

    draw(plot)
    frame(wks)

    dimvar1=dimsizes(var1)
    length=dimvar1(0)*dimvar1(1)*dimvar1(2)
    th_hr=15
    print("-----------------------------------")
    print("Average Resident Time more than "+th_hr+"hr: "+100*num(var1 .gt.th_hr)/length+"% in total")
    print("-----------------------------------")

end



