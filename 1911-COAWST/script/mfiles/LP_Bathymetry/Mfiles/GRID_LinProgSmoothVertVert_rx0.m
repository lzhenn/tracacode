function [NewBathy, TotalHmodif]=GRID_LinProgSmoothVertVert_rx0(...
    MSK_rho, Hobs, rx0max, AreaMatrix)
% [NewBathy, TotalHmodif]=GRID_LinProgSmoothVertVert_rx0(...
%        MSK_rho, Hobs, rx0max, AreaMatrix)
%
% ---MSK_rho(eta_rho,xi_rho) is the mask of the grd
%      1 for sea
%      0 for land
% ---Hobs(eta_rho,xi_rho) is the raw depth of the grid
% ---rx0max is the target rx0 roughness factor
% ---AreaMatrix(eta_rho,xi_rho) matrix of areas of the model

[eta_rho, xi_rho]=size(Hobs);
disp(['eta_rho=' num2str(eta_rho) '  xi_rho=' num2str(xi_rho)]);
%
KrhoWet=find(MSK_rho == 1);
nbWetRho=size(KrhoWet,1);
disp(['nbWet Rho points=' num2str(nbWetRho)]);
MinArea=min(AreaMatrix(KrhoWet));
%
IndexRhoPoints=zeros(eta_rho,xi_rho);
iPt=0;
for iEta=1:eta_rho
  for iXi=1:xi_rho
    if (MSK_rho(iEta, iXi) == 1)
      iPt=iPt+1;
      IndexRhoPoints(iEta, iXi)=iPt;
    end;
  end;
end;
disp('IndexRhoPoints built');
%
MSK_u=MSK_rho(1:eta_rho, 2:xi_rho).*MSK_rho(1:eta_rho, 1:xi_rho-1);
MSK_v=MSK_rho(2:eta_rho, 1:xi_rho).*MSK_rho(1:eta_rho-1, 1:xi_rho);
[eta_u, xi_u]=size(MSK_u);
[eta_v, xi_v]=size(MSK_v);
disp(['eta_rho=' num2str(eta_rho) '  xi_rho=' num2str(xi_rho)]);
disp(['eta_u=' num2str(eta_u) '  xi_u=' num2str(xi_u)]);
disp(['eta_v=' num2str(eta_v) '  xi_v=' num2str(xi_v)]);
%
KuWet=find(MSK_u == 1);
KvWet=find(MSK_v == 1);
nbUWet=size(KuWet(:),1);
nbVWet=size(KvWet(:),1);
TotalNbVert=nbUWet+nbVWet;
disp(['nb Uwet=' num2str(nbUWet), '  nb Vwet=' num2str(nbVWet)]);
IndexUPoints=zeros(eta_u, xi_u);
iPt=0;
for iEta=1:eta_u
  for iXi=1:xi_u
    if (MSK_u(iEta, iXi) == 1)
      iPt=iPt+1;
      IndexUPoints(iEta, iXi)=iPt;
    end;
  end;
end;
disp('IndexUPoints has been built');
IndexVPoints=zeros(eta_v, xi_v);
for iEta=1:eta_v
  for iXi=1:xi_v
    if (MSK_v(iEta, iXi) == 1)
      iPt=iPt+1;
      IndexVPoints(iEta, iXi)=iPt;
    end;
  end;
end;
disp('IndexVPoints has been built');
%
IncidenceRhoUeta=zeros(nbWetRho, 2);
IncidenceRhoUxi=zeros(nbWetRho, 2);
IncidenceRhoUcoef=zeros(nbWetRho, 2);
ListIncRhoU=zeros(nbWetRho, 1);
for iEta=1:eta_rho
  for iXi=1:xi_rho-1
    if (MSK_rho(iEta, iXi) == 1 && MSK_rho(iEta, iXi+1) == 1)
      iPt1=IndexRhoPoints(iEta, iXi);
      iPt2=IndexRhoPoints(iEta, iXi+1);
      %
      inc1=ListIncRhoU(iPt1,1)+1;
      IncidenceRhoUeta(iPt1,inc1)=iEta;
      IncidenceRhoUxi(iPt1,inc1)=iXi;
      IncidenceRhoUcoef(iPt1,inc1)=1;
      ListIncRhoU(iPt1,1)=inc1;
      % yes we are serious about iXi and not iXi+1
      inc2=ListIncRhoU(iPt2,1)+1;
      IncidenceRhoUeta(iPt2,inc2)=iEta;
      IncidenceRhoUxi(iPt2,inc2)=iXi;
      IncidenceRhoUcoef(iPt2,inc2)=-1;
      ListIncRhoU(iPt2,1)=inc2;
    end;
  end;
end;
disp('IncidenceRhoU built');

