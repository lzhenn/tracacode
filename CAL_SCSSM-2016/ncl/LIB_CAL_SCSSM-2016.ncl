; get the BOB onset idx
function get_esm_var_2d_from_post(var_name:string, g_data_path:string)
begin
    print("get_esm_var_2d_from_post...")
    ctrl_in_files = systemfunc("ls "+g_data_path)
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in     = addfiles (ctrl_in_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in, "join")
    var  =ctrl_in[:]->$var_name$
    return(var)
end 
 
function get_esm_var_2d_from_3d_post(var_name:string, g_data_path:string, plvl)
begin
    print("get_esm_var_2d_from_post...")
    ctrl_in_files = systemfunc("ls "+g_data_path)
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in     = addfiles (ctrl_in_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in, "join")
    var  =ctrl_in[:]->$var_name$(:,:,{plvl},:,:)
    return(var)
end 
    

function get_onset_idx_from_post_flut(g_latS, g_latN, g_lonW, g_lonE, g_data_path:string)
begin
    day_strt=80
    print("get_onset_idx_from_post_flut...")

    var=get_esm_var_2d_from_post("FLUT", g_data_path)
    
    var_areamean=wgt_areaave_Wrap(var(:,1:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
    var_mean=dim_avg_n_Wrap(var_areamean,0)  
    var_onset=var_areamean
    var_onset_M2J=var_onset(:,day_strt:)

    var_onset_M2J=where(var_onset_M2J .lt. 236, 1, 0)
    var_onset_M2J=dim_acumrun_n(var_onset_M2J,6,1,1)
    
    dim_esm=dimsizes(var_onset)
    dim_esm:=dim_esm(0)

    
    onset_esm=var_onset(:,0)

    do ii=0,dim_esm-1
        idate= get1Dindex(var_onset_M2J(ii,:), 6)
        onset_esm(ii)=(day_strt+idate-5)
    end do
    
    ncase=dimsizes(onset_esm)
    print("Cases: "+ncase)
    return(onset_esm)
end
   
    

