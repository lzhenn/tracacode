function [iList, jList, sList, Constant]=...
    GRID_LinProgGetIJS_rx0(MSK, DEP, r)
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
TotalNbVert=nbVert;
disp('ListCoord built');
disp(['Computing inequalities for r=', num2str(r)]);
%
TotalNbConstant=0;
TotalNbEntry=0;
for iEta=1:eta_rho-1
  for iXi=1:xi_rho
    if (MSK(iEta, iXi) == 1 && MSK(iEta+1, iXi) == 1)
      TotalNbConstant=TotalNbConstant+2;
      TotalNbEntry=TotalNbEntry+4;
    end;
  end;
end;
for iEta=1:eta_rho
  for iXi=1:xi_rho-1
    if (MSK(iEta, iXi) == 1 && MSK(iEta, iXi+1) == 1)
      TotalNbConstant=TotalNbConstant+2;
      TotalNbEntry=TotalNbEntry+4;
    end;
  end;
end;
TotalNbConstant=TotalNbConstant+2*TotalNbVert;
TotalNbEntry=TotalNbEntry+4*TotalNbVert;
%
Constant=zeros(TotalNbConstant,1);
iList=zeros(TotalNbEntry,1);
jList=zeros(TotalNbEntry,1);
sList=zeros(TotalNbEntry,1);

nbConst=0;
nbEntry=0;
for iEta=1:eta_rho-1
  for iXi=1:xi_rho
    if (MSK(iEta, iXi) == 1 && MSK(iEta+1, iXi) == 1)
      idx1=ListCoord(iEta, iXi);
      idx2=ListCoord(iEta+1, iXi);
      %
      nbConst=nbConst+1;
      CST=(1+r)*DEP(iEta+1,iXi)+(-1+r)*DEP(iEta, iXi);
      Constant(nbConst,1)=CST;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=idx2;
      sList(nbEntry,1)=-1-r;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=idx1;
      sList(nbEntry,1)=1-r;
      %
      nbConst=nbConst+1;
      CST=(1+r)*DEP(iEta,iXi)+(-1+r)*DEP(iEta+1, iXi);
      Constant(nbConst,1)=CST;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=idx1;
      sList(nbEntry,1)=-r-1;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=idx2;
      sList(nbEntry,1)=1-r;
    end;
  end;
end;
disp('Inequalities for h(iEta, iXi) and h(iEta+1, iXi)');


for iEta=1:eta_rho
  for iXi=1:xi_rho-1
    if (MSK(iEta, iXi) == 1 && MSK(iEta, iXi+1) == 1)
      idx1=ListCoord(iEta, iXi);
      idx2=ListCoord(iEta, iXi+1);
      %
      nbConst=nbConst+1;
      CST=(1+r)*DEP(iEta,iXi+1)+(r-1)*DEP(iEta, iXi);
      Constant(nbConst,1)=CST;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=idx2;
      sList(nbEntry,1)=-r-1;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=idx1;
      sList(nbEntry,1)=1-r;
      %
      nbConst=nbConst+1;
      CST=(1+r)*DEP(iEta,iXi)+(r-1)*DEP(iEta, iXi+1);
      Constant(nbConst,1)=CST;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=idx1;
      sList(nbEntry,1)=-r-1;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=idx2;
      sList(nbEntry,1)=1-r;
    end;
  end;
end;
disp('Inequalities for h(iEta, iXi) and h(iEta, iXi+1)');


for iEta=1:eta_rho
  for iXi=1:xi_rho
    if (MSK(iEta, iXi) == 1)
      idx=ListCoord(iEta, iXi);
      %
      nbConst=nbConst+1;
      Constant(nbConst,1)=0;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=TotalNbVert+idx;
      sList(nbEntry,1)=-1;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=idx;
      sList(nbEntry,1)=1;
      %
      nbConst=nbConst+1;
      Constant(nbConst,1)=0;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=TotalNbVert+idx;
      sList(nbEntry,1)=-1;
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=idx;
      sList(nbEntry,1)=-1;
    end;
  end;
end;
disp('Inequalities d <= ad and -d <= ad');
disp(['rx0: nbEntry=' num2str(nbEntry) ...
      '  nbConst=' num2str(nbConst)]);
if (abs(nbEntry - TotalNbEntry) > 0)
  disp('We have a coding inconsistency for nbEntry');
  error('Please correct');
end;
if (abs(nbConst - TotalNbConstant) > 0)
  disp('We have a coding inconsistency for nbConst');
  error('Please correct');
end;
