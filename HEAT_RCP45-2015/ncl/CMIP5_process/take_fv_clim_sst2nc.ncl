;************************************************************
;Aim: read SST from monthly varied, fv forcing data of CAM,
;     caculating the climatological value, put the monthly
;     climatological to a netcdf
;
;Mission:
;   1. Read read sst forcing data
;   2. Post-post process sst (also sea ice) to climatology
;   3. Output SST forcing field
;                       Zhenning Li
;                       2015-01-07
;Last Edited:
;   2015-01-07  Create
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 


;================================================
;Variables List:
;   var1--------------CAM used sst
;   var2--------------CAM used sea ice
;================================================


begin

    res     =   "0.9x1.25"
    ymstrt  =   199601
    ymlast  =   200512 ; ERSST only extended to 2010-12
    
    yrstrt  = floor(ymstrt/100)
    yrlast  = floor(ymlast/100)
    
    data_path   = "../../data/sst/monthly/"
    out_ncdf    = "sst_HadOIBl_bc_"+res+"_"+yrstrt+"_"+yrlast+"_clim.nc"
;**********************************************************************************************
;MISSION.1		Read sst and sea ice from nc file
;**********************************************************************************************

    ctrl_file1   = data_path+"sst_HadOIBl_bc_"+res+"_1850_2012_c130411.nc"
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
 
    time    = ctrl_in1->time
    yyyymm  = cd_calendar(time,-1)
    istrt   = ind(yyyymm .eq. ymstrt)
    ilast   = ind(yyyymm .eq. ymlast)
   
   
    var1    = ctrl_in1->SST_cpl(istrt:ilast,:,:)			
	var1_pre= ctrl_in1->SST_cpl_prediddle(istrt:ilast,:,:)
	var2    = ctrl_in1->ice_cov(istrt:ilast,:,:)
	var2_pre= ctrl_in1->ice_cov_prediddle(istrt:ilast,:,:)
    printVarSummary(var1)
    printVarSummary(time)

;**********************************************************************************************
;MISSION.2		Post process sst and sea ice
;**********************************************************************************************
    clim_var1   = clmMonTLL(var1)
    clim_var1_pre   = clmMonTLL(var1_pre)
    clim_var2   = clmMonTLL(var2)
    clim_var2_pre   = clmMonTLL(var2_pre)

;**********************************************************************************************
;MISSION.3		Write Clim monthly mean to nc file
;**********************************************************************************************

	system("rm "+data_path+out_ncdf)
	ncdf     = addfile(data_path+out_ncdf ,"c")  ; open output netCDF file

	; make time and UNLIMITED dimension      ; recommended  for most applications
	filedimdef(ncdf,"time",-1,True) 

	time0=ctrl_in1->time(istrt:istrt+11)

	; output variables directly
	ncdf->SST_cpl=clim_var1
	ncdf->SST_cpl_prediddle=clim_var1_pre
	ncdf->ice_cov=clim_var2
	ncdf->ice_cov_prediddle=clim_var2_pre
	ncdf->time=time0
end

