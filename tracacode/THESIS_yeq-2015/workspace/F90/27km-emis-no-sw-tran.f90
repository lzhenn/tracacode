program redistribution_smoke_points_emissions

include  "/public/software/WRFV331/lib/netcdf363-intel/include/netcdf.inc"
integer :: nx,ny,nz,nt,newx,newy,cx,cy,i,j,k,t,ii,jj,kk,irec,var
character chfln*2,file1*200,file2*200
parameter (cx=182,cy=138,nt=97,nz=25,var=32,num_pic=32) !/01'BC',02'CB05_ALD2',03'CB05_ALDX',04'CB05_ETH',05'CB05_ETHA',06'CB05_ETOH',07'CB05_FORM',08'CB05_IOLE',09'CB05_ISOP',10'CB05_MEOH',11'CB05_NVOL',12'CB05_OLE',13'CB05_PAR',14'CB05_TERP',15'CB05_TOL',16'CB05_UNR',17'CB05_XYL',18'CO',19'CO2',20'NH3',21'OC',22'PM2.5',23'PMcoarse',24'SO2',25'VOC',26:NO     27:NO2       28: HONO 29:PMFINE 30:PNO3 31:PSO4 32:SULF /)
!!!!!! souce(1:5)=(/'power','agriculture','industry','residential','transportation'/)
integer::dat_h(nt),dat_d(nt),dat_m(nt),dat_w(nt),pic(33)
integer::mon_num(12),iy,im,id,ih,SDATE2,iw             !读取  日期信息  年，月，日，时，第几天，星期
integer SDATE1,SDATE,day_yu,var_id,STIME
integer TFLAG(2,var,nt),TFLAG1
character(len=2)::month(12),day(31)
character(len=100) :: file_name
integer status, ncid, ncid1, ncid2, ncid3, it, ichr,i0,j0
integer start1(3),start2(4),start3(4)
integer count1(3),count3(4)
data start1 /1,1,1/
data start2 /1,1,1,1/
data count1 /2,var,nt/
data count3 /cx,cy,nz,nt/
real::grid(4,cx,cy),grid_china_in(cx,cy),grid_china_out(cx,cy),pow_dens(18),ind_dens(18),grid_gd(cx,cy)
real,allocatable,dimension(:,:,:,:,:)::dat_cmaq_over
real,allocatable,dimension(:,:,:,:)::coe,dat_over_1,dat_over_2,dat_over_3,dat_over_4,dat_over_5!!!dat_over_1=power,dat_over_3=industry,dat_over_2=all of other
real,allocatable,dimension(:,:,:,:)::CO!!all smoke output pollutants name use CO 
mon_num=(/31,28,31,30,31,30,31,31,30,31,30,31/) 
month=(/'01','02','03','04','05','06','07','08','09','10','11','12'/)
day=(/'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31'/)
pic=(/0,2,3,0,0,18,4,5,6,7,0,8,9,10,20,26,27,11,12,13,1,23,29,30,21,31,24,0,14,15,0,16,17/)
pow_dens=(/0.000,0.000,0.000,0.000,0.030,0.036,0.058,0.144,0.100,0.102,0.122,0.215,0.126,0.057,0.003,0.004,0.003,0.000/)
ind_dens=(/0.057,0.052,0.033,0.037,0.068,0.104,0.126,0.154,0.144,0.086,0.103,0.021,0.007,0.002,0.002,0.003,0.002,0.000/)
file_name='/public/home/dengtao/models/emis-qinghua/'
allocate(dat_cmaq_over(cx,cy,5,num_pic,12),dat_over_1(cx,cy,num_pic,nt))
allocate(dat_over_2(cx,cy,num_pic,nt),dat_over_3(cx,cy,num_pic,nt))
allocate(coe(5,12,7,24))

