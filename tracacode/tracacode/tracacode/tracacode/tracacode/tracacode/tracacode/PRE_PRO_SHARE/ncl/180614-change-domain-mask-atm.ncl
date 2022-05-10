;************************************************************
;Aim: Regression SST anomaly from TCP_index, and insert these 
;     anomalies to clim SST
;     
;
;Mission:
;   1. Read index data from ascii file, read sst data
;   2. Post process
;       2.1 Regression NINO3
;       2.2 Departure NINO3 signal from Anomaly pattern
;       2.3 Detrend
;       2.4 Regression TCP
;
;   3. Draw patterns 
;   4. Output SST forcing field
;                       Zhenning Li
;                       2015-01-18
;Last Edited:
;   2015-01-18  Create
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin


;================================================
;Variables List:
;   var1--------------CAM used sst
;   index1------------TCP index
;   index2------------NINO3 index
;================================================

;SCS-PhS region
    

	latS    =   -90.0
	latN    =   90.0
    lonL    =   0
    lonR    =   360.
   
    data_file_in   =   "/users/yangsong3/CESM/input/atm/cam/ocnfrac/domain.camocn.1.9x2.5_gx1v6_090403.nc"
    data_file_out   =   "/users/yangsong3/CESM/input/atm/cam/ocnfrac/domain.camocn.1.9x2.5_gx1v6_aqua_180614.nc"
    

;------------------Read clim sst-------------------------------
    ctrl_in1     = addfile (data_file_in, "r")   ; note the "s" of addfile
    var1  = ctrl_in1->mask			; p for unify the var name
    var2  = ctrl_in1->frac			; p for unify the var name

    var1=1
    var2=1.0
    print("*************")

  ncdf     = addfile(data_file_out ,"w")  ; open output netCDF file
  ncdf->mask=var1
  ncdf->frac=var2
end
