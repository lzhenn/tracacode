program change_bathymetry 
    implicit none
    integer, parameter :: fin = 100, fout= 101
    integer, parameter :: nlen = 122880
    integer :: ii
    integer :: status = 0
    integer :: bath(nlen)=0
    integer :: bath0(320,384)=0
    character(len=256) :: filename="/home/lzhenn/temp/Drake_Closure/topography_20210211.ieeei4"
    character(len=256) :: outname="/home/lzhenn/temp/NO_LSD/topography_20221030.ieeei4"
    
    open(unit=fin, file=filename, form="unformatted", access="direct", recl=nlen, convert="big_endian")
    read(fin, rec=1) bath 
    close(fin)
    
    do ii = 1, nlen
        if (bath(ii)<1) then
            bath(ii)=1
        end if
    end do
    bath0=reshape(bath,(/320,384/))
    bath0(:,1:2)=0
    bath0(:,383:384)=0
    open(unit=fout, file=outname, form="unformatted", access="direct", action="write", recl=nlen, convert="big_endian")
    write(fout, rec=1) bath0
    close(fout)

end program