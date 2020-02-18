function [ValueFct, ValueVar, testfeasibility]=...
    LP_ReadLinearProgram(FileName, nbVar)

f=fopen(FileName,'r');
eLine=fgetl(f);
chn='This problem is infeasible';
if (26 <= size(eLine,2))
  if (eLine(1,1:26) == chn)
    disp(chn);
    ValueFct=chn;
    ValueVar=chn;
    testfeasibility=0;
    return;
  end;
end;
testfeasibility=1;
%
eLine=fgetl(f);
nbChar=size(eLine, 2);
for iChar=1:nbChar
  if (eLine(1,iChar) == ':')
    FoundCol=iChar;
  end;
end;
FoundCol=FoundCol+2;
Vstr='';
for iCol=FoundCol:nbChar
  Vstr=[Vstr eLine(iCol)];
end;
ValueFct=str2num(Vstr);
eLine=fgetl(f);
eLine=fgetl(f);
ValueVar=zeros(nbVar,1);
for iVar=1:nbVar
  eLine=fgetl(f);
  nbChar=size(eLine, 2);
  eValChar='';
  WeHaveSpace=0;
  for iChar=1:nbChar
    eChar=eLine(iChar);
    if (eChar == ' ')
      WeHaveSpace=1;
    else
      if (WeHaveSpace == 1)
	eValChar=[eValChar eChar];
      end;
    end;
  end;
  ValueVar(iVar)=str2num(eValChar);
end;
fclose(f);