IncidenceRhoVeta=zeros(nbWetRho, 2);
IncidenceRhoVxi=zeros(nbWetRho, 2);
IncidenceRhoVcoef=zeros(nbWetRho, 2);
ListIncRhoV=zeros(nbWetRho, 1);
for iEta=1:eta_rho-1
  for iXi=1:xi_rho
    if (MSK_rho(iEta, iXi) == 1 && MSK_rho(iEta+1, iXi) == 1)
      iPt1=IndexRhoPoints(iEta, iXi);
      iPt2=IndexRhoPoints(iEta+1, iXi);
      %
      inc1=ListIncRhoV(iPt1,1)+1;
      IncidenceRhoVeta(iPt1,inc1)=iEta;
      IncidenceRhoVxi(iPt1,inc1)=iXi;
      IncidenceRhoVcoef(iPt1,inc1)=1;
      ListIncRhoV(iPt1,1)=inc1;
      %
      inc2=ListIncRhoV(iPt2,1)+1;
      IncidenceRhoVeta(iPt2,inc2)=iEta;
      IncidenceRhoVxi(iPt2,inc2)=iXi;
      IncidenceRhoVcoef(iPt2,inc2)=-1;
      ListIncRhoV(iPt2,1)=inc2;
    end;
  end;
end;
disp('IncidenceRhoV built');


% TotalNbConstant is the number of inequalities
% TotalNbEntry is the number of non-zero entries
TotalNbConstant=(2*2+2+2)*eta_rho*xi_rho;
TotalNbEntry=(2*2*2*2*2+2*2+2*2)*eta_rho*xi_rho;
% this is an upper bound

nbConst=0;
nbEntry=0;
Constant=zeros(TotalNbConstant,1);
iList=zeros(TotalNbEntry,1);
jList=zeros(TotalNbEntry,1);
sList=zeros(TotalNbEntry,1);



% iterate over all pairs (iEta1, iXi1)   (iEta2, iXi2)
% of adjacent wet nodes.
for iEta1=1:eta_rho
  for iXi1=1:xi_rho
    for iDir=1:2
      if (iDir == 1)
	AddEta=0;
	AddXi=1;
      else
	AddEta=1;
	AddXi=0;
      end;
      iEta2=iEta1+AddEta;
      iXi2=iXi1+AddXi;
      if (iEta2 <= eta_rho && iXi2 <= xi_rho && ...
	  MSK_rho(iEta1, iXi1) == 1 && MSK_rho(iEta2, iXi2) == 1)
	for iSel=1:2
	  nbConst=nbConst+1;
	  if (iSel == 1)
	    iEtaW1=iEta1;
	    iXiW1=iXi1;
	    iEtaW2=iEta2;
	    iXiW2=iXi2;
	  else
	    iEtaW1=iEta2;
	    iXiW1=iXi2;
	    iEtaW2=iEta1;
	    iXiW2=iXi1;
	  end
	  iPt1=IndexRhoPoints(iEtaW1,iXiW1);
	  iPt2=IndexRhoPoints(iEtaW2,iXiW2);
	  Area1=AreaMatrix(iEtaW1, iXiW1);
	  Area2=AreaMatrix(iEtaW2, iXiW2);
	  % there is some code to be written for that part
	  %
	  CST=(1+rx0max)*Hobs(iEtaW1,iXiW1)+(rx0max-1)*Hobs(iEtaW2, iXiW2);
	  Constant(nbConst,1)=CST;
	  for iS=1:2
	    if (iS == 1)
	      TheVal=-rx0max-1;
	      iPt=iPt1;
	      eArea=Area1/MinArea;
	    else
	      TheVal=1-rx0max;
	      iPt=iPt2;
	      eArea=Area2/MinArea;
	    end
	    nbU=ListIncRhoU(iPt,1);
	    for idx=1:nbU
	      iEta=IncidenceRhoUeta(iPt,idx);
	      iXi=IncidenceRhoUxi(iPt,idx);
	      TheCoef=IncidenceRhoUcoef(iPt,idx);
	      iPtU=IndexUPoints(iEta, iXi);
	      nbEntry=nbEntry+1;
	      iList(nbEntry,1)=nbConst;
	      jList(nbEntry,1)=iPtU;
	      sList(nbEntry,1)=TheVal*TheCoef/eArea;
	    end
	    nbV=ListIncRhoV(iPt,1);
	    for idx=1:nbV
	      iEta=IncidenceRhoVeta(iPt,idx);
	      iXi=IncidenceRhoVxi(iPt,idx);
	      TheCoef=IncidenceRhoVcoef(iPt,idx);
	      iPtV=IndexVPoints(iEta, iXi);
	      nbEntry=nbEntry+1;
	      iList(nbEntry,1)=nbConst;
	      jList(nbEntry,1)=iPtV;
	      sList(nbEntry,1)=TheVal*TheCoef/eArea;
	    end
	  end
	end
      end
    end;
  end;
