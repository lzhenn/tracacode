;*************************************************************
;Aim: draw MCA timeseries of SST~Pr 
;     
;Mission:
;   1. Read data from GPCP datasets
;   2. Post-post process to deserved results in diff Region of
;      IO
;   3. Draw the MCA timeseries (BIO only)
;                       Zhenning Li
;                       2014-12-19
;Last Edited:
;   2014-12-19  Create
;*************************************************************


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

;================================================
;Variables List:
;   var2--------------Precpt
;================================================

;initial data


    sst_path   =   "../../../data/sst/monthly/"

    fig_name    =   "../../../fig/IO_paper/fig6_5_mca_timeseries_BIO"
    setfileoption("bin","ReadByteOrder","Native")       ; default

    nyears  =   32
    nt     =   384 
    season  =   "JJA"
    season0 =   "JJA"

    lonL        =   20
    lonR        =   180
    latS        =   -30
    latN        =   60

    global_font = 0.035
    g_thickness = 3.0 
    need_start  =   1979
    need_end    =   2010 ; ERSST only extended to 2010-12

    sst_start  =   12*(need_start-1850) 
    sst_end  =   12*(need_end-1850)+11 
	
    latS_IO    =   (/-30.,  0.,-30.,-15./)
	latN_IO    =   (/ 30., 30.,  0., 15./)
    lonL_IO    =   50.
    lonR_IO    =   110.


	fig_ranks    = (/"f","b","c","d"/)
    fig_titles   = (/"MAM BIO","MAM NIO","MAM SIO","MAM TIO"/)

    sigr    =   0.1
    iflag   =   False   ; population variance similar
; ==============================================================
; Mission 1. Open the file: Read data and merge metadata 
; ==============================================================


;--------------Read SST Out----------------------

;CAMSST
    ctrl_file1   = sst_path+"sst_HadOIBl_bc_0.9x1.25_1850_2012_c130411.nc"
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
    
    TIME   = ctrl_in1->time
    YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
	
    sst_org  = ctrl_in1->SST_cpl(sst_start:sst_end,:,:)			; p for unify the var name
    sst_0    = f2fsh_Wrap(sst_org,(/180,360/)) 
; for land sea mask

    a    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
    lsdata = a->LSMASK
    lsm  = landsea_mask(lsdata,sst_0&lat,sst_0&lon)
    sst = sst_0
    sst = mask(sst_0,lsm.eq.1,False)

; process the ssts, generate seasons mean and EOF 
    printVarSummary(sst)
    sst_season   = month_to_season (sst, season0)
    sst_all_anom = dim_rmvmean_n_Wrap(sst_season, 0)                ; (time, lat,lon)
    
    sst0_season   = month_to_season (sst_0, season0)
    sst0_all_anom = dim_rmvmean_n_Wrap(sst0_season, 0)                ; (time, lat,lon)

    print("sst has been loaded...")

;-----var2 standard netcdf file
    var2_file   = "../../../data/GPCP/precip.mon.mean.nc"
	ctrl_in1     = addfile (var2_file, "r")   ; note the "s" of addfile
	var2        = ctrl_in1->precip(0:nt-1,:,:)



  ;----read var1 var3 var4 from Binary files 
    print("var2, has been loaded...")
    

; ==============================================================
; Mission 2. Set the figure parameters
; ==============================================================


; ==============================================================
; Mission 3. post process the data
; ==============================================================

    nmca = 1 ; how many MCA we need

    season_var2   =   month_to_season(var2,season)
    clim_season_var2    =   dim_avg_n_Wrap(season_var2,0)
    var_season_var2     =  dim_variance_n_Wrap(season_var2,0)


    season_var2_region = season_var2(:,{latS:latN},{lonL:lonR})
    season_var2_region_LLT = season_var2_region(lat|:,lon|:,time|:)
    season_var2_ano = dim_rmvmean_n_Wrap(season_var2_region,0)
    
    var2_region_size = dimsizes(season_var2_ano)
    n_var2_size = var2_region_size(1)*var2_region_size(2)
    homrgt = new((/nmca,n_var2_size/),float)
    hetrgt = new((/nmca,n_var2_size/),float)
    season_var2_ano_line = reshape(season_var2_ano,(/nyears,n_var2_size/))
    season_var2_ano_line!0 = "time" 
    season_var2_ano_line!1 = "pts"

   

   
    do i = 0,0
        
        ;----MCA Here----

        ;----SST Preprocess----
        sst_region_anom = sst_all_anom(:,{latS_IO(i):latN_IO(i)},{lonL_IO:lonR_IO})
        sst0_region_anom = sst0_all_anom(:,{latS_IO(i):latN_IO(i)},{lonL_IO:lonR_IO})
        region_size = dimsizes(sst_region_anom)
        n_sst_size = region_size(1)*region_size(2)
        sst_region_anom_line = reshape(sst_region_anom,(/nyears,n_sst_size/))
        sst_region_anom_line!0 = "time"
        sst_region_anom_line!1 = "pts"
        
        homlft = new((/nmca,n_sst_size/),float)
        hetlft = new((/nmca,n_sst_size/),float)


        ;var2
               
        mca_var2 = svdcov(sst_region_anom_line(pts|:,time|:),season_var2_ano_line(pts|:,time|:),nmca,homlft,hetlft,homrgt,hetrgt) 
        var2_ak   = onedtond(mca_var2@ak,(/nmca,nyears/)) ;timeseries
        var2_bk   = onedtond(mca_var2@bk,(/nmca,nyears/)) ;timeseries
        var2_ak!0 = "sv"
        var2_ak!1 = "time"
        var2_bk!0 = "sv"
        var2_bk!1 = "time"
      
        var2_ak_std=dim_standardize_Wrap(var2_ak,1)
        var2_bk_std=dim_standardize_Wrap(var2_bk,1)
        r = escorc(var2_ak_std(0,:),var2_bk_std(0,:))
        reg_sst = sst0_region_anom(0,:,:)
        reg_sst = (/regCoef(var2_bk_std(0,:), sst0_region_anom(lat|:,lon|:,time|:))/) 

        print("var2 MCA done!") 
        
        if (i .eq. 2) then
            reg_sst = (/-reg_sst/)
        end if
        if (i .eq. 0) then
            reg_sst = (/-reg_sst/)
        end if
        

        delete([/homlft,hetlft,reg_sst/])
        delete([/sst_region_anom,sst_region_anom_line,sst0_region_anom/])

        ;plot_V(i) = gsn_csm_vector(wks,reg_var3,reg_var4,vcres)

        ;overlay(plot_S(i),plot_V(i))
    end do
    
    
    plot_value=new((/2,nyears/),"float")
    plot_value(0,:)=var2_ak_std(0,:)
    plot_value(1,:)=var2_bk_std(0,:)

