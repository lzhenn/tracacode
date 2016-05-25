;*************************************************************
;Aim: draw OLR annually ltm trend 
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
;   2015-07-09  Change to caculate OLR
;   2015-07-09  Change to fit composite
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List:
;	var1--------------U
;	var2--------------V
;================================================
;global variables
    ;Define parameters
    g_data_path1 = "../data/obv/ERA-Interim/U-197901-201408.nc"
    g_data_path2 = "../data/obv/ERA-Interim/V-197901-201408.nc"

;Indian and Pacific
    g_latS=-45.
    g_latN=45.
    g_lonW=30.
    g_lonE=220.
    
; Western Equatorial Pacific    
;    g_latS=-15.
;    g_latN=15.
;    g_lonW=140.
;    g_lonE=180.

    
    g_season_rank=(/"DJF","MAM","JJA","SON"/)
; create an array of desired pressure levels:

        
    g_font = 0.035

    g_strt_mon = 197901 
    g_lst_mon = 201312
    
    ;g_sp_events = (/198101,199001,199601,200101/)
    ;g_su_events = (/198501,199301,200301,200501,200801/)
    
    g_sp_events = (/198201,199101,199701,200201/)
    g_su_events = (/198601,199401,200401,200601,200901/)
    n_sp_events= dimsizes(g_sp_events)
    n_su_events= dimsizes(g_su_events)
    g_fig_name    =   "../fig/"+g_strt_mon+"-"+g_lst_mon+"_lowUV_curl_cmp_ts"
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(m)","(n)"/)
    
    g_fig_title     = "Timeseries of W Index"

    ;g_fig_title     = (/"Jan","Feb","Mar","Apr","May","Jun"/)+"(0) 1000UV & Curl"

;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	ctrl_file1   = g_data_path1
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	time_hist    = ctrl_in1->time
    yyyymm  = cd_calendar(time_hist,-1)
    istrt   = ind(yyyymm .eq. g_strt_mon)
    ilast   = ind(yyyymm .eq. g_lst_mon)
	var1  =short2flt(ctrl_in1->u(istrt:ilast,{1000},:,:))			; p for unify the var name

    ctrl_file2   = g_data_path2
	ctrl_in2     = addfile (ctrl_file2, "r")   ; note the "s" of addfile
	var2  =short2flt(ctrl_in2->v(istrt:ilast,{1000},:,:))			; p for unify the var name

; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================
    cmp_var1 = var1(0:11,:,:)
    cmp_var1 = 0
    do ii=0,n_sp_events-1
        i_evstrt= ind(yyyymm .eq. g_sp_events(ii)) - istrt
        print(i_evstrt)
        cmp_var1 = cmp_var1+var1(i_evstrt:i_evstrt+11,:,:)
    end do
    cmp_var1 =cmp_var1/n_sp_events
    clm_var1 = clmMonTLL(var1)
    ano_cmp_var1 = calcMonAnomTLL(cmp_var1,clm_var1)


    cmp_var2 = var2(0:11,:,:)
    cmp_var2 = 0
    do ii=0,n_sp_events-1
        i_evstrt= ind(yyyymm .eq. g_sp_events(ii)) - istrt
        cmp_var2 = cmp_var2+var2(i_evstrt:i_evstrt+11,:,:)
    end do
    cmp_var2 =cmp_var2/n_sp_events
    clm_var2 = clmMonTLL(var2)
    ano_cmp_var2 = calcMonAnomTLL(cmp_var2,clm_var2)


    cmp_var1_su = var1(0:11,:,:)
    cmp_var1_su = 0
    do ii=0,n_su_events-1
        i_evstrt= ind(yyyymm .eq. g_su_events(ii)) - istrt
        print(i_evstrt)
        cmp_var1_su = cmp_var1_su+var1(i_evstrt:i_evstrt+11,:,:)
    end do
    cmp_var1_su =cmp_var1_su/n_su_events
    ano_cmp_var1_su = calcMonAnomTLL(cmp_var1_su,clm_var1)


    cmp_var2_su = var2(0:11,:,:)
    cmp_var2_su = 0
    do ii=0,n_su_events-1
        i_evstrt= ind(yyyymm .eq. g_su_events(ii)) - istrt
        cmp_var2_su = cmp_var2_su+var2(i_evstrt:i_evstrt+11,:,:)
    end do
    cmp_var2_su =cmp_var2_su/n_su_events
    ano_cmp_var2 = calcMonAnomTLL(cmp_var2_su,clm_var1)

    clm_vr = uv2vrF_Wrap(clm_var1,clm_var2)
    cmp_vr    = uv2vrF_Wrap (cmp_var1,cmp_var2)         ; u,v ==> vorticity (rel)
    cmp_vr_su    = uv2vrF_Wrap (cmp_var1_su,cmp_var2_su)         ; u,v ==> vorticity (rel)
    
    cmp_vr = cmp_vr - clm_vr
    cmp_vr_su = cmp_vr_su - clm_vr

    cmp_vr_ts = wgt_areaave(cmp_vr(:,{-15:0},{150:180}), 1.0, 1.0, 0)-wgt_areaave(cmp_vr(:,{0:15},{150:180}), 1.0, 1.0, 0)
    cmp_vr_ts_su = wgt_areaave(cmp_vr_su(:,{-15:0},{150:180}), 1.0, 1.0, 0)-wgt_areaave(cmp_vr_su(:,{0:15},{150:180}), 1.0, 1.0, 0)
    
    data=new((/2,dimsizes(cmp_vr_ts)/),float)
    data(0,:)=cmp_vr_ts
    data(1,:)=cmp_vr_ts_su
    print(data) 

; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

	;************************************************ 
	; plotting parameters
	;************************************************
	wks   = gsn_open_wks ("eps",g_fig_name)                 ; open workstation

	res               = True                    ; plot mods desired

             
    res@vpXF     = 0.15

    res@vpWidthF = 0.8
    res@vpHeightF= 0.2


;	res@trYMinF            = min(exp_nino34_idx)                ; Y axis limits
;	res@trYMaxF            = max(exp_nino34_idx)+0.5

    res@gsnCenterString = g_fig_title
	res@trXMinF  = 1                   ; min value on x-axis
	res@trXMaxF  = 12                   ; max value on x-axis
	res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    res@tiXAxisString = "Month"
	res@tmXBValues = ispan(1, 12, 1) ;interval
	res@tmXBLabels = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)         ;tick label
    
    res@tmYLMode      = "Explicit" ; Define own tick mark labels.
	res@tmYLValues = (/-2e-6,-1e-6,0,1e-6,2e-6,3e-6,4e-6,5e-6,6e-6/) ;interval
	res@tmYLLabels = (/-2e-6,-1e-6,0,1e-6,2e-6,3e-6,4e-6,5e-6,6e-6/)         ;tick label

    res@xyMonoLineColor    = False             ; want colored lines
	res@xyLineColors       = (/"blue","red"/) ; colors chosen
	res@xyLineThicknesses	 = (/4.0,4.0/)      ; line thicknesses
	res@xyDashPatterns	 = (/0.,0./)      ; make all lines solid
	res@tmXBMajorThicknessF = 5.0
	res@tmYLMajorThicknessF = 5.0
	res@tmXBMinorThicknessF = 4.0
	res@tmYLMinorThicknessF = 4.0
	res@tmBorderThicknessF = 4.0
	res@tmXBLabelFontHeightF =0.022
	res@tmYLLabelFontHeightF = 0.022
	; Note that a colon is the default function code. We recommend
	; setting default code to be a tilde (~) in your .hluresfile.
	; See: http://www.ncl.ucar.edu/Document/Graphics/hlures.shtml
	;
	 top_plot  = gsn_csm_xy (wks,ispan(1,12,1),data,res)   ; create plot

end 
