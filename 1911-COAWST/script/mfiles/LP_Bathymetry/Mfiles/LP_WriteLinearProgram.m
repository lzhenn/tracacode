function testfeasibility=LP_WriteLinearProgram(...
    FileName, iList, jList, sList, Constant, ...
    ObjectiveFct)
%
% Do not remove the test of feasibility !
% It is a preliminary check and it is actually useful.
nbVar=size(ObjectiveFct,1);
nbConst=size(Constant,1);
disp(['nbVar=' num2str(nbVar) '  nbConst=' num2str(nbConst)]);

fid=fopen(FileName,'w');
fprintf(fid, 'min: ');
for iVar=1:nbVar
  eVal=ObjectiveFct(iVar,1);
  if (eVal ~= 0)
    if (eVal > 0)
      add='+';
    else
      add='';
    end;
    str=[num2str(eVal) ' X' num2str(iVar) ' '];
    fprintf(fid, '%s%s', add, str);
  else
    str=['+0 X' num2str(iVar) ' '];
    fprintf(fid, '%s', str);
  end;
end;
fprintf(fid, ';\n');
fprintf(fid,'\n');

tolCrit=10^(-6);
for iConst=1:nbConst
  H=find(iList == iConst);
  nbH=size(H,1);
  if (nbH == 0)
    if (Constant(iConst,1) < -tolCrit)
      testfeasibility=0;
      return;
    end;
  else
    fprintf(fid, 'row%s: ', num2str(iConst));
    for iH=1:nbH
      jL=jList(H(iH),1);
      sL=sList(H(iH),1);
      str=[num2str(sL) ' X' num2str(jL) ' '];
      if (sL > 0)
	add='+';
      else
	add='';
      end;
      fprintf(fid, '%s%s', add, str);
    end;
    fprintf(fid, '<= %d ;\n', Constant(iConst,1));
  end;
end;
fprintf(fid, '\n');
% the free command does not seem to work as advertised
fprintf(fid, 'free');
for iVar=1:nbVar
  if (iVar > 1)
    fprintf(fid, ',');
  end;
  fprintf(fid, ' X%s', num2str(iVar));
end;
fprintf(fid, ';\n');
%for iVar=1:nbVar
%  fprintf(fid, 'X%s>= -Inf;\n', num2str(iVar));
%end;
fclose(fid);
testfeasibility=1;