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
    mon_name=(/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)

    g_font=0.025

    fig_title="Resident Time"

    ;Fig name
    g_fig_name="../fig/frequency_restime"
    
    ;File IO
    pdata_fn     = "/Users/zhenningli/data/HKUST-yeq-2016/fwd_traj/res_time_"+mon_name+".nc"  ; open output netCDF file
    ctrl_in = addfiles(pdata_fn ,"r")  ; open output netCDF file
    var1    = ctrl_in[:]->res_time
    
  res                  = True       ; use plot options

  res@gsnFrame         = False
  res@gsnDraw  = False
    
  res@tiMainString="Resident Time Histogram"
  res@gsnMaximize              = True
  ;res@gsnHistogramMinMaxBinsOn = True
  res@tmXBLabelStride                = 2     ; every other x-label
    res@gsnHistogramNumberOfBins = 20
var1_mean=dim_avg_n_Wrap(var1(0:90,:,:),0)
;printVarSummary(var1_mean)
;dims=dimsizes(var1_mean)
;var1_freq=new((/10/),integer)
;var1_freq=0
;do xx=0,dims(0)-1
;    do yy=0,dims(1)-1
;        do ii=0,9
;            if (var1_mean(xx,yy) .ge. ii*2) .and. (var1_mean(xx,yy) .lt. ii*2+2) then 
;                var1_freq(ii)=var1_freq(ii)+1
;            end if
;        end do
;    end do
;end do

var1_1d=ndtooned(var1_mean)
wks = gsn_open_wks("png",g_fig_name)
plot = gsn_histogram(wks,var1_1d,res)


draw(plot)
frame(wks)

end



