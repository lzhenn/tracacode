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

;================================================
;Variables List:
;	var1--------------CO2
;	var2--------------CH4
;	var3--------------N2O
;	var4--------------f11
;	var5--------------f12
;================================================



begin
    data_file_name1="/home/yangsong3/L_Zealot/data-mirror/data-model/CESM_CTRL/B2000_F19G16_CAM4_CTRL/spun-up-pro/B20f19-spun-up.cam.h0.TS.250-299.nc"
    fig_title="NINO3.4 INDEX Timeseries"
    
    ;one month rightward shift
    yrstrt1  = 25002
    yrlast1  = 30001

    ;NINO3.4 region
    g_lonW = 190
    g_lonE = 240
    g_latS = -5
    g_latN = 5
    g_font = 0.02
;---------------Read data-------------------
    ctrl_in1 = addfile(data_file_name1,"r")
    time = ctrl_in1->time
    yyyymm =floor( cd_calendar(time,-1))
    ;yyyymm = array_append_record (101., yyyymm0, 0)
    istrt = ind(yyyymm .eq. yrstrt1)
    ilast = ind(yyyymm .eq. yrlast1)
    ctrl_var1 = ctrl_in1->TS(istrt:ilast,:,:)
   
   ;--------------Proprocessing-----------
    ctrl_nino34 = wgt_areaave_Wrap(ctrl_var1(:,{g_latS:g_latN},{g_lonW:g_lonE}), 1.0, 1.0, 0)
    ctrl_rmean_nino34 = runave_Wrap(ctrl_nino34,3,0)
    ctrl_nino34_idx = rmAnnCycle1D(ctrl_rmean_nino34)
    print(yyyymm(istrt:ilast)+": "+ctrl_nino34_idx(:))
    
    
   print (yyyymm(istrt:ilast)+" CTRL:"+ctrl_nino34_idx)

end




