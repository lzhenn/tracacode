program change_temp_salt
    implicit none
    integer, parameter :: fin = 100, fout= 101
    integer, parameter :: nlen = 384*320*60*2
    integer :: ii
    integer :: status = 0
    double precision :: tracer(nlen)=0.
    real(kind=8) :: tracer0(320,384,60,2)=0.
!    character(len=256) :: filename="/users/yangsong3/CESM/input/ocn/pop/gx1v6/ic/ts_PHC2_jan_ic_gx1v6_20090205.ieeer8"
    character(len=256) :: filename="/users/yangsong3/CESM/input/ocn/pop/gx1v6/ic/ts_surf_aqua_PHC2_jan_ic_gx1v6_20180613.ieeer8"
    character(len=256) :: outname="/users/yangsong3/CESM/input/ocn/pop/gx1v6/grid/region_mask_aqua_20180612.ieeei4"
    
    open(unit=fin, file=filename, form="unformatted", access="direct", recl=nlen*4, convert="big_endian")
    read(fin, rec=1) tracer
    close(fin)
    
    tracer0=reshape(tracer,(/320,384,60,2/))

    write(*,*)    (tracer0(:,50,1,2))

end program
