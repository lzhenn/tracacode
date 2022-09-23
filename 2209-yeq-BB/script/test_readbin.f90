program test_bin
    real   data(380,320,38,24)
    open (11,file="/home/lzhenn/temp/test.bin",form="unformatted", access="sequential")
    read (11) data
    write (*,*) data(201,101,2,2)
end program test_bin