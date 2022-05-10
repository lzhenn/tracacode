load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
    
    
    ;orginal emission file (path)
    datain_fn="../data/step4_output/"
    
    output_fn="../data/step5_output/"
    
    ;target grid file
    grid_fn="/disk/hq247/yhuangci/resource/map_info/research_domains/27km/GRIDCRO2D.27km"
    
    ;monthly ratio
    factor_fn="../data/input_profile/monthly_temporal.txt"

    ;
    d2_fn=(/"REF_TRF","PRO","CHE","IRO","NFE","PRU_SOL","NEU","TRO","TNR_other","SWD_LDF","WWT","SWD_INC","FFF","RCO","MNM","AGS","AWB"/) ;17 files; monthly:line 1~17
    d3_fn=(/"ENE","IND","FOO_PAP","NMM","TNR"/) ;5 files; monthly:line 17~21
    n_sec=dimsizes(d2_fn)+dimsizes(d3_fn)
    n_sec_d2=dimsizes(d2_fn)
    ;
    ;weekname=(/"weekXhour_Mon_temporal","weekXhour_Fri_temporal","weekXhour_Sat_temporal","weekXhour_Sun_temporal"/)
    weekname=(/"Mon","Fri","Sat","Sun"/)

    ;
    mon_abbr = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
    mon_days=(/31,29,31,30,31,30,31,31,30,31,30,31/)

    
    vNames=(/"NH3","CO","SO2","SULF","NO","NO2","HONO","PEC","POC","PSO4","PNO3","PCA","PMG","PK","PNCOM","PFE","PAL","PSI","PTI","PMN","PCL","PNH4","PNA","PMOTHR","PH2O","PMC","CH4","PAR","OLE","TOL","XYL","FORM","ALD2","ETH","ISOP","MEOH","ETOH","NVOL","ETHA","IOLE","ALDX","TERP","UNR","BENZENE","UNK","NR","NROG"/)


    ;profile source
    mon_prof_src="/disk/hq247/yhuangci/analy/halogen/emission/EDGAR/data/input_profile/monthly_temporal.txt"

