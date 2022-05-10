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

begin


    g_data3_path ="/users/yangsong3/L_Zealot/F/DATA_Nudging/pro"
    g_font=0.02
    g_latS=-90.
    g_latN=90.
    g_lonW=0.
    g_lonE=360.
    g_level=200

    g_var_name:=(/"T"/)
    ctrl_in_files1 = systemfunc("ls "+g_data3_path+"/*ESMn*."+g_var_name(0)+".*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in1     = addfiles (ctrl_in_files1, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in1, "join")
    var1  =ctrl_in1[:]->$g_var_name(0)$(:,75:120,{150:1000},:,:)
    delete(ctrl_in1)
    clim_var1=dim_avg_n_Wrap(var1, 0)
    delete(var1)
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

;  plot_sh = new((/g_day_comp_len/),graphic)
;  plot_V = new((/g_day_comp_len/),graphic)
;  plot_cn_max = new((/g_day_comp_len/),graphic)
;  plot_cn_max_pre = new((/g_day_comp_len/),graphic)
;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)
;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")


;-----------------------------------------------------------------------------
;************************************************
; High Efficiency to Write the file
;************************************************
    print("Output...")

    output_fn="../data/Nudging_clim_"+g_var_name(0)+".nc"


    write_TLLL_to_nc(g_var_name(0),clim_var1,output_fn)



end
