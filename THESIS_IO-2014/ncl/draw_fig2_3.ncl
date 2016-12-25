;*************************************************************
;Aim: draw IO Basin/NIO/SIO/TIO spring EOF, pattern in fig2_1
;     also fig2_2 (BIO)
;     time series in fig2_3
;
;Mission:
;   1. Read data from CAM SSTs
;   2. Post-post process
;       2.1 Rebuild the data
;       2.2 EOF
;       2.3 Detrend, normalize and regress
;   3. Draw timeseries and overlap shading area
;                       Zhenning Li
;                       2014-11-25
;Last Edited:
;   2014-11-25  Create
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin


;================================================
;Variables List:
;   var1--------------CAM used sst
;================================================

;IO region
; BIO NIO SIO TIO
	latS    =   (/-30.,  0.,-30.,-15./)
	latN    =   (/ 30., 30.,  0., 15./)
    lonL    =   50.
    lonR    =   110.

    exp_code    =   (/"BIO","NIO","SIO","TIO"/)
    fig_num     =   (/"(e)","(f)","(g)","(h)"/)
    data_path   =   "/Users/zhenningli/data/THESIS-IO-2014/"
    fig_name1   =   "../fig/fig2_1_sst_EOF_pattern_2"
    fig_name2   =   "../fig/fig2_2_sst_EOF_timeseries_2"
    
    season      =   "MAM"

    global_font = 0.035
    
    need_start  =   1979
    need_end    =   2011 ; ERSST only extended to 2010-12

    var1_start  =   12*(need_start-1850) 
    var1_end  =   12*(need_end-1850)+11 

    neof   = 1        ; number of EOFs
    optEOF = True       
    optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
;;optEOF@jopt = 1   ; **only** if the correlation EOF is desired

    optETS = False



; ==============================================================
; Mission 1. Open the file: Read sst 
; ==============================================================

;CAMSST
    ctrl_file1   = data_path+"sst_HadOIBl_bc_1.9x2.5_1850_2011_c130301.nc"
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
    var1_0  = ctrl_in1->SST_cpl(var1_start:var1_end,:,:)			; p for unify the var name
    ;var1_0    = f2fsh_Wrap(var1_org,(/180,360/)) 
; for land sea mask
    var1_org = var1_0

    a    = addfile(data_path+"domain.lnd.fv1.9x2.5_gx1v6.090206.nc","r")
    lsdata = a->mask
    var1_0@_FillValue = -999
    var1 = var1_0
    do i = 0,395
        var1(i,:,:) = where(lsdata .eq. 1 ,var1_0@_FillValue, var1(i,:,:))
    end do
; ==============================================================
; Mission 2. process the ssts, generate seasons mean and EOF 
; ==============================================================

    var1_season   = month_to_season (var1, season)
    var1_org_season = month_to_season (var1_0,season)
    nyrs          = need_end - need_start
    var1_all_anom     = dim_rmvmean_n_Wrap(var1_org_season, 0)                ; (time, lat,lon)


; ==============================================================
; Mission 3. Set the figure parameters
; ==============================================================

    ;-----------------------------------------------------------------------------
    wks = gsn_open_wks("eps",fig_name2)  ; open a ps file
    ;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
    ;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

    plot = new((/4/),graphic)
    rts           = True
    rts@gsnDraw   = False       ; don't draw yet
    rts@gsnFrame  = False       ; don't advance frame yet
    rts@gsnScale  = True        ; force text scaling               

    ; these four rtsources allow the user to stretch the plot size, and
    ; decide exactly where on the page to draw it.

    rts@vpHeightF = 0.30        ; Changes the aspect ratio
    rts@vpWidthF  = 0.80
    rts@vpXF      = 0.10        ; change start locations
    rts@vpYF      = 0.75        ; the plot


    rts@tiYAxisString = "Standardized"          ; y-axis label      

    rts@gsnYRefLine           = 0.              ; reference line   
    rts@gsnXYBarChart         = True            ; create bar chart 
    rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
    rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

    rts@trYMinF            = -3.0                 ; Y axis limits
	rts@trYMaxF            = 3.5


    ;rts@tmXBLabelStride     = 1
    rts@tmYLLabelStride     = 2

    rts@tmYLMajorThicknessF = 3.0
    rts@tmXBMinorThicknessF = 3.0
    rts@tmYLMinorThicknessF = 3.0
    rts@tmBorderThicknessF = 3.0

    rts@tmXBLabelFontHeightF = global_font
    rts@tmYLLabelFontHeightF = global_font
    rts@gsnStringFontHeightF = global_font
    rts@tiYAxisFontHeightF   = global_font
    
   
    eof_ts_archive=new((/4,33/),float)
    eof_ts_archive(0,:)=var1_season(:,0,0)
    do n_smp = 0,3
        rts@gsnLeftString = fig_num(n_smp)
        rts@gsnCenterString = exp_code(n_smp)
        var1_season_rg    = var1_season({lat|latS(n_smp):latN(n_smp)},{lon|lonL:lonR},time|:)
        eof    = eofunc_Wrap(var1_season_rg, neof, optEOF)      
        eof_ts = eofunc_ts_Wrap (var1_season_rg, eof, optETS)
        eof_ts = dtrend(eof_ts,False)
        eof_ts = dim_standardize_n(eof_ts, 0, 1)      ; normalize
        ; regress the field
        
        yyyymm = cd_calendar(eof_ts&time,-2)/100  
        YYYY = yyyymm/100
        plot(n_smp) = gsn_csm_xy(wks,YYYY,eof_ts(0,:),rts)
        print(exp_code(n_smp)+"0.7*std="+(/stddev(eof_ts)/) )
        print(eof_ts)

        eof_ts_archive(n_smp,:)=eof_ts(0,:)
        delete(var1_season_rg)
        delete(eof)
        delete(eof_ts)
    end do
    gsn_panel(wks,plot,(/4,1/),False)

    draw(plot)
    frame(wks)
    
    ;---------------archive---------------
    
    system("rm -f ../../../data/sst/sst_IO_EOF_ts.nc")
    ncdf     = addfile("../../../data/sst/sst_IO_EOF_ts.nc" ,"c")  ; open output netCDF file
    
    eof_ts_archive&time@units="years since 1979-01-01"
	; output variables directly
    ncdf->sst_ts=eof_ts_archive

end
