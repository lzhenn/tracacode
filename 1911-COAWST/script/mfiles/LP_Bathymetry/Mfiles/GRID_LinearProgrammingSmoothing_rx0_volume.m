function NewBathy=GRID_LinearProgrammingSmoothing_rx0_volume(...
    MSK, Hobs, rx0max, AreaMatrix)
% GRID_LinearProgrammingSmoothing_rx0_volume(MSK, Hobs, rx0max, AreaMatrix)
%
% ---MSK(eta_rho,xi_rho) is the mask of the grid
%      1 for sea
%      0 for land
% ---Hobs(eta_rho,xi_rho) is the raw depth of the grid
% ---rx0max is the target rx0 roughness factor
% ---AreaMatrix(eta_rho,xi_rho) is the matrix of grid cells areas.
[eta_rho, xi_rho]=size(MSK);
tol=0.0001;
Ksea=find(MSK == 1);
if (min(Hobs(Ksea)) < tol)
  disp('The bathymetry should always be positive');
  error('Please correct');
end;

TotalNbVert=sum(MSK(:));
ObjectiveFct=zeros(2*TotalNbVert, 1);
for iVert=1:TotalNbVert
  ObjectiveFct(TotalNbVert+iVert,1)=1;
end;

%

[iList, jList, sList, Constant]=...
    GRID_LinProgGetIJS_rx0(MSK, Hobs, rx0max);
%
[iListApp, jListApp, sListApp, ConstantApp]=...
    GRID_LinProgGetIJS_volume(MSK, AreaMatrix);
[iListWork, jListWork, sListWork, ConstantWork]=...
    LP_MergeIJS_listings(...
	iList, jList, sList, Constant, ...
	iListApp, jListApp, sListApp, ConstantApp);

[ValueFct1, ValueVar1, testfeasibility1]=LP_SolveLinearProgram(...
    iListWork, jListWork, sListWork, ConstantWork, ObjectiveFct);
if (testfeasibility1 == 0)
  disp('Normally the program is feasible');
  disp('We should consider it as a bug');
  error('Please correct');
end;
% normally always feasible ...
VolPert1=0;
for iVert=1:TotalNbVert
  VolPert1=VolPert1+ValueVar1(iVert);
end;
smallPert=10^(-2);
if (abs(VolPert1) > smallPert)
  sListApp=-sListApp;
  [iListWork, jListWork, sListWork, ConstantWork]=...
      LP_MergeIJS_listings(...
	  iList, jList, sList, Constant, ...
	  iListApp, jListApp, sListApp, ConstantApp);
  % normally always feasible ...
  [ValueFct2, ValueVar2, testfeasibility2]=LP_SolveLinearProgram(...
      iListWork, jListWork, sListWork, ConstantWork, ObjectiveFct);
  if (testfeasibility2 == 0)
    disp('Normally the program is feasible');
    disp('We should consider it as a bug');
    error('Please correct');
  end;
  VolPert2=0;
  for iVert=1:TotalNbVert
    VolPert2=VolPert2+ValueVar2(iVert);
  end;
  if (abs(VolPert2) > abs(VolPert1))
    ValueVar=ValueVar1;
    ValueFct=ValueFct1;
  else
    ValueVar=ValueVar2;
    ValueFct=ValueFct2;
  end;
else
  ValueVar=ValueVar1;
  ValueFct=ValueFct1;
  VolPert2=NaN;
end;
if (isnan(VolPert2) == 1)
  disp(['VolPert1=' num2str(VolPert1)]);
else
  disp(['VolPert1=' num2str(VolPert1) '  VolPert2=' num2str(VolPert2)]);
end;
%
correctionBathy=zeros(eta_rho, xi_rho);
nbVert=0;
for iEta=1:eta_rho
  for iXi=1:xi_rho
    if (MSK(iEta, iXi) == 1)
      nbVert=nbVert+1;
      correctionBathy(iEta, iXi)=ValueVar(nbVert);
    end;
  end;
end;
NewBathy=Hobs+correctionBathy;

