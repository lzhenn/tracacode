function NewBathy=GRID_LinearProgrammingSmoothing_rx0_fixed(...
    MSK, Hobs, PRS, rx0max)
% this is a program for doing linear programming optimization
% of the bathymetry with some point being fixed.
% GRID_LinearProgrammingSmoothing_fixed(MSK, Hobs, PRS, r)
%
% ---MSK(eta_rho,xi_rho) is the mask of the grd
%      1 for sea
%      0 for land
% ---Hobs(eta_rho,xi_rho) is the raw depth of the grid
% ---PRS(eta_rho,xi_rho) is the array for preservation status.
%      1 for preserving depth
%      0 for not preserving depth
% ---rx0max is the target rx0 roughness factor
PRSwork=PRS;
K=find(MSK == 0 & PRS);
PRSwork(K)=0;
[eta_rho, xi_rho]=size(MSK);
[iList, jList, sList, Constant]=...
    GRID_LinProgGetIJSfixed_rx0(MSK, Hobs, PRSwork, rx0max);
%
Set1=find(MSK == 1);
Set2=find(PRSwork == 0);
Set3=intersect(Set1, Set2);
TotalNbVert=size(Set3, 1);
disp(['TotalNbVert=' num2str(TotalNbVert)]);
%
ObjectiveFct=zeros(2*TotalNbVert, 1);
for iVert=1:TotalNbVert
  ObjectiveFct(TotalNbVert+iVert,1)=1;
end;
[ValueFct, ValueVar, testfeasibility]=...
    LP_SolveLinearProgram(...
	iList, jList, sList, Constant, ObjectiveFct);
if (testfeasibility == 0)
  NewBathy=NaN*ones(eta_rho, xi_rho);
  return;
end;
%
correctionBathy=zeros(eta_rho, xi_rho);
nbVert=0;
for iEta=1:eta_rho
  for iXi=1:xi_rho
    if (MSK(iEta, iXi) == 1 && PRSwork(iEta, iXi) == 0)
      nbVert=nbVert+1;
      correctionBathy(iEta, iXi)=ValueVar(nbVert);
    end;
  end;
end;
NewBathy=Hobs+correctionBathy;
