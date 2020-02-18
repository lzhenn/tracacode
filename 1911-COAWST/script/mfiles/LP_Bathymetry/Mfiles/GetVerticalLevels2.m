function [Z_r, Z_w]=GetVerticalLevels2(DEP_rho, MSK_rho, ARVD)
    
% [Z_r, Z_w]=GetVerticalLevels2(DEP_rho, MSK_rho, ARVD)
%
% Z_r, Z_w are vertical Z level (negative values)
% DEP_rho is depth at rho points
% MSK_rho is mask at rho points
% (it works also for u points, vpoints, psi-points)
%
% ARVD is a record containing the description of vertical 
% stratification. For example:
% ARVD.Vtransform=2;
% ARVD.Vstretching=1;
% ARVD.ThetaS=4;
% ARVD.ThetaB=0.35;
% ARVD.N=30;
% ARVD.hc=10;



[Sc_w, Cs_w, Sc_r, Cs_r]=GRID_GetSc_Cs_V2(ARVD);
N=ARVD.N;

[eta_rho, xi_rho]=size(DEP_rho);
DEPwork=DEP_rho;
K=find(MSK_rho == 0);
DEPwork(K)=3;


Z_r=zeros(N, eta_rho, xi_rho);
Z_w=zeros(N+1, eta_rho, xi_rho);
if (ARVD.Vtransform == 1)
  for i=1:N
    Z_r(i,:,:)=ARVD.hc*Sc_r(i,1) + (DEPwork - ARVD.hc)*Cs_r(i,1);
  end;
  for i=1:N+1
    Z_w(i,:,:)=ARVD.hc*Sc_w(i,1) + (DEPwork - ARVD.hc)*Cs_w(i,1);
  end;
elseif (ARVD.Vtransform == 2)
  for i=1:N
    Zo=(ARVD.hc*Sc_r(i,1) + DEPwork*Cs_r(i,1))./(ARVD.hc+DEPwork);
    Z_r(i,:,:)=Zo.*DEPwork;
  end;
  for i=1:N+1
    Zo=(ARVD.hc*Sc_w(i,1) + DEPwork*Cs_w(i,1))./(ARVD.hc+DEPwork);
    Z_w(i,:,:)=Zo.*DEPwork;
  end;
else
  disp('Vtransform wrongly assigned');
  error('Please correct');
end;
