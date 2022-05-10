;NCL script to perturb the initial T field of an ensemble run.



begin
    if (.not. isvar("pre_dir") .or. .not. isvar("t_purb")) then 
            print("At least one argument has not been assigned, cannot continue!");
            exit
        end if

    ; Reset random seeds
    rseed1 = toint(systemfunc(" date +%s"))
    rseed2 = toint((12345l*rseed1)%2147483398l)
    random_setallseed(rseed1, rseed2)
    
    ; Read and change the initial files
    a = addfile(pre_dir,"w")

    t = a->T               ; degC
    dim= dimsizes(t(:,0,:,:))
    print("One Point Before pert: "+t(:,0,{0},{120}))
    rnd=random_normal(0,t_purb,dim)
    t(:,0,:,:)=t(:,0,:,:)+rnd
    print("One Point After pert:"+t(:,0,{0},{120}))
    a->T = t               ; overwrite
end

