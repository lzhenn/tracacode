function [ValueFct, ValueVar, testfeasibility]=...
    LP_SolveLinearProgram(...
	iList, jList, sList, Constant, ObjectiveFct)

nbVar=size(ObjectiveFct,1);
nbConstraint=size(Constant,1);
disp(['Solving a linear program of ' num2str(nbVar) ...
      ' variables and ' num2str(nbConstraint) ' Constraints']);


while(1)
  H=clock;
  V0=H(1,4);
  V1=H(1,5);
  V2=floor(H(1,6));
  V3=ceil(10*rand);
  Prefix=['lp_' num2str(V0) '_' num2str(V1) ...
	  '_' num2str(V2) '_' num2str(V3)];
  %
  FileInput=['/tmp/' Prefix '_input.lp'];
  FileOutput=['/tmp/' Prefix '_output.lp'];
  if (IsExistingFile(FileInput) == 0 && ...
      IsExistingFile(FileOutput) == 0)
    break;
  end;
  disp(['We failed with FileInput=' FileInput]);
end;
disp(['FileInput=', FileInput]);
testfeasibility=LP_WriteLinearProgram(...
    FileInput, ...
    iList, jList, sList, Constant, ...
    ObjectiveFct);
if (testfeasibility == 0)
  return;
end;
disp('Linear program written');
disp(['FileOutput=', FileOutput]);
ExpR=['!lp_solve ' FileInput ' > ' FileOutput];
eval(ExpR);
%
[ValueFct, ValueVar, testfeasibility]=...
    LP_ReadLinearProgram(FileOutput, nbVar);
%RemoveFileIfExist(FileInput);
%RemoveFileIfExist(FileOutput);
disp('Reading linear program');
