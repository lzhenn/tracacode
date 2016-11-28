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

;================================================
;Variables List:
;================================================



begin
    ;Data series
    g_filetime=(/"316","317","318"/)
    
    ;AE6 PM25 species
    ;g_species=(/"AECI","AECJ","ASO4I","ASO4J","ANO3I","ANO3J","APOCI","APOCJ","AOTHRJ","AH2OJ","ANAJ","ACLI","ACLJ","ANH4I","ANH4J","APNCOMI","APNCOMJ","AALJ","ACAJ","AFEJ","ASIJ","ATIJ","AMGJ","AKJ","AMNJ","AALKJ","AXYL1J","AXYL2J","AXYL3J","ATOL1J","ATOL2J","ATOL3J","ABNZ1J","ABNZ2J","ABNZ3J","ATRP1J","ATRP2J","AISO1J","AISO2J","ASQTJ","AORGCJ","AISO3J","AOLGAJ","AOLGB"/)
    
    ;AE5 PM25 species
    ;g_species=(/"AECI","AECJ","ASO4I","ASO4J","ANO3I","ANO3J","AORGPAI","AORGPAJ","A25J","AH2OJ","ANAJ","ACLI","ACLJ","ANH4I","ANH4J","AALKJ","AXYL1J","AXYL2J","AXYL3J","ATOL1J","ATOL2J","ATOL3J","ABNZ1J","ABNZ2J","ABNZ3J","ATRP1J","ATRP2J","AISO1J","AISO2J","ASQTJ","AORGCJ","AISO3J","AOLGAJ","AOLGBJ"/)
    
    ;AE6 POC
    g_species=(/"APOCI","APOCJ"/)

    ;AE5 POC
    ;g_species=(/"AORGPAI","AORGPAJ"/)

    ;Output species name
    out_species_name="POC"

    ;Input file stream
    data_file_name="/disk/scratch/huangyeq/test_data/AE-test/ae6/cmaq/2015111112/3km/CCTM_V5g_Linux2_x86_64pg_mpich2.CONC.2015"+g_filetime
    ;data_file_name="/disk/scratch/huangyeq/test_data/AE-test/ae5/cmaq/2015111112/3km/CCTM_V5g_ebi_cb05cl_ae5_aq_mpich2.CONC.2015"+g_filetime
    
    ;Output file stream
    out_file_name="/disk/scratch/huangyeq/test_data/AE-test/ae6/cmaq/2015111112/3km/CCTM_V5g_Linux2_x86_64pg_mpich2."+out_species_name+".2015"+g_filetime+".nc"
    ;out_file_name="/disk/scratch/huangyeq/test_data/AE-test/ae5/cmaq/2015111112/3km/CCTM_V5g_ebi_cb05cl_ae5_aq_mpich2.POC.2015"+g_filetime+".nc"

do ii=0,dimsizes(g_filetime)-1

;---------------Read data-------------------
    print("Preparing reading...")
    ctrl_in=addfile(data_file_name(ii),"r")
    ctrl_var = ctrl_in->$g_species(0)$(0:23,:,:,:)               
    ctrl_tflag = ctrl_in->TFLAG(0:23,0,:)               
    do jj=1,dimsizes(g_species)-1
        print("Reading Day"+g_filetime(ii)+" "+g_species(jj))
        ctrl_var = ctrl_var+ctrl_in->$g_species(jj)$(0:23,:,:,:)
    end do


;---------------Write data-------------------
    print("Day"+g_filetime(ii)+" Writing...")
;Get dimsize
    dims=dimsizes(ctrl_var(0,:,:,:))
    nlvl=dims(0)
    nrow=dims(1)
    ncol=dims(2)
    
;Set fileoption    
    system("rm "+out_file_name(ii)+" >& /dev/null")
    fout = addfile(out_file_name(ii) ,"c")  ; open output netCDF file
    setfileoption(fout,"DefineMode",True)

;Set All field attribution
    fileAtt     = True
    fileAtt@creation_date=systemfunc("date")
    fileattdef(fout,fileAtt)

;Define Coordinate
    dimNames    =(/ctrl_var!0,ctrl_var!1,ctrl_var!2,ctrl_var!3,ctrl_tflag!1/)
    dimSizes    =(/-1,nlvl,nrow,ncol,2/)
    dimUnlim    =(/True,False,False,False,False/)
    filedimdef(fout,dimNames,dimSizes,dimUnlim)
;Define var, type and dim
    filevardef(fout,out_species_name,typeof(ctrl_var),getvardims(ctrl_var))
    filevardef(fout,"TSTEP",typeof(ctrl_tflag),getvardims(ctrl_tflag))

;Define Attribute
    filevarattdef(fout,out_species_name,ctrl_var)
    filevarattdef(fout,"TSTEP",ctrl_tflag)

    fout->POC=(/ctrl_var/)
    fout->TSTEP=(/ctrl_tflag/)
    delete([/ctrl_var, fout/])
    print("Day"+g_filetime(ii)+" Done!")

end do
end