open(11,file=''//trim(file_name)//'date.fin',status='old')      !读取日期信息
read(11,*)iy
read(11,*)im
read(11,*)id
read(11,*)ih
read(11,*)SDATE2
read(11,*)iw
SDATE=iy*1000+SDATE2 
STIME=ih*10000
write(*,*)"SDATE",SDATE,iy,im,id,ih,iw 
close(11)

!未来nt小时日期计算
if(mod(iy,4)==0)then
	mon_num(2)=29
end if
dat_m=im
do i=1,nt
	dat_h(i)=mod(ih+i-1,24)
	!  write(*,*)dat_h(i)
	dat_d(i)=id+(ih+i-1)/24
	! write(*,*)dat_d(i)	  
	if(dat_d(i)>mon_num(im))then 
		dat_m(i)=dat_m(i)+1 
	end if
	dat_w(i)=mod(iw+(ih+i-1)/24,7)
	if(dat_w(i)==0)then 
		dat_w(i)=7
	end if
	!  write(*,*)dat_w(i),i
end do
dat_h=dat_h+1
!write(*,*)dat_m
open(11,file=''//trim(file_name)//'coe.txt',status='old')              !读取时间系数
do kk=1,5
	do i=1,12
		do j=1,7
			do k=1,24
				read(11,'(f8.6)')coe(kk,i,j,k)
				!write(*,'(f8.6)')coe(kk,i,j,k)
			end do
		end do
	end do
end do
close(11)
!     open(102,file=''//trim(file_name)//'dat_pic.grd',status='old',form='unformatted',access='direct',recl=cx,swap)
open(102,file=''//trim(file_name)//'dat_pic_27km.txt',status='old')	
irec=0
do ii=1,5
	do k=1,num_pic
		do kk=1,12
			do j=1,cy
				irec=irec+1
				! read(102,rec=irec)(dat_cmaq_over(i,j,ii,k,kk),i=1,cx)
				read(102,*)(dat_cmaq_over(i,j,ii,k,kk),i=1,cx)	
			end do
		end do
	end do
end do
close(102)
write(*,*)dat_cmaq_over(100,94,1:5,18,dat_m(1))

do jj=1,num_pic
	do k=1,nt
		do i=1,cx
			do j=1,cy
				dat_over_1(i,j,jj,k)=dat_cmaq_over(i,j,1,jj,dat_m(k))*coe(1,dat_m(k),dat_w(k),dat_h(k)) 
				dat_over_3(i,j,jj,k)=dat_cmaq_over(i,j,3,jj,dat_m(k))*coe(3,dat_m(k),dat_w(k),dat_h(k))
				dat_over_2(i,j,jj,k)=dat_cmaq_over(i,j,2,jj,dat_m(k))*coe(2,dat_m(k),dat_w(k),dat_h(k))
				dat_over_4(i,j,jj,k)=dat_cmaq_over(i,j,4,jj,dat_m(k))*coe(4,dat_m(k),dat_w(k),dat_h(k))
				dat_over_5(i,j,jj,k)=dat_cmaq_over(i,j,5,jj,dat_m(k))*coe(5,dat_m(k),dat_w(k),dat_h(k))
			end do
		end do
	end do
end do
write(*,*)'dat_over_2'
write(*,*)dat_over_1(100,94,18,1),dat_over_2(100,94,18,1)
write(*,*)coe(1,dat_m(1),dat_w(1),dat_h(1)) 
deallocate(dat_cmaq_over,coe)
open(102,file=trim(file_name)//'china_in.txt',status='old')
do i=1,cx
	do j=1,cy
		read(102,'(f3.2)')grid_china_in(i,j) 
	end do
end do
close(102)

open(102,file=trim(file_name)//'china_out.txt',status='old')
do i=1,cx
	do j=1,cy
		read(102,'(f3.2)')grid_china_out(i,j) 
		write(*,*)grid_china_out(i,j)         
	end do
end do
close(102)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
status=nf_open(''//trim(file_name)//'egts.2012032800_27.ncf',nf_write,ncid)
write(*,*)'get nc'
status=nf_put_att_int(ncid,SDATEID,"SDATE",4,1,SDATE) !!!!change SDATE!!!!!!!!!!!!
status=nf_put_att_int(ncid,STIMEID,"STIME",4,1,STIME) !!!!change STIME!!!!!!!!!!!!
status=nf_get_vara_int(ncid,1,start1,count1,TFLAG)
!!!!!!!!!!!!!!!!!!!!!!!!!!calculate TFLAG times!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
do k=0,nt-1
	day_yu=(k+ih)/24
	TFLAG1=(iy)*1000+SDATE2+day_yu
	if(mod(iy,4)==0)then
		if((SDATE2+day_yu)>366)then
			TFLAG1=(iy+1)*1000+SDATE2+day_yu-366
		endif
	else if((SDATE2+day_yu)>365)then
		TFLAG1=(iy+1)*1000+SDATE2+day_yu-365
	endif
	TFLAG(1,:,k+1)=TFLAG1
	TFLAG(2,:,k+1)=10000*mod((k+ih),24)
enddo
write(*,*) 'TFLAG(1,1,1)',TFLAG(1,1,1),'TFLAG(2,32,1)',TFLAG(2,32,1),'TFLAG(1,32,36)',TFLAG(1,32,36),'TFLAG(2,32,36)',TFLAG(2,32,36)
status=nf_put_vara_int(ncid,1,start1,count1,TFLAG)!!!!!!!!change TFLAG!!!!!!!!!!!!

allocate(CO(cx,cy,nz,nt))
do kk=2,33
	write(*,*)kk	
	if(pic(kk)/=0)then
		status=nf_get_vara_real(ncid,kk,start2,count3,CO)
		
		open(11,file='/public/home/dengtao/models/emis-qinghua/eve_pov_1.txt',status='old')
		do i=1,cx
			do j=1,cy
				read(11,*)grid_gd(i,j)
			end do
		end do
		close(11)
		do i=1,cx
			do j=1,cy
				if (grid_gd(i,j)==1.000000) then  !1 for guangdong
					grid_gd(i,j)=1
				else
					grid_gd(i,j)=0
				end if
			end do
		end do		
		
		
		do i=1,cx
			do j=1,cy
				do k=2,18
					do ii=1,nt
					CO(i,j,k,ii)=(dat_over_1(i,j,pic(kk),ii)*pow_dens(k)+dat_over_3(i,j,pic(kk),ii)*ind_dens(k))*grid_china_in(i,j)+CO(i,j,k,ii)*grid_china_out(i,j)
					!           CO(i,j,k,ii)=dat_over_1(i,j,pic(kk),ii)*pow_dens(k)+dat_over_3(i,j,pic(kk),ii)*ind_dens(k)
				end do
			end do
		end do
	end do
	do i=1,cx
		do j=1,cy
			do ii=1,nt         
				CO(i,j,1,ii)=(dat_over_2(i,j,pic(kk),ii)+dat_over_4(i,j,pic(kk),ii)+dat_over_5(i,j,pic(kk),ii)*grid_gd(i,j)+dat_over_1(i,j,pic(kk),ii)*pow_dens(1)+dat_over_3(i,j,pic(kk),ii)*ind_dens(1))*grid_china_in(i,j)+CO(i,j,1,ii)*grid_china_out(i,j)
				!             CO(i,j,1,ii)=dat_over_2(i,j,pic(kk),ii)+dat_over_1(i,j,pic(kk),ii)*pow_dens(1)+dat_over_3(i,j,pic(kk),ii)*ind_dens(1)
			enddo
		enddo
	enddo           
	CO(:,:,19:nz,:)=0
	
	
	
	status=nf_put_vara_real(ncid,kk,start2,count3,CO)
	end if   
end do           
deallocate(CO,dat_over_1,dat_over_2,dat_over_3)
write(*,*)'write over'
status=nf_close(ncid)        
end
