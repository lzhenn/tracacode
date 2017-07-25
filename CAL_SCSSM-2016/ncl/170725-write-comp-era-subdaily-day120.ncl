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


;======================================================
;Variables List:
;	t2m--------------Air Temperature (K, TLL)
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    origin_dir="/Users/zhenningli/data/obv/ERA-daily/uvw/"
    output_fn="/Users/zhenningli/data/CAL_SCSSM-2016/onset_comp_uvw/early/cmp_uvw.nc"
    ;SCS
    ;g_day_rank=(/135,140,150,155,145,140,150,135,160,145,160,140,160,140,150,125,135,130,140,140,150,135,130,135,145,140,150,140,145,125,150,145,130,140/)
    
    ;BOB
    
    g_strt_yr=1979
    g_lst_yr=2012
    g_yr_len = g_lst_yr-g_strt_yr+1
 
    ;BOB test
    ;g_comp="all"
    ;g_special_year=ispan(g_strt_yr,1980,1)
    ;g_day_rank=(/125,136/)


    
    ;BOB All
    ;g_comp="all"
    ;g_special_year=ispan(g_strt_yr,g_lst_yr,1)
    ;g_day_rank=(/125,136,133,134,143,108,136,123,119,119,128,105,110,132,134,114,126,112,133,132,93,100,115,114,127,118,123,107,116,112,99,134,113,119,123/)

    
    ;BOB Early
    g_comp="early"
    g_special_year=(/1984, 1990, 1999, 2000, 2006, 2009/)
    g_day_rank=(/108, 105, 93, 100, 107, 99/)
    
    ;BOB Late
    ;g_comp="late"
    ;g_special_year=(/1980, 1981, 1982, 1983, 1985, 1992, 1993, 1997, 1998, 2010/)
    ;g_day_rank=(/136, 133, 134, 143, 136, 132, 134, 133, 132, 134/)

    p_lvl=37
    g_special_cases=dimsizes(g_day_rank)
    jj=0
    print("Year: "+g_special_year(jj))    
    yyyymmddhh_list = yyyymmddhh_time(g_special_year(jj), g_lst_yr, 6, "integer")  
    yyyymmdd_strt=yyyyddd_to_yyyymmdd(g_special_year(jj)*1000+g_day_rank(jj)-14)
    yyyymmdd_end=yyyyddd_to_yyyymmdd(g_special_year(jj)*1000+g_day_rank(jj)+9)
    parser_time=yyyymmddhh_list({yyyymmdd_strt*100:yyyymmdd_end*100})
    all_files = origin_dir+"ei.oper.an.pl.regn128uv."+parser_time+".nc"; ../"+case_name+"/"+exedir+"/*cam.h0.002[0-4]*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in, "join")             ; concatenate or "merge" (default)
    ctrl_var1 = ctrl_in[:]->U_GDS4_ISBL
    ctrl_var2 = ctrl_in[:]->V_GDS4_ISBL

    all_files = origin_dir+"ei.oper.an.pl.regn128sc."+parser_time+".nc"; ../"+case_name+"/"+exedir+"/*cam.h0.002[0-4]*")
    ctrl_in2      = addfiles (all_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in2, "join")             ; concatenate or "merge" (default)
    ctrl_var3 = ctrl_in2[:]->W_GDS4_ISBL
    jj=jj+1
    do ii=1,g_yr_len-1
        if (ii+g_strt_yr) .eq. g_special_year(jj) then
            print("Year: "+g_special_year(jj))    
            yyyymmdd_strt=yyyyddd_to_yyyymmdd(g_special_year(jj)*1000+g_day_rank(jj)-14)
            yyyymmdd_end=yyyyddd_to_yyyymmdd(g_special_year(jj)*1000+g_day_rank(jj)+9)
            parser_time=yyyymmddhh_list({yyyymmdd_strt*100:yyyymmdd_end*100})
            all_files = origin_dir+"ei.oper.an.pl.regn128uv."+parser_time+".nc"; ../"+case_name+"/"+exedir+"/*cam.h0.002[0-4]*")
            setfileoption("nc","SuppressClose",False) ; close too many files
            ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
            ctrl_var1= ctrl_var1+ ctrl_in[:]->U_GDS4_ISBL
            ctrl_var2 =ctrl_var2+ ctrl_in[:]->V_GDS4_ISBL
            all_files = origin_dir+"ei.oper.an.pl.regn128sc."+parser_time+".nc"; ../"+case_name+"/"+exedir+"/*cam.h0.002[0-4]*")
            ctrl_in2      = addfiles (all_files, "r")   ; note the "s" of addfile
            ctrl_var3 = ctrl_var3+ctrl_in2[:]->W_GDS4_ISBL
            
            jj=jj+1
            if jj .eq. g_special_cases
                break
            end if
        end if
    end do
    
    
    ctrl_var1=(/ctrl_var1/g_special_cases/)
    ctrl_var2=(/ctrl_var2/g_special_cases/)
    ctrl_var3=(/ctrl_var3/g_special_cases/)
    
    ctrl_var1!0="time"
    ctrl_var1!1="lev"
    ctrl_var1!2="lat"
    ctrl_var1!3="lon"

    dims=dimsizes(ctrl_var1)
    ntime=dims(0)
    nlat=dims(2)
    nlon=dims(3)

    ctrl_var1&time=ispan(0,(ntime-1)*6,6)
    ctrl_var1&time@units="hours since 0001-01-01 00:00:0.0"
    copy_VarMeta(ctrl_var1, ctrl_var2)
    copy_VarMeta(ctrl_var1, ctrl_var3)
    printVarSummary(ctrl_var1)
    printVarSummary(ctrl_var2)
    printVarSummary(ctrl_var3)
    

;************************************************
; High Efficiency to Write the file
;************************************************
    print("Output...")
;Get dimsize

    
;Set fileoption    
    system("rm "+output_fn)
    fout = addfile(output_fn ,"c")  ; open output netCDF file
    setfileoption(fout,"DefineMode",True)

;Set All field attribution
    fileAtt     = True
    fileAtt@creation_date=systemfunc("date")
    fileattdef(fout,fileAtt)

;Define Coordinate
    dimNames    =(/"time","lev","lat","lon"/)
    dimSizes    =(/-1,p_lvl,nlat,nlon/)
    dimUnlim    =(/True,False,False,False/)
    filedimdef(fout,dimNames,dimSizes,dimUnlim)

;Define var, type and dim
    filevardef(fout,"time",typeof(ctrl_var1&time),getvardims(ctrl_var1&time))
    filevardef(fout,"lev",typeof(ctrl_var1&lev),getvardims(ctrl_var1&lev))
    filevardef(fout,"lat",typeof(ctrl_var1&lat),getvardims(ctrl_var1&lat))
    filevardef(fout,"lon",typeof(ctrl_var1&lon),getvardims(ctrl_var1&lon))
    filevardef(fout,"uwnd",typeof(ctrl_var1),getvardims(ctrl_var1))
    filevardef(fout,"vwnd",typeof(ctrl_var2),getvardims(ctrl_var2))
    filevardef(fout,"vv",typeof(ctrl_var3),getvardims(ctrl_var3))

;Define Attribute
    filevarattdef(fout,"uwnd",ctrl_var1)
    filevarattdef(fout,"vwnd",ctrl_var2)
    filevarattdef(fout,"vv",ctrl_var3)
    
    fout->time=(/ctrl_var1&time/)
    fout->lev=(/ctrl_var1&lev/)
    fout->lat=(/ctrl_var1&lat/)
    fout->lon=(/ctrl_var1&lon/)
    fout->uwnd=(/ctrl_var1/)
    fout->vwnd=(/ctrl_var2/)
    fout->vv=(/ctrl_var3/)

end

