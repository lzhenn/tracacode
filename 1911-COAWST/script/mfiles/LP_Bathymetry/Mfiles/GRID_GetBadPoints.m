function MSKbad=GRID_GetBadPoints(MSK_rho, DEP_rho, rx0max)
RetBathy=GRID_SmoothPositive_rx0(MSK_rho, DEP_rho, rx0max);
K1=find(RetBathy ~= DEP_rho);

[eta_rho, xi_rho]=size(DEP_rho);
MSKbad=zeros(eta_rho, xi_rho);
MSKbad(K1)=1;
