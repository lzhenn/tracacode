function [iList, jList, sList, Constant]=...
    GRID_LinProgGetIJS_maxamp(MSK, DEP, AmpConst)
[eta_rho, xi_rho]=size(DEP);
disp(['eta_rho=' num2str(eta_rho) '  xi_rho=' num2str(xi_rho)]);
%
nbVert=0;
ListCoord=zeros(eta_rho, xi_rho);
for iEta=1:eta_rho
  for iXi=1:xi_rho
    if (MSK(iEta, iXi) == 1)
      nbVert=nbVert+1;
      ListCoord(iEta, iXi)=nbVert;
    end;
  end;
end;
%
TotalNbConstant=0;
TotalNbEntry=0;
for iEta=1:eta_rho
  for iXi=1:xi_rho
    if (MSK(iEta, iXi) == 1)
      alpha=AmpConst(iEta, iXi);
      if (alpha < 9999)
	TotalNbConstant=TotalNbConstant+2;
	TotalNbEntry=TotalNbEntry+2;
      end;
    end;
  end;
end;
%
nbConst=0;
nbEntry=0;
Constant=zeros(TotalNbConstant,1);
iList=zeros(TotalNbEntry,1);
jList=zeros(TotalNbEntry,1);
sList=zeros(TotalNbEntry,1);
%
for iEta=1:eta_rho
  for iXi=1:xi_rho
    if (MSK(iEta, iXi) == 1)
      idx=ListCoord(iEta, iXi);
      alpha=AmpConst(iEta, iXi);
      %
      if (alpha < 9999)
	nbConst=nbConst+1;
	nbEntry=nbEntry+1;
	Constant(nbConst,1)=alpha*DEP(iEta, iXi);
	iList(nbEntry,1)=nbConst;
	jList(nbEntry,1)=idx;
	sList(nbEntry,1)=-1;
	%
	nbConst=nbConst+1;
	nbEntry=nbEntry+1;
	Constant(nbConst,1)=alpha*DEP(iEta, iXi);
	iList(nbEntry,1)=nbConst;
	jList(nbEntry,1)=idx;
	sList(nbEntry,1)=1;
      end;
    end;
  end;
end;
disp('Inequalities |h^{new} - h^{old}| <= alpha h^{old}');
disp(['maxamp: nbEntry=' num2str(nbEntry) ...
      '  nbConst=' num2str(nbConst)]);
if (abs(nbEntry - TotalNbEntry) > 0)
  disp('We have a coding inconsistency for nbEntry');
  error('Please correct');
end;
if (abs(nbConst - TotalNbConstant) > 0)
  disp('We have a coding inconsistency for nbEntry');
  error('Please correct');
end;
