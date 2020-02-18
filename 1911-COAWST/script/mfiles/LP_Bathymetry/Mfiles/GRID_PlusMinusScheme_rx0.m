function [RetBathy, HmodifVal, ValueFct]=GRID_PlusMinusScheme_rx0(...
    MSK, Hobs, rx0max, AreaMatrix)
% [RetBathy, HmodifVal]=GRID_PlusMinusScheme_rx0(...
%    MSK, Hobs, rx0max, AreaMatrix)
%
% ---MSK(eta_rho,xi_rho) is the mask of the grid
%      1 for sea
%      0 for land
% ---Hobs(eta_rho,xi_rho) is the raw depth of the grid
% ---rx0max is the target rx0 roughness factor
% ---AreaMatrix(eta_rho,xi_rho) is the matrix of areas at
% rho-points.

[eta_rho, xi_rho]=size(Hobs);
if (nargin < 4)
  AreaMatrix=ones(eta_rho, xi_rho);
end;
ListNeigh=[1 0;
	   0 1;
	   -1 0;
	   0 -1];
RetBathy=Hobs;
%
HmodifVal=0;
TheMultiplier=(1-rx0max)/(1+rx0max);
tol=0.000001;
ValueFct=0;
while(true)
  IsFinished=1;
  for iEta=1:eta_rho
    for iXi=1:xi_rho
      if (MSK(iEta, iXi) == 1)
	Area=AreaMatrix(iEta, iXi);
	for ineigh=1:4
	  iEtaN=iEta+ListNeigh(ineigh,1);
	  iXiN=iXi+ListNeigh(ineigh,2);
	  if (iEtaN <= eta_rho && iEtaN >= 1 && ...
	      iXiN <= xi_rho && iXiN >= 1 && ...
	      MSK(iEtaN, iXiN) == 1)
	    AreaN=AreaMatrix(iEtaN, iXiN);
	    LowerBound=RetBathy(iEtaN, iXiN)*TheMultiplier;
	    if (RetBathy(iEta,iXi) - LowerBound < -tol)
	      IsFinished=0;
	      h=(TheMultiplier*RetBathy(iEtaN, iXiN)-...
		 RetBathy(iEta, iXi))/(AreaN+TheMultiplier*Area);
	      RetBathy(iEta, iXi)=RetBathy(iEta, iXi)+AreaN*h;
	      RetBathy(iEtaN, iXiN)=RetBathy(iEtaN, iXiN)-Area*h;
	      HmodifVal=HmodifVal+abs(h);
	      ValueFct=ValueFct+abs(h)*(Area+AreaN);
	    end;
	  end;
	end;
      end;
    end;
  end;
  if (IsFinished == 1)
    break;
  end;
end;
%
H=AreaMatrix.*Hobs.*MSK;
TheBathymetry1=sum(H(:));
H=AreaMatrix.*RetBathy.*MSK;
TheBathymetry2=sum(H(:));
DeltaBathymetry=TheBathymetry1-TheBathymetry2;
disp(['DeltaBathymetry=' num2str(DeltaBathymetry)]);
