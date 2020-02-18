function [iList, jList, sList, Constant]=...
    GRID_LinProgGetIJS_volume(MSK, AreaMatrix)
[eta_rho, xi_rho]=size(MSK);
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
TotalNbEntry=nbVert;
%
nbConst=1;
Constant=zeros(1,1);
iList=zeros(TotalNbEntry,1);
jList=zeros(TotalNbEntry,1);
sList=zeros(TotalNbEntry,1);
ListArea=zeros(nbVert,1);
Constant(1,1)=0;
nbEntry=0;
for iEta=1:eta_rho
  for iXi=1:xi_rho
    if (MSK(iEta, iXi) == 1)
      idx=ListCoord(iEta, iXi);
      nbEntry=nbEntry+1;
      iList(nbEntry,1)=1;
      jList(nbEntry,1)=idx;
      sList(nbEntry,1)=AreaMatrix(iEta, iXi);
    end;
  end;
end;
disp(['volume: nbEntry=' num2str(nbEntry) ...
      '  nbConst=' num2str(nbConst)]);
if (abs(nbEntry - TotalNbEntry) > 0)
  disp('We have a coding inconsistency for nbEntry');
  error('Please correct');
end;
