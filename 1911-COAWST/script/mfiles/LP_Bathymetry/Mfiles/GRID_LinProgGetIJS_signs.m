function [iList, jList, sList, Constant]=...
    GRID_LinProgGetIJS_signs(MSK, SignConst)
[eta_rho, xi_rho]=size(MSK);
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
    if (MSK(iEta, iXi) == 1 && SignConst(iEta, iXi) ~= 0)
      TotalNbConstant=TotalNbConstant+1;
      TotalNbEntry=TotalNbEntry+1;
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

for iEta=1:eta_rho
  for iXi=1:xi_rho
    if (MSK(iEta, iXi) == 1 && SignConst(iEta, iXi) ~= 0)
      idx=ListCoord(iEta, iXi);
      %
      nbConst=nbConst+1;
      nbEntry=nbEntry+1;
      Constant(nbConst,1)=0;
      iList(nbEntry,1)=nbConst;
      jList(nbEntry,1)=idx;
      if (SignConst(iEta, iXi) == 1)
	sList(nbEntry,1)=-1;
      elseif (SignConst(iEta, iXi) == -1)
	sList(nbEntry,1)=1;
      else
	disp('Wrong assigning please check SignConst');
      end;
    end;
  end;
end;
disp('Inequalities d >= 0 or d <= 0');
disp(['signs: nbEntry=' num2str(nbEntry) ...
      '  nbConst=' num2str(nbConst)]);
if (abs(nbEntry - TotalNbEntry) > 0)
  disp('We have a coding inconsistency for nbEntry');
  error('Please correct');
end;
if (abs(nbConst - TotalNbConstant) > 0)
  disp('We have a coding inconsistency for nbEntry');
  error('Please correct');
end;
