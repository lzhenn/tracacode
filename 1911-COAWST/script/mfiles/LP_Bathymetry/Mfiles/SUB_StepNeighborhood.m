function ListNeighRet=SUB_StepNeighborhood(MSK_rho, iEta, iXi, Kdist)

[eta_rho, xi_rho]=size(MSK_rho);
MaxSiz=(2*Kdist+1)*(2*Kdist+1);
ListNeigh=zeros(MaxSiz,2);
ListStatus=-1*ones(MaxSiz,1);
ListKeys=zeros(MaxSiz,1);

eKey=iEta + (eta_rho+1)*iXi;
ListNeigh(1,1)=iEta;
ListNeigh(1,2)=iXi;
ListStatus(1,1)=0;
ListKeys(1,1)=eKey;
nbPt=1;

List4dir=[1 0;
	  0 1;
	  -1 0;
	  0 -1];
for iK=1:Kdist
  nbPtOld=nbPt;
  for iPt=1:nbPtOld
    if (ListStatus(iPt,1) == iK-1)
      iEta=ListNeigh(iPt,1);
      iXi=ListNeigh(iPt,2);
      for ineigh=1:4
	iEtaN=iEta+List4dir(ineigh,1);
	iXiN=iXi+List4dir(ineigh,2);
	if (iEtaN <= eta_rho && iEtaN >= 1 && ...
	    iXiN <= xi_rho && iXiN >= 1 && ...
	    MSK_rho(iEtaN, iXiN) == 1)
	  eKeyN=iEtaN + (eta_rho+1)*iXiN;
	  Kf=find(ListKeys == eKeyN);
	  nbKf=size(Kf,1);
	  if (nbKf == 0)
	    nbPt=nbPt+1;
	    ListNeigh(nbPt,1)=iEtaN;
	    ListNeigh(nbPt,2)=iXiN;
	    ListStatus(nbPt,1)=iK;
	    ListKeys(nbPt,1)=eKeyN;
	  end;
	end;
      end;
    end;
  end;
end;
ListNeighRet=ListNeigh(2:nbPt, 1:2);