;---------------Read data-------------------

    ;profile in
    print("Profile in...")
    mon_prof_rec  =   asciiread(mon_prof_src,(/n_sec,12/),"float") ; get the first file's lat lon and value
    weekxhour_prof_rec=new((/4,n_sec,48/),"float")
    do iweek=0,3
        weekxhour_frame  =   asciiread("/disk/hq247/yhuangci/analy/halogen/emission/EDGAR/data/input_profile/weekXhour_"+weekname(iweek)+"_temporal.txt",(/n_sec,48/),"float") ; get the first file's lat lon and value
        weekxhour_prof_rec(iweek,:,:) = weekxhour_frame
    end do

    ;grid in (lon for calculating timezone)
    print("Longitude in...")
    grid_in   =  addfile(grid_fn,"r")
    lon= grid_in->LON(0,0,:,:)
    dim2d=dimsizes(lon)
    
    
    nUTC=25
    nLAY=26
    nROW=dim2d(0)
    nCOL=dim2d(1)

    nNames = 47

    ; change lon to timezone
    timezone0=lon
    timezone0=floattoint((lon+7.5)/15)
    
    ;create template variables
    print("Creating template arrays, may take long...")
    timezone:=conform_dims((/nNames,nROW,nCOL/), timezone0, (/1,2/))
    timezone3D:=conform_dims((/nNames,nLAY,nROW,nCOL/), timezone0, (/2,3/))
    
    ; create vars zookeeper
    zookeeper2D:=conform_dims((/nNames,nROW,nCOL/),lon, (/1,2/))
    zookeeper2D=0.0
    zookeeper2D!0="varlist"
    zoo_alctor2D:=zookeeper2D
    
    print(">>Zookeeper2D created...")

    zookeeper3D:=conform_dims((/nNames,nLAY,nROW,nCOL/),lon, (/2,3/))
    zookeeper3D=0.0
    zookeeper3D!0="varlist"
    
    print(">>Zookeeper3D created...")
    
   
    ; create vars zoo exit
    zoo_exit:=conform_dims((/nUTC,nNames,nLAY,nROW,nCOL/),zookeeper2D,(/1,3,4/))
    zoo_exit=0.0
    ; define zoo_exit
    zoo_exit!0="UTC"
    zoo_exit!1="VAR"
    zoo_exit!2="LAY"
    zoo_exit!3="ROW"
    zoo_exit!4="COL"
    print(">>ZooExit created...")

               

    print("Allocation...")

    do imon=9,11  ; mon loop
        do iweek= 0,3 ;week loop (Mon, Fri, Sat, Sun)
          ;  if (imon .lt. 9) .and. (iweek .lt. 2) then
          ;      continue
          ;  end if
            print(">>Allocating "+weekname(iweek)+" in "+mon_abbr(imon))
            
            do isec = 0, n_sec-1     
                
                flag2d=False
                
                if isec .lt. dimsizes(d2_fn) then
                    flag2d=True
                end if
                
                if flag2d then
                    
                    fn=datain_fn+"/"+d2_fn(isec)+".nc"
                    
                    print(">>>>Reading 2D sector: "+fn)
                    d2_in=addfile(fn,"r")
                    
                    zookeeper2D&varlist=vNames
                    
                    do ivar=0,nNames-1              ; loop thru each variable
                        var_source_temp := d2_in->$vNames(ivar)$        ; read the varible to memory
                        zookeeper2D(ivar,:,:)=(/var_source_temp/)
                    end do
     
                    print(">>>>Allocating...")
                    ; allocate to weeekly emission mon
                    zoo_alctor2D=zookeeper2D*mon_prof_rec(isec,imon)/mon_days(imon)*7.0
                    zoo_alctor_hr2D=conform_dims((/24,nNames,dim2d(0),dim2d(1)/), zoo_alctor2D, (/1,2,3/))
                    hr_profile=conform_dims((/24,nNames,nROW,nCOL/),weekxhour_prof_rec(iweek,isec,0:23),(/0/))

                    ; allocate to hourly, this is tricky
                    zoo_alctor_hr2D=zoo_alctor_hr2D*hr_profile
                    
                    print(">>>>>>Allocation: Timezone Shifting")
                    ; conform variables
                    zoo_alctor_hr_utc:=zoo_alctor_hr2D ; use re-let because the append operation
                    do izone = floattoint(min(timezone)),floattoint(max(timezone))
                        do itime=0,24-izone-1
                            zoo_alctor_hr_utc(itime,:,:,:)=where(timezone .eq. izone, zoo_alctor_hr2D(izone+itime,:,:,:), zoo_alctor_hr_utc(itime,:,:,:))
                        end do
                        do itime=24-izone,23
                            zoo_alctor_hr_utc(itime,:,:,:)=where(timezone .eq. izone, zoo_alctor_hr2D(itime+izone-24,:,:,:), zoo_alctor_hr_utc(itime,:,:,:))
                        end do
                    end do
                    
                    print(">>>>>>Allocation: Final Processing")
                    ; append 25th record
                    zoo_alctor_hr_utc:=array_append_record(zoo_alctor_hr_utc,zoo_alctor_hr_utc(0:0,:,:,:),0)

                    ; unit alter t/h --> g/s
                    zoo_alctor_hr_utc=zoo_alctor_hr_utc*1e6/3600

                    ; accumulate the variables;
                    zoo_exit(:,:,0,:,:)=(/zoo_exit(:,:,0,:,:)+zoo_alctor_hr_utc/)
                else ;3D sector

                    isec3d=isec-n_sec_d2
                    fn=datain_fn+"/"+d3_fn(isec3d)+".nc"
                    
                    print(">>>>Deal with 3D sector: "+fn)
                   
                    d3_in=addfile(fn,"r")
                    
                    zookeeper3D&varlist=vNames
                    
                    do ivar=0,nNames-1              ; loop thru each variable
                        var_source_temp := d3_in->$vNames(ivar)$        ; read the varible to memory
                        zookeeper3D(ivar,:,:,:)=(/var_source_temp/)
                    end do
     
                    print(">>>>Allocating...")
                    ; allocate to weeekly emission mon
                    zoo_alctor3D=zookeeper3D*mon_prof_rec(isec,imon)/mon_days(imon)*7.0
                    zoo_alctor_hr3D=conform_dims((/24,nNames,nLAY,dim2d(0),dim2d(1)/), zoo_alctor3D, (/1,2,3,4/))
                    
                    ; allocate to hourly, this is tricky
                    do ihour=0,23
                        zoo_alctor_hr3D(ihour,:,:,:,:)=zoo_alctor_hr3D(ihour,:,:,:,:)*weekxhour_prof_rec(iweek,isec,ihour)
                    end do                
                    print(">>>>>>Allocation: Timezone Shifting")
                    ; conform variables
                    zoo_alctor_hr_utc3D:=zoo_alctor_hr3D ; use re-let because the append operation
                    do izone = floattoint(min(timezone3D)),floattoint(max(timezone3D))
                        do itime=0,24-izone-1
                            zoo_alctor_hr_utc3D(itime,:,:,:,:)=where(timezone3D .eq. izone, zoo_alctor_hr3D(izone+itime,:,:,:,:), zoo_alctor_hr_utc3D(itime,:,:,:,:))
                        end do
                        do itime=24-izone,23
                            zoo_alctor_hr_utc3D(itime,:,:,:,:)=where(timezone3D .eq. izone, zoo_alctor_hr3D(itime+izone-24,:,:,:,:), zoo_alctor_hr_utc3D(itime,:,:,:,:))
                        end do
                    end do
                    
                    print(">>>>>>Allocation: Final Processing")
                    ; append 25th record
                    zoo_alctor_hr_utc3D:=array_append_record(zoo_alctor_hr_utc3D,zoo_alctor_hr_utc3D(0:0,:,:,:,:),0)

                    ; unit alter t/h --> g/s
                    zoo_alctor_hr_utc3D=zoo_alctor_hr_utc3D*1e6/3600

                    ; accumulate the variables;
                    zoo_exit=(/zoo_exit+zoo_alctor_hr_utc3D/)
                end if
            end do ; isec end 
            
            
            ;-----------Output---------------- 
            out_file_fullpath=output_fn+weekname(iweek)+"."+mon_abbr(imon)+".nc"
            print(">>>>Output "+out_file_fullpath)
            
            ;Set fileoption    
            system("rm "+out_file_fullpath)
            setfileoption("nc","format","netcdf4")
            fout := addfile(out_file_fullpath ,"c")  ; open output netCDF file
            ;setfileoption(fout,"DefineMode",True)

            ;Set All field attribution
            fileAtt     = True
            fileAtt@creation_date=systemfunc("date")
            fileattdef(fout,fileAtt)

            ;Define Coordinate
            dimNames    =(/"UTC", "LAY", "ROW", "COL"/)
            dimSizes    =(/nUTC,nLAY,nROW,nCOL/)
            dimUnlim    =(/False,False,False,False/)
            filedimdef(fout,dimNames,dimSizes,dimUnlim)
       
            do ivar=0,nNames-1              ; loop thru each variable
                var_source_temp := d3_in->$vNames(ivar)$        ; read the varible to memory
                filevardef(fout,vNames(ivar),typeof(zoo_exit),getvardims(zoo_exit(:,0,:,:,:)))
                filevarattdef(fout,vNames(ivar),var_source_temp)
                fout->$vNames(ivar)$=(/zoo_exit(:,ivar,:,:,:)/)
            end do
            delete([/fout, d2_in, d3_in/])
            zoo_exit=0.0
        end do ; iweek end
    end do ; imon end

       
end
