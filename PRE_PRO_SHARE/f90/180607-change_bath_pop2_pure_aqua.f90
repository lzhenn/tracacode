program change_bathymetry 
    implicit none
    integer, parameter :: fin = 100, fout= 101
    integer, parameter :: nlen = 122880
    integer :: ii
    integer :: status = 0
    integer :: bath(nlen)=0
    integer :: bath0(320,384)=0
    character(len=256) :: filename="/users/yangsong3/CESM/input/ocn/pop/gx1v6/grid/topography_20090204.ieeei4"
    character(len=256) :: outname="/users/yangsong3/CESM/input/ocn/pop/gx1v6/grid/topography_pure_aqua_polar_20180607.ieeei4"
    
    open(unit=fin, file=filename, form="unformatted", access="direct", recl=nlen, convert="big_endian")
    read(fin, rec=1) bath 
    close(fin)
   
    bath=25
    bath0=reshape(bath,(/320,384/))
    bath0(:,1:2)=0
    bath0(:,3)=5
    bath0(:,4)=10
    bath0(:,5)=18
    bath0(:,383:384)=0
    bath0(:,382)=5
    bath0(:,381)=10
    bath0(:,380)=18
    open(unit=fout, file=outname, form="unformatted", access="direct", action="write", recl=nlen, convert="big_endian")
    write(fout, rec=1) bath0
    close(fout)

end program