;**********************************************************************************************
;MISSION.4		Display timeseries 
;**********************************************************************************************



	;************************************************ 
	; plotting parameters
	;************************************************
	wks   = gsn_open_wks ("eps",fig_name)                 ; open workstation

	res               = True                    ; plot mods desired
    ;res@gsnDraw = False
    res@gsnFrame = False
    res@gsnStringFontHeightF = global_font
    res@gsnLeftString = "(f)"        
    res@vpXF     = 0.15

    res@vpWidthF = 0.8
    res@vpHeightF= 0.35


	res@trYMinF            = -3.0                ; Y axis limits
	res@trYMaxF            = 3.0 

	res@trXMinF  = 0                   ; min value on x-axis
	res@trXMaxF  = 31                   ; max value on x-axis
	res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    res@tmYLLabelStride = 2

    ;res@tiYAxisString = "Radiation (W/m2)"
    ;res@tiXAxisString = "Year"
	res@tmXBValues = (/1,11,21,31/) ;interval
	res@tmXBLabels = (/1980,1990,2000,2010/) ;tick label
	res@xyMonoLineColor    = False             ; want colored lines
	res@xyLineColors       = (/"red","blue"/) ; colors chosen
	res@xyLineThicknesses	 = (/g_thickness,g_thickness/)      ; line thicknesses
	res@xyDashPatterns	 = (/0.,0./)      ; make all lines solid
	res@tmXBMajorThicknessF = g_thickness
	res@tmYLMajorThicknessF = g_thickness
	res@tmXBMinorThicknessF = g_thickness
	res@tmYLMinorThicknessF = 0
	res@tmBorderThicknessF = g_thickness
	res@tmXBLabelFontHeightF =global_font
	res@tmYLLabelFontHeightF = global_font
	; Note that a colon is the default function code. We recommend
	; setting default code to be a tilde (~) in your .hluresfile.
	; See: http://www.ncl.ucar.edu/Document/Graphics/hlures.shtml
	;
	;res@tiMainString = fig_title 
    ;res@tiMainFontHeightF = 0.025
    top_plot  = gsn_csm_xy (wks,ispan(0,nyears-1,1),plot_value,res)   ; create plot
    lnres = True
    lnres@gsLineThicknessF = 1.5
    lnres@gsLineColor = "black"
    lnres@gsLineDashPattern = 0 
    gsn_polyline(wks,top_plot,(/0.,nyears-1/),(/0,0/),lnres)
    ;******************************************
    ;Manually create and attach legend
    ;******************************************
  
	res_text                    = True                  ; text mods desired
	res_text@txFontHeightF      = global_font           ; change text size
	res_text@txJust             = "CenterLeft"          ; text justification

	res_lines                   = True                  ; polyline mods desired
	res_lines@gsLineDashPattern = 0.                    ; solid line
	res_lines@gsLineThicknessF  = g_thickness           ; line thicker
	res_lines@gsLineColor       = "red"                 ; line color
	xx = (/15,18/)
	yy = (/1.8,1.8/)
    tex_x = 19
    tex_y = 1.8
	gsn_polyline(wks,top_plot,xx,yy,res_lines)              ; add polyline
	gsn_text(wks,top_plot,"SST",tex_x,tex_y,res_text); add text


	;res_lines@gsLineThicknessF  = 2.                    ; line thicker
	xx = (/23,26/)
    tex_x = 27
	res_lines@gsLineColor       = "blue"                                 ; change to blue
	gsn_polyline(wks,top_plot,xx,yy,res_lines)                ; add polyline
	gsn_text(wks,top_plot,"Pr",tex_x,tex_y,res_text)       ; add text


end
