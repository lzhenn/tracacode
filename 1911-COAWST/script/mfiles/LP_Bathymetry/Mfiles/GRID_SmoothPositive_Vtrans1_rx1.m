function RetBathy=GRID_SmoothPositive_Vtrans1_rx1(...
    MSK, Hobs, rx1max, Scoord, Ccoord, hc)
% This program optimizes the bathymetry for the rx0 factor by increasing it.
% GRID_SmoothPositive_rx1(MSK, Hobs, rx1max, Scoord, Ccoord, hc)
%
% ---MSK(eta_rho,xi_rho) is the mask of the grid
%      1 for sea
%      0 for land
% ---Hobs(eta_rho,xi_rho) is the raw depth of the grid
% ---rx1max is the target rx1 roughness factor
% ---Scoord, Ccoord and hc is the vertical parameterization.

Ksea=find(MSK == 0);
HobsSel=Hobs(Ksea);
mindep=min(HobsSel(:));
disp(['mindep=' num2str(mindep) '  hc=' num2str(hc)]);
if (hc > mindep)
  disp('The minimal depth is smaller than hc');
  disp('That is a problem');
  error('Please correct');
end;
minS=min(Scoord);
maxS=max(Scoord);
minC=min(Ccoord);
maxC=max(Ccoord);
tol=0.0001;
%if (minS < -tol || maxS > 1+tol || ...
%    minC < -tol || maxC > 1+tol)
%  disp('The coordinates Scoord and Ccoord are not correct');
%  disp('Please put them between 0 and 1');
%  error('Please correct');
%end;

N=size(Scoord, 1)-1;
disp(['N=' num2str(N)]);
fK=zeros(N+1, 1);
gK=zeros(N+1, 1);
for i=1:N+1
  fK(i,1)=Scoord(i,1)-Ccoord(i,1);
  gK(i,1)=Ccoord(i,1);
end;
PhiK=zeros(N, 1);
PsiK=zeros(N, 1);
for i=1:N
  PhiK(i,1)=rx1max*2*hc*(fK(i,1)-fK(i+1,1))/(gK(i+1,1)+gK(i,1));
  PsiK(i,1)=rx1max*(gK(i,1)-gK(i+1,1))/(gK(i+1,1)+gK(i,1));
%  disp(['i=' num2str(i) '  Phi=' num2str(PhiK(i,1)) ...
%	'  Psi=' num2str(PsiK(i,1))]);
end;
minPsi=min(PsiK);
maxPsi=max(PsiK);
%disp(['minPsi=' num2str(minPsi) '   maxPsi=' num2str(maxPsi)]);


[eta_rho, xi_rho]=size(Hobs);
ListNeigh=[1 0;
	   0 1;
	   -1 0;
	   0 -1];
RetBathy=Hobs;

nbModif=0;
tol=0.000001;
while(true)
  IsFinished=1;
  for iEta=1:eta_rho
    for iXi=1:xi_rho
      if (MSK(iEta, iXi) == 1)
	for ineigh=1:4
	  iEtaN=iEta+ListNeigh(ineigh,1);
	  iXiN=iXi+ListNeigh(ineigh,2);
	  if (iEtaN <= eta_rho && iEtaN >= 1 && ...
	      iXiN <= xi_rho && iXiN >= 1 && ...
	      MSK(iEtaN, iXiN) == 1)
	    for i=1:N
	      rReal=PsiK(i,1);
	      phiV=PhiK(i,1);
	      LowerBound=RetBathy(iEtaN, iXiN)*(1-rReal)/(1+rReal)-phiV/(1+rReal);
	      if (RetBathy(iEta,iXi) - LowerBound < -tol)
		IsFinished=0;
		RetBathy(iEta, iXi)=LowerBound;
		nbModif=nbModif+1;
	      end;
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
disp(['     nbModif=' num2str(nbModif)]);
