function TheNewBathy=GRID_LinProgHeuristic_rx0_fixed(...
    MSK_rho, DEP_rho, PRS_rho, rx0max)

% This is the same as GRID_LinearProgrammingSmoothing_rx0_fixed
% but with the divide and conqueer heuristic approach for speedups.

MSKbad=GRID_GetBadPoints(MSK_rho, DEP_rho, rx0max);

[eta_rho, xi_rho]=size(DEP_rho);
ETAmat=zeros(eta_rho, xi_rho);
XImat=zeros(eta_rho, xi_rho);
for iEta=1:eta_rho
  for iXi=1:xi_rho
    ETAmat(iEta, iXi)=iEta;
    XImat(iEta, iXi)=iXi;
  end;
end;


Kdist=5;

Kbad=find(MSKbad == 1);
nbKbad=size(Kbad,1);
ListIdx=zeros(eta_rho, xi_rho);
ListIdx(Kbad)=1:nbKbad;

ETA_K=ETAmat(Kbad);
XI_K=XImat(Kbad);
ListEdges=zeros(0,2);
nbEdge=0;
for iK=1:nbKbad
  iVert=Kbad(iK,1);
  iEta=ETAmat(iVert);
  iXi=XImat(iVert);
  ListNeigh=SUB_StepNeighborhood(MSK_rho, iEta, iXi, 2*Kdist+1);
  nbNeigh=size(ListNeigh,1);
  for iNeigh=1:nbNeigh
    iEtaN=ListNeigh(iNeigh,1);
    iXiN=ListNeigh(iNeigh,2);
    if (MSKbad(iEtaN, iXiN) == 1)
      idx=ListIdx(iEtaN, iXiN);
      if (idx > iK)
	nbEdge=nbEdge+1;
	ListEdges(nbEdge,1)=iK;
	ListEdges(nbEdge,2)=idx;
      end;
    end;
  end;
end;


ListVertexStatus=GRAPH_ConnectedComponent(...
    ListEdges, nbKbad);
nbColor=max(ListVertexStatus);
for iColor=1:nbColor
  K=find(ListVertexStatus == iColor);
  nbK=size(K,1);
  disp(['iColor=' num2str(iColor) '  nbK=' num2str(nbK)]);
end;
TheNewBathy=DEP_rho;
for iColor=1:nbColor
  disp('---------------------------------------------------------------');
  MSKcolor=zeros(eta_rho, xi_rho);
  K=find(ListVertexStatus == iColor);
  nbK=size(K,1);
  disp(['iColor=' num2str(iColor) '  nbK=' num2str(nbK)]);
  idx=0;
  for iVertex=1:nbKbad
    if (ListVertexStatus(iVertex,1) == iColor)
      idx=idx+1;
      iVert=Kbad(iVertex,1);
      iEta=ETAmat(iVert);
      iXi=XImat(iVert);
      MSKcolor(iEta, iXi)=1;
      ListNeigh=SUB_StepNeighborhood(MSK_rho, iEta, iXi, Kdist);
      nbNeigh=size(ListNeigh,1);
      for iNeigh=1:nbNeigh
	iEtaN=ListNeigh(iNeigh,1);
	iXiN=ListNeigh(iNeigh,2);
	MSKcolor(iEtaN, iXiN)=1;
      end;
    end;
  end;
  K=find(MSKcolor == 1);
  Hobs=zeros(eta_rho, xi_rho);
  Hobs(K)=DEP_rho(K);
  NewBathy=GRID_LinearProgrammingSmoothing_rx0_fixed(...
      MSKcolor, Hobs, PRS_rho, rx0max);
  TheNewBathy(K)=NewBathy(K);
end;
disp('Final obtained bathymetry');
RMat=GRID_RoughnessMatrix(TheNewBathy, MSK_rho);
MaxRx0=max(RMat(:));
disp(['rx0max=' num2str(rx0max) '  MaxRx0=' num2str(MaxRx0)]);
