load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
    
    ;orginal emission file (path)
    data_fn="../data/input_inv/gas_pol/"
    
    ;target grid file
    grid_fn="/disk/hq247/yhuangci/analy/halogen/emission/marine/data/METCRO3D.27km.20180619"
   
    ;allocation coefficients
    factor_fn="../data/input_profile/RA.txt"
    
    ;Output file (path) 
    pdata_fn     = "../data/step1_output/gas_pol/"  ; open output netCDF file

    ;Number of relocation grids
    n_pts=846980
;---------------Read data-------------------
    all_res_files = systemfunc ("ls "+data_fn+"v4*"); ../"+case_name+"/"+exedir+"/*cam.h0.002[0-4]*")
    n_files=dimsizes(all_res_files)
    grid_in   =  addfile(grid_fn,"r")
    sample_var4d = grid_in->JACOBF
    sample_var4d = 0    ;set to empty
    sample_var2d = sample_var4d(0,0,:,:)
    dim_mcip_2d=dimsizes(sample_var2d)
    
    pt_record  =   asciiread(factor_fn,(/n_pts,5/),"float") ; get the first file's lat lon and value
       
    do ii = 0, n_files-1
        
        out_name=str_split(all_res_files(ii),"/")
        out_file_fullpath=pdata_fn+"mcip_"+out_name(3)
        print("Creating "+out_file_fullpath)
        ;Get dimsize
        dims=dimsizes(sample_var4d)
        ncorx=dims(2)
        ncory=dims(3)
            
        ;Set fileoption    
        system("rm "+out_file_fullpath)
        fout = addfile(out_file_fullpath ,"c")  ; open output netCDF file
        setfileoption(fout,"DefineMode",True)

        ;Set All field attribution
        fileAtt     = True
        fileAtt@creation_date=systemfunc("date")
        fileattdef(fout,fileAtt)

        ;Define Coordinate
        dimNames    =(/ "ROW", "COL"/)
        dimSizes    =(/ncorx,ncory/)
        dimUnlim    =(/False,False/)
        filedimdef(fout,dimNames,dimSizes,dimUnlim)

        print("Processing "+all_res_files(ii))
        emission_in=addfile(all_res_files(ii), "r")
        
        vNames = getfilevarnames (emission_in) ; get names of all variables on file
        nNames = dimsizes (vNames)   ; number of variables on the file
        
        do nn=0,nNames-1              ; loop thru each variable
            print(">>Dealing with var $$"+vNames(nn)+"$$ in "+out_name(3))
            if (vNames(nn) .eq. "lat") .or. (vNames(nn) .eq. "lon") then
                continue
            end if
            var_source = emission_in->$vNames(nn)$        ; read the varible to memory
            
            print(">>Relocationing")
            sample_var2d=0.0
            delete_VarAtts(sample_var2d, -1)
            copy_VarAtts(var_source, sample_var2d)
            do jj=0, n_pts-1
                 sample_var2d(floattoint(pt_record(jj,0))-1,floattoint(pt_record(jj,1))-1)=sample_var2d(floattoint(pt_record(jj,0))-1,floattoint(pt_record(jj,1))-1)+var_source(floattoint(pt_record(jj,2))-1,floattoint(pt_record(jj,3))-1)*pt_record(jj,4)
            end do
            ;sample_var4d=(/conform(sample_var4d,sample_var2d, (/2,3/))/)
            ;printVarSummary(sample_var4d)
            print("Write File...")
            
            filevardef(fout,vNames(nn),typeof(sample_var2d),getvardims(sample_var2d))
            filevarattdef(fout,vNames(nn),sample_var2d)
            fout->$vNames(nn)$=(/sample_var2d/)

        end do ; var loop
        delete([/fout, vNames/])
     end do ; file loop
end
