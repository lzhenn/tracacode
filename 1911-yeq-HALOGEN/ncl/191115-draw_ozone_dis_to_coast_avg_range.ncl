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
load "/disk/hq247/yhuangci/resource/ncl-resource/cnmap-zhenning/cnmap.ncl"
;================================================
;Variables List:
;	var1--------------CO2
;	var2--------------CH4
;	var3--------------N2O
;	var4--------------f11
;	var5--------------f12
;================================================



begin
        
    mon="oct"
    type="with"

    species=(/"CL2","CL","HOCL","CLO","FMCL","HCL","CLNO2","CLNO3","BR","BRO",\
              "HOBR","HBR","BR2","BRNO3","BRNO2","FMBR","CH3BR","MB3","MB2","MB2C",\
              "MBC2","MBC","DMS","MSA","BRCL","I","IO","HI","I2","HOI",\
              "INO","INO2","INO3","OIO","I2O4","I2O2","I2O3","CH3I","ICL","IBR",\
              "MI2","MIB","MIC"/)
    ;
    g_font=0.015


    ;grid file
    grid_fn="/disk/hq247/yhuangci/resource/map_info/research_domains/27km/GRIDCRO2D.27km"
    latlon_in   =  addfile(grid_fn,"r")
    lat2d = latlon_in->LAT(0,0,:,:)
    lon2d = latlon_in->LON(0,0,:,:)

    ;File IO
    ocean_fn=addfile("dis_to_coast_27km.nc","r")
    dis_coast=ocean_fn->dis_to_coast
    dis_coast=where(dis_coast .eq. 999, 0, dis_coast) 
    dis_coast=dis_coast*27  ;convert to km

    ;File IO
    pdata_fn  =systemfunc("ls ../../../data/cmaq/with/"+mon+"/COMBINE_CCTM_ACONC_27km_2016*") 
    ctrl_in = addfiles(pdata_fn ,"r")  ; open output netCDF file
    var1_with = ctrl_in[:]->O3(:,0,:,:)

    var1_with_mean=dim_avg_n_Wrap(var1_with,0)


    pdata_fn  =systemfunc("ls ../../../data/cmaq/without/"+mon+"/COMBINE_CCTM_ACONC_27km_2016*") 
    ctrl_in = addfiles(pdata_fn ,"r")  ; open output netCDF file
    var1_without = ctrl_in[:]->O3(:,0,:,:)

    var1_without_mean=dim_avg_n_Wrap(var1_without,0)
    var1_diff=var1_with_mean
    var1_diff=(/var1_with_mean-var1_without_mean/)*1000

    dis_1d=ndtooned(dis_coast)
    print(max(dis_1d))
    print(min(dis_1d))
    var1_1d=ndtooned(var1_diff)

    var1_1d_by_dis=var1_1d

    ;-------below take bins, cal bin mean and stddev----------
    rank_ascend=dim_pqsort(dis_1d,2)
    nends=150
    dis_range=fspan(dis_1d(0),dis_1d(dimsizes(dis_1d)-1),nends)
    dis_center=new(nends-1, "float")
    bin_var1=new(nends-1,"float")
    bin_nvar1=new(nends-1,"float")
    bin_var1std=new(nends-1,"float")
    tmp_avg=0.       ; individual bin avg
    acc_count=0     ; total count in dis_1d
    bin_nsmp=0      ; sub n samples in individual bin
    ;print(dis_range)
    do ii=0,nends-2
        do while (.not.(dis_1d(acc_count) .gt.dis_range(ii+1)))
            tmp_avg=tmp_avg+var1_1d(rank_ascend(acc_count))
            var1_1d_by_dis(acc_count)=var1_1d(rank_ascend(acc_count))
            acc_count=acc_count+1
            bin_nsmp=bin_nsmp+1
            if (acc_count .gt. dimsizes(dis_1d)-1) then
                break
            end if
        end do
        tmp_avg=tmp_avg/bin_nsmp
        bin_nvar1(ii)=bin_nsmp
        bin_var1(ii)=tmp_avg
        dis_center(ii)=(dis_range(ii)+dis_range(ii+1))/2
        bin_nsmp=0
        tmp_avg=0
    end do

    ; below determine stddev
    strt_pos=0
    do ii=0, nends-2
        print(ii+"--"+bin_nvar1(ii))
        bin_var1std(ii)=stddev(var1_1d_by_dis(toint(strt_pos):toint(strt_pos+bin_nvar1(ii)-1)))
        strt_pos=strt_pos+toint(bin_nvar1(ii))
    end do
    bin_var1_range=new((/2,nends-1/),"float")
    bin_var1_range(0,:)=bin_var1-bin_var1std
    bin_var1_range(1,:)=bin_var1+bin_var1std
    ;-------above take bins, cal bin mean and stddev----------
;************************************************
; plotting parameters
;************************************************
 wks  = gsn_open_wks("png","scatter")             ; send graphics to PNG file
 
 res                     = True                   ; plot mods desired
 
 res@gsnFrame         = False
 res@gsnDraw  = False
 res@gsnMaximize         = True                   ; maximize plot in frame
; res@xyLineThicknesses   = (/1,2/)                ; set second line to 2
 res@tiYAxisFontHeightF = g_font
 res@tiXAxisFontHeightF = g_font
 res@tiYAxisString = "O3 Diff (HAL-BASE, ppb)"
 res@tiXAxisString = "Distance (km)"
 res@gsnStringFontHeightF=g_font
 res@gsnLeftString = "(d) "+mon
 res@gsnRightString = "O3 Diff (ppb)"

 res@xyLineColor="red"
 res@xyLineThicknessF=4.0
 res@trYMaxF            = 0.0
 res@trYMinF            = -12.0
 res@trXMaxF            = 1800.0
 res@trXMinF            = -3000.0


 bot_plot  = gsn_csm_xy (wks,dis_center, bin_var1,res)        ; create plot
 
 ; Create a plot with the area between both curves filled in pink.
 res@gsnXYFillColors = "LightPink"
 res@xyLineColor     = -1                           ; We don't want the line, so make it transparent.
 mid_plot  = gsn_csm_xy (wks,dis_center,bin_var1_range,res)  ; Create another filled XY plot.

  overlay(bot_plot,mid_plot)

;---------------------------Add plot legend-----------------------------------
    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 1.                    ; solid line
    res_lines@gsLineThicknessF  = 3.                    ; line thicker
    res_lines@gsLineColor       = "black"

    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.015                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification
    res_text@txFontColor        = "Blue"
    res_text@txFontHeightF      = 0.03

    yy = (/-12.0,0.0/)
    xx = (/0,0/)
    dum11 = gsn_add_polyline(wks,bot_plot,xx,yy,res_lines)              ; add polyline
    dum12 = gsn_add_text(wks,bot_plot,"At Sea",500,-10.0,res_text); add text
    
    res_text@txFontColor        = "Brown"
    dum22 = gsn_add_text(wks,bot_plot,"In Land",-2000,-10.0,res_text); add text
    draw(bot_plot)
    frame(wks)
end




