function RetBathy=GRID_LaplacianSelectSmooth_rx0(MSK, Hobs, rx0max)
% GRID_LaplacianSelectSmooth(MSK, Hobs, rx0max)
%
% ---MSK(eta_rho,xi_rho) is the mask of the grd
%      1 for sea
%      0 for land
% ---Hobs(eta_rho,xi_rho) is the raw depth of the grid
% ---rx0max is the target rx0 roughness factor




[eta_rho, xi_rho]=size(Hobs);
disp(['eta_rho=' num2str(eta_rho) '  xi_rho=' num2str(xi_rho)]);

ListNeigh=[1 0;
	   0 1;
	   -1 0;
	   0 -1];
RetBathy=Hobs;
tol=0.00001;
WeightMatrix=zeros(eta_rho, xi_rho);
for iEta=1:eta_rho
  for iXi=1:xi_rho
    WeightSum=0;
    for ineigh=1:4
      iEtaN=iEta+ListNeigh(ineigh,1);
      iXiN=iXi+ListNeigh(ineigh,2);
      if (iEtaN <= eta_rho && iEtaN >= 1 && ...
	  iXiN <= xi_rho && iXiN >= 1 && ...
	  MSK(iEtaN, iXiN) == 1)
	WeightSum=WeightSum+1;
      end;
    end;
    WeightMatrix(iEta, iXi)=WeightSum;
  end;
end;



NumberDones=zeros(eta_rho, xi_rho);
while(true)
  RoughMat=GRID_RoughnessMatrix(RetBathy, MSK);
  Kbefore=find(RoughMat > rx0max);
  nbPtBefore=size(Kbefore, 1);
  realR=max(RoughMat(:));
  %
  TheCorrect=zeros(eta_rho,xi_rho);
  IsFinished=1;
  nbPointMod=0;
  AdditionalDone=zeros(eta_rho, xi_rho);
  for iEta=1:eta_rho
    for iXi=1:xi_rho
      Weight=0;
      WeightSum=0;
      for ineigh=1:4
	iEtaN=iEta+ListNeigh(ineigh,1);
	iXiN=iXi+ListNeigh(ineigh,2);
	if (iEtaN <= eta_rho && iEtaN >= 1 && ...
	    iXiN <= xi_rho && iXiN >= 1 && ...
	    MSK(iEtaN, iXiN) == 1)
	  Weight=Weight+RetBathy(iEtaN,iXiN);
	  AdditionalDone(iEtaN, iXiN)=AdditionalDone(iEtaN, iXiN)+...
	      NumberDones(iEta, iXi);
	end;
      end;
      TheWeight=WeightMatrix(iEta, iXi);
      WeDo=0;
      if (TheWeight > tol)
	if (RoughMat(iEta,iXi) > rx0max)
	  WeDo=1;
	end;
	if (NumberDones(iEta, iXi) > 0)
	  WeDo=1;
	end;
      end;
      if (WeDo == 1)
	IsFinished=0;
	TheDelta=(Weight-TheWeight*RetBathy(iEta,iXi))/(2*TheWeight);
	TheCorrect(iEta,iXi)=TheCorrect(iEta,iXi)+TheDelta;
	nbPointMod=nbPointMod+1;
	NumberDones(iEta, iXi)=1;
      end;
    end;
  end;
  NumberDones=NumberDones+AdditionalDone;
  RetBathy=RetBathy+TheCorrect;
  NewRoughMat=GRID_RoughnessMatrix(RetBathy, MSK);
  Kafter=find(NewRoughMat > rx0max);
  nbPtAfter=size(Kafter, 1);
  TheProd=(RoughMat > rx0max).*(NewRoughMat > rx0max);
  nbPtInt=sum(TheProd(:));
  if (nbPtInt == nbPtAfter && nbPtBefore == nbPtAfter)
    eStr=' no erase';
  else
    eStr='';
    NumberDones=zeros(eta_rho, xi_rho);
  end;
  disp(['current r=' num2str(realR) ...
	'  nbPointMod=' num2str(nbPointMod) eStr]);
  if (IsFinished == 1)
    break;
  end;
end;
