;*************************************************************
;Aim: draw PRECC annually ltm trend 
;Mission:
;   1. Read data
;   2. Post-post process
;     2.1 take the trend 
;   4. Draw and overlap
;                       Zhenning Li
;                       2015-05-03
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN
;   2015-05-03  Change to caculate season trend 
;   2015-06-20  Change to caculate timeseries
;   2015-06-22  Change to fit multi-data 2 region timeseries
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List:
;	var1--------------PRECC
;================================================
;global variables
    ;Define parameters
    g_data_path1 = "$DATAOBV/20thCRV2/prate.mon.mean.nc";NOAA-CIRES 20th Century Reanalysis version 2
    g_data_path2 ="/home/yangsong3/data/observation/ICOADS2/Enhanced/slp.mean.nc"

    ;MC+WEP
    sea_latS=-5.
    sea_latN=15.
    sea_lonW=85.
    sea_lonE=125.
    
    g_strt_year=1900        
    g_end_year=2010
    g_strt_yyyymm=190001       
    g_end_yyyymm=201012

    g_font = 0.035

    g_fig_name    =   "../fig/Pr_cldc_timeseries_20R-anncyc"
    g_fig_rank    =   (/"","","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(m)","(n)"/)
    
    g_fig_title     = (/"Southern China ","MC+WEP "/)+"ANN Pr Timeseries"
   ;g_fig_title1   =   (/"Mar","Apr","May","Jun","Jul","Aug","Sep"/)+" Pr trend"  ;for dsstdt
   ;g_fig_title2   =   (/"Mar","Apr","May","Jun","Jul","Aug","Sep"/)+" Pr' trend" ;for dsst'dt

    g_seasons=(/"DJF", "JFM", "FMA", "MAM", "AMJ", "MJJ", "JJA", "JAS", "ASO", "SON", "OND", "NDJ"/)
;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	ctrl_file1   = g_data_path1
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
    time = ctrl_in1->time
    yyyymm =floor( cd_calendar(time,-1))
    istrt = ind(yyyymm .eq. g_strt_yyyymm)
    ilast = ind(yyyymm .eq. g_end_yyyymm)
    var1 = ctrl_in1->prate(istrt:ilast,:,:)

    var1=var1*86400
   

    printVarSummary(var1)
    var1_season=month_to_season12(var1)
    printVarSummary(var1_season)
    var1_season_seamean = wgt_areaave_Wrap(var1_season(:,{sea_latS:sea_latN},{sea_lonW:sea_lonE}),1.0,1.0,0)

    nyears=g_end_year-g_strt_year+1
    var1_2d=onedtond(var1_season_seamean,(/nyears,12/))   
    
    nclim=dim_avg_n(var1_2d,0)
    print(nclim)
    ntrend=var1_2d(0,:)
    do ii=0,11
      ntrend(ii)=(/regline(ispan(1,nyears,1),var1_2d(:,ii))*nyears/)
    end do
    ntrend=100*ntrend/nclim
   
    ctrl_file2   = g_data_path2
	ctrl_in2     = addfile (ctrl_file2, "r")   ; note the "s" of addfile
    time := ctrl_in2->time
    yyyymm :=floor( cd_calendar(time,-1))
    istrt = ind(yyyymm .eq. g_strt_yyyymm)
    ilast = ind(yyyymm .eq. g_end_yyyymm)
    var2 = short2flt(ctrl_in2->slp(istrt:ilast,:,:))

    printVarSummary(var2)
    var2_season=month_to_season12(var2)
    printVarSummary(var2_season)
    var2_season_seamean = wgt_areaave_Wrap(var2_season(:,{sea_latS:sea_latN},{sea_lonW:sea_lonE}),1.0,1.0,0)

    nyears=g_end_year-g_strt_year+1
    var2_2d=onedtond(var2_season_seamean,(/nyears,12/))   
    
    nclim:=dim_stddev_n(var2_2d,0)
    print(nclim)
    ntrend2=var2_2d(0,:)
    do ii=0,11
      ntrend2(ii)=(/regline(ispan(1,nyears,1),var2_2d(:,ii))*nyears/)
    end do
    ntrend2=-50*ntrend2/nclim
   

;*********************************
; create plot
;********************************
 wks   = gsn_open_wks ("png", "../fig/bar-20CR-cldc-seasonality" )  ; send graphics to PNG file
 res   = True
; res@gsnScale = True               
 res@gsnFrame= False
; these four resources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

; res@vpXF      = 0.10        ; In page coordinates, where to start
; res@vpYF      = 0.75        ; the plot
 res@vpHeightF = 0.43        ; Changes the aspect ratio
 res@vpWidthF  = 0.85
 res@gsnMaximize = True

 res@trXMinF   = 0        ; min value on y-axis
 res@trXMaxF   =  13        ; max value on y-axis
 res@trYMinF   = 0        ; min value on y-axis
 res@trYMaxF   =  45        ; max value on y-axis

 res@tiYAxisString = "Change (%/100a)" ; y-axis label      
 res@tiXAxisString = ""
 res@tiMainString  = "Change relative to 1901-2010 Clim" ; title

 res@gsnYRefLine           = 0.              ; reference line   
 res@gsnXYBarChart         = True            ; create bar chart 
 ;res@gsnAboveYRefLineColor = "red"           ; above ref line fill red
; res@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue
 res@tmXBMode              = "Explicit"         ; explicit labels
 res@tmXBValues            = ispan(1,12,1)
 res@tmXBLabels            = g_seasons 
 res@gsnXYBarChartBarWidth = 0.25
 res@gsnXYBarChartColors = (/"red"/)   
 plot = gsn_csm_xy (wks,fspan(0.875,11.875,12),ntrend,res) 
 res@gsnXYBarChartColors = (/"blue"/)                  ; but tweaking where
 plot1 = gsn_csm_xy(wks,fspan(1.125,12.125,12),ntrend2,res)        ; Western
 frame(wks)
end


