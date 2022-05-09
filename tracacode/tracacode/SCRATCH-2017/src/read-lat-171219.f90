program readlatlon
    implicit none
    integer ios, ii
    real*4 lat

    open(unit=20, file="/home/yangsong3/L_Zealot/data-mirror/obv/L_Zealot/IMS_Snow/imslat_24km.bin", access="direct",status="old",recl=1,iostat=ios,convert="little_endian")
    if ( ios /= 0 ) then
        write(*,*) "fail in openning the file"
        stop
    end if
    do ii = 1,1024*512
        read(unit=20,rec=ii) lat
        write(*,*) lat
    end do
end program