end;
disp('First part of inequalities built');
disp(['nbConst=' num2str(nbConst)]);
%
for iEta=1:eta_u
  for iXi=1:xi_u
    if (MSK_u(iEta, iXi) == 1)
      iPtU=IndexUPoints(iEta, iXi);
      %
      nbConst=nbConst+1;
      Constant(nbConst,1)=0;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=nbUWet+nbVWet+iPtU;
      sList(nbEntry,1)=-1;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=iPtU;
      sList(nbEntry,1)=1;
      %
      nbConst=nbConst+1;
      Constant(nbConst,1)=0;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=nbUWet+nbVWet+iPtU;
      sList(nbEntry,1)=-1;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=iPtU;
      sList(nbEntry,1)=-1;
    end
  end
end
disp('Second part has been done');
for iEta=1:eta_v
  for iXi=1:xi_v
    if (MSK_v(iEta, iXi) == 1)
      iPtV=IndexVPoints(iEta, iXi);
      %
      nbConst=nbConst+1;
      Constant(nbConst,1)=0;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=nbUWet+nbVWet+iPtV;
      sList(nbEntry,1)=-1;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=iPtV;
      sList(nbEntry,1)=1;
      %
      nbConst=nbConst+1;
      Constant(nbConst,1)=0;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=nbUWet+nbVWet+iPtV;
      sList(nbEntry,1)=-1;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=iPtV;
      sList(nbEntry,1)=-1;
    end
  end
end
disp('Third part of inequalities built');
disp(['nbConst=' num2str(nbConst) ...
      '   TotalNbConstant=' num2str(TotalNbConstant)]);
disp(['nbEntry=' num2str(nbEntry) ...
      '   TotalNbEntry=' num2str(TotalNbEntry)]);

ObjectiveFct=zeros(2*TotalNbVert, 1);
for iVert=1:TotalNbVert
  ObjectiveFct(TotalNbVert+iVert,1)=1;
end;
disp('Calling the linear programming program');
ConstantRed=Constant(1:nbConst,1);
iListRed=iList(1:nbEntry,1);
jListRed=jList(1:nbEntry,1);
sListRed=sList(1:nbEntry,1);
[ValueFct, ValueVar]=LP_SolveLinearProgram(...
    iListRed, jListRed, sListRed, ConstantRed, ObjectiveFct);


TotalHmodif=0;
corrBathy=zeros(eta_rho, xi_rho);
for iEta1=1:eta_u
  for iXi1=1:xi_u
    iEta2=iEta1;
    iXi2=iXi1+1;
    Area1=AreaMatrix(iEta1,iXi1);
    Area2=AreaMatrix(iEta2,iXi2);
    if (MSK_u(iEta1, iXi1) == 1)
      iPtU=IndexUPoints(iEta1, iXi1);
      corrBathy(iEta1,iXi1)=corrBathy(iEta1,iXi1)+ValueVar(iPtU)/Area1;
      corrBathy(iEta2,iXi2)=corrBathy(iEta2,iXi2)-ValueVar(iPtU)/Area2;
      TotalHmodif=TotalHmodif+abs(ValueVar(iPtU));
    end;
  end;
end;
for iEta1=1:eta_v
  for iXi1=1:xi_v
    iEta2=iEta1+1;
    iXi2=iXi1;
    Area1=AreaMatrix(iEta1,iXi1);
    Area2=AreaMatrix(iEta2,iXi2);
    if (MSK_v(iEta1, iXi1) == 1)
      iPtV=IndexVPoints(iEta1, iXi1);
      corrBathy(iEta1,iXi1)=corrBathy(iEta1,iXi1)+ValueVar(iPtV)/Area1;
      corrBathy(iEta2,iXi2)=corrBathy(iEta2,iXi2)-ValueVar(iPtV)/Area2;
      TotalHmodif=TotalHmodif+abs(ValueVar(iPtV));
    end;
  end;
end;
NewBathy=Hobs+corrBathy;

RMat=GRID_RoughnessMatrix(NewBathy, MSK_rho);
MaxRx0=max(RMat(:));
disp(['MaxRx0=' num2str(MaxRx0)]);

H=AreaMatrix.*Hobs.*MSK_rho;
TheBathymetry1=sum(H(:));
H=AreaMatrix.*NewBathy.*MSK_rho;
TheBathymetry2=sum(H(:));
DeltaBathymetry=TheBathymetry1-TheBathymetry2;
disp(['DeltaBathymetry=' num2str(DeltaBathymetry)]);
