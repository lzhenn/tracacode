function ListVertexStatus=GRAPH_ConnectedComponent(...
    ListEdges, nbVert)

% compute the vector of connected component belonging
% using a representation and an algorithm well suited
% for sparse graphs.

nbEdge=size(ListEdges, 1);
ListDegree=zeros(nbVert,1);
ListAdjacency=zeros(nbVert, 10);

for iEdge=1:nbEdge
  eVert=ListEdges(iEdge,1);
  fVert=ListEdges(iEdge,2);
  eDeg=ListDegree(eVert,1)+1;
  fDeg=ListDegree(fVert,1)+1;
  ListDegree(eVert,1)=eDeg;
  ListDegree(fVert,1)=fDeg;
  ListAdjacency(eVert,eDeg)=fVert;
  ListAdjacency(fVert,fDeg)=eVert;
end;
MaxDeg=max(ListDegree(:));

ListVertexStatus=zeros(nbVert,1);
ListHot=zeros(nbVert,1);
ListNotDone=ones(nbVert,1);

iComp=0;
while(1)
  H=find(ListNotDone == 1);
  nb=size(H, 1);
  if (nb == 0)
    break;
  end;
  iComp=iComp+1;
  ListVertexStatus(H(1,1),1)=iComp;
  ListHot(H(1,1),1)=1;
  while(1)
    H=find(ListHot == 1);
    ListNotDone(H, 1)=0;
    ListNewHot=zeros(nbVert,1);
    for iH=1:size(H,1)
      eVert=H(iH,1);
      for iV=1:ListDegree(eVert,1)
	ListNewHot(ListAdjacency(eVert, iV),1)=1;
      end;
    end;
    ListHot=ListNotDone.*ListNewHot;
    SumH=sum(ListHot(:));
    if (SumH == 0)
      break;
    end;
    H2=find(ListHot == 1);
    ListVertexStatus(H2,1)=iComp;
  end;
end;
