function NewBathy=GRID_LinearProgrammingSmoothing_rx0_blockconstraint(...
    MSK, Hobs, rx0max, ListVal, ListBlock)
% This is a program for doing linear programming optimization
% of the bathymetry.
% GRID_LinearProgrammingSmoothing_rx0_blockconstraint(...
%          MSK,Hobs,rx0max,ListVal,ListBlock)
%
% ---MSK(eta_rho, xi_rho) is the mask of the grd
%      1 for sea
%      0 for land
% ---Hobs(eta_rho, xi_rho) is the raw depth of the grid
% ---rx0max is the target rx0 roughness factor
% ---ListVal(nbBlock,1) and ListBlock(nbBlock, eta_rho, xi_rho)
%    are the constraints of the system.
[eta_rho, xi_rho]=size(MSK);
[iList, jList, sList, Constant]=...
    GRID_LinProgGetIJS_rx0(MSK, Hobs, rx0max);
%
[iListApp, jListApp, sListApp, ConstantApp]=...
    GRID_LinProgGetIJS_blocksigns(MSK, ListVal, ListBlock);
[iList, jList, sList, Constant]=...
    LP_MergeIJS_listings(...
	iList, jList, sList, Constant, ...
	iListApp, jListApp, sListApp, ConstantApp);
%
TotalNbVert=sum(MSK(:));
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
    if (MSK(iEta, iXi) == 1)
      nbVert=nbVert+1;
      correctionBathy(iEta, iXi)=ValueVar(nbVert);
    end;
  end;
end;
NewBathy=Hobs+correctionBathy;
