function [iList, jList, sList, Constant]=...
    GRID_LinProgGetIJS_similarity(MSK, DEP, MaxSim)
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
%
TotalNbConstant=2*nbVert;
TotalNbEntry=2*nbVert;
nbConst=0;
nbEntry=0;
Constant=zeros(TotalNbConstant,1);
iList=zeros(TotalNbEntry,1);
jList=zeros(TotalNbEntry,1);
sList=zeros(TotalNbEntry,1);
for iEta=1:eta_rho
  for iXi=1:xi_rho
    if (MSK(iEta, iXi) == 1)
      idx=ListCoord(iEta, iXi);
      TheDep=DEP(iEta, iXi);
      %
      nbConst=nbConst+1;
      nbEntry=nbEntry+1;
      Constant(nbConst,1)=(1-1/MaxSim)*TheDep;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=idx;
      sList(nbEntry,1)=-1;
      %
      nbConst=nbConst+1;
      nbEntry=nbEntry+1;
      Constant(nbConst,1)=(MaxSim-1)*TheDep;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=idx;
      sList(nbEntry,1)=1;
    end;
  end;
end;
disp('Similarity inequalities for h');
disp(['similarity: nbEntry=' num2str(nbEntry) ...
      '  nbConst=' num2str(nbConst)]);
if (abs(nbEntry - TotalNbEntry) > 0)
  disp('We have a coding inconsistency for nbEntry');
  error('Please correct');
end;
if (abs(nbConst - TotalNbConstant) > 0)
  disp('We have a coding inconsistency for nbEntry');
  error('Please correct');
end;
