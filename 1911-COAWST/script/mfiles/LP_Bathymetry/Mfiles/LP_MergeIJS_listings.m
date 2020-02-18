function [iList, jList, sList, Constant]=...
    LP_MergeIJS_listings(...
	iList1, jList1, sList1, Constant1, ...
	iList2, jList2, sList2, Constant2)
%
% Suppose we have two sets of inequalities for two linear programs
% with the same set of variables presented in sparse form.
% The two descriptions are merge.

nbConst1=size(Constant1, 1);
nbConst2=size(Constant2, 1);
nbEnt1=size(iList1, 1);
nbEnt2=size(iList2, 1);

Constant=zeros(nbConst1+nbConst2, 1);
iList=zeros(nbEnt1+nbEnt2, 1);
jList=zeros(nbEnt1+nbEnt2, 1);
sList=zeros(nbEnt1+nbEnt2, 1);

for iCons=1:nbConst1
  Constant(iCons, 1)=Constant1(iCons, 1);
end;
for iCons=1:nbConst2
  Constant(nbConst1+iCons, 1)=Constant2(iCons, 1);
end;
for iEnt=1:nbEnt1
  iList(iEnt, 1)=iList1(iEnt,1);
  jList(iEnt, 1)=jList1(iEnt,1);
  sList(iEnt, 1)=sList1(iEnt,1);
end;
for iEnt=1:nbEnt2
  iList(nbEnt1+iEnt, 1)=nbConst1+iList2(iEnt,1);
  jList(nbEnt1+iEnt, 1)=jList2(iEnt,1);
  sList(nbEnt1+iEnt, 1)=sList2(iEnt,1);
end;
