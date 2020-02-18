function result=IsExistingFile(FileName)


test=exist(FileName, 'file');
if (test == 0)
  result=0;
else
  result=1;
end;
