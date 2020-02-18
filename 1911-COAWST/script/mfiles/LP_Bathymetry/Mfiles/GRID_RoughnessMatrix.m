function RoughMat=GRID_RoughnessMatrix(DEP, MSK)
% RoughMat=GRID_RoughnessMatrix(DEP, MSK)
%
% DEP is the bathymetry of the grid
% MSK is the mask of the grid
[eta_rho, xi_rho]=size(DEP);
RoughMat=zeros(eta_rho, xi_rho);
Umat=[0 1;
      1 0;
      0 -1;
      -1 0];
for iEta=1:eta_rho
  for iXi=1:xi_rho
    if (MSK(iEta, iXi) == 1)
      rough=0;
      for i=1:4
	iEtaB=iEta+Umat(i,1);
	iXiB=iXi+Umat(i,2);
	if (iEtaB >= 1 && iEtaB <= eta_rho && ...
	    iXiB >= 1 && iXiB <= xi_rho && MSK(iEtaB, iXiB) == 1)
	  dep1=DEP(iEta, iXi);
	  dep2=DEP(iEtaB, iXiB);
	  delta=abs(dep1-dep2)/(dep1+dep2);
	  rough=max(rough, delta);
	end;
      end;
      RoughMat(iEta, iXi)=rough;
    end;
  end;
end;
