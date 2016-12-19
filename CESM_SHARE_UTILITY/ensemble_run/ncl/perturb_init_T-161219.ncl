;NCL script to perturb the initial T field of an ensemble run.

begin
    b = systemfunc("cp *.org B2000_f09_CAM5PM_spin-up.cam.i.0111-01-01-00000.nc"
    a = addfile("B2000_f09_CAM5PM_spin-up.cam.i.0111-01-01-00000.nc","w")

    t = a->T               ; degC
    dim= dimsizes(t(:,0,:,:))
    print(t(:,0,{0},{120}))
    rnd=random_normal(0,0.2,dim)
    t(:,0,:,:)=t(:,0,:,:)-rnd
    print(t(:,0,{0},{120}))
    a->T = t               ; overwrite
end

