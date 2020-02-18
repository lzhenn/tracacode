function NewBathy=GRID_ScaledLinearProgrammingSmoothing_rx0(...
    MSK, Hobs, rx0max, SignConst, AmpConst)
% GRID_ScaledLinearProgrammingSmoothing(MSK, Hobs, r, SignConst, AmpConst)
%
% ---MSK(eta_rho,xi_rho) is the mask of the grd
%      1 for sea
%      0 for land
% ---Hobs(eta_rho,xi_rho) is the raw depth of the grid
% ---rx0max is the target rx0 roughness factor
% ---SignConst(eta_rho,xi_rho) matrix of 0, +1, -1
%      +1  only bathymetry increase are allowed.
%      -1  only bathymetry decrease are allowed.
%      0   increase and decrease are allowed.
%      (put 0 if you are indifferent)
% ---AmpConst(eta_rho,xi_rho)  matrix of reals.
%      coefficient alpha such that the new bathymetry should
%      satisfy to  |h^{new} - h^{raw}| <= alpha h^{old}
%      (put 10000 if you are indifferent)
[eta_rho, xi_rho]=size(Hobs);
[iList, jList, sList, Constant]=...
    GRID_LinProgGetIJS_rx0(MSK, Hobs, rx0max, SignConst, AmpConst);

TotalNbVert=sum(MSK(:));
ObjectiveFct=zeros(2*TotalNbVert, 1);
nbVert=0;
for iEta=1:eta_rho
  for iXi=1:xi_rho
    if (MSK(iEta, iXi) == 1)
      nbVert=nbVert+1;
      ObjectiveFct(TotalNbVert+nbVert,1)=1/Hobs(iEta, iXi);
    end;
  end;
end;
[ValueFct, ValueVar]=LP_SolveLinearProgram(...
    iList, jList, sList, Constant, ObjectiveFct);


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

