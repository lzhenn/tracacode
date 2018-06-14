program change_bathymetry 
    implicit none
    integer, parameter :: fin = 100, fout= 101
    integer, parameter :: nlen = 122880
    integer :: ii
    integer :: status = 0
    integer :: idx(nlen)=0
    integer :: idx0(320,384)
    character(len=256) :: filename="/users/yangsong3/CESM/input/ocn/pop/gx1v6/grid/region_mask_20090205.ieeei4"
    character(len=256) :: outname="/users/yangsong3/CESM/input/ocn/pop/gx1v6/grid/region_mask_aqua_polar_20180612.ieeei4"
    
    open(unit=fin, file=filename, form="unformatted", access="direct", recl=nlen, convert="big_endian")
    read(fin, rec=1) idx 
    close(fin)
    
    idx(1:61440)=1
    idx(61441:)=2
    idx0=reshape(idx,(/320,384/))
    idx0(:,1:2)=0
    idx0(:,383:384)=0
    open(unit=fout, file=outname, form="unformatted", access="direct", action="write", recl=nlen, convert="big_endian")
    write(fout, rec=1) idx0
    close(fout)

end program
