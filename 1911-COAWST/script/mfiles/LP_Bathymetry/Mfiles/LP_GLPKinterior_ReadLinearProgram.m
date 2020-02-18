function [ValueFct, Hmat1, Hmat2, testfeasibility]=...
    LP_GLPKinterior_ReadLinearProgram(FileName)

fid=fopen(FileName, 'r');
m=fscanf(fid, '%d', 1);
n=fscanf(fid, '%d', 1);
status=fscanf(fid, '%d', 1);
ValueFct=fscanf(fid, '%f', 1);
disp(['m=' num2str(m) '  n=' num2str(n)]);
disp(['status=' num2str(status)]);
disp(['ValueFct=' num2str(ValueFct)]);
if (status == 5)
  testfeasibility=1;
else
  testfeasibility=0;
end;
Hmat1=zeros(m,2);
for i=1:m
  a=fscanf(fid, '%f', 1);
  b=fscanf(fid, '%f', 1);
  Hmat1(i,1)=a;
  Hmat1(i,2)=b;
end;
Hmat2=zeros(n,2);
for i=1:n
  a=fscanf(fid, '%f', 1);
  b=fscanf(fid, '%f', 1);
  Hmat2(i,1)=a;
  Hmat2(i,2)=b;
end;
fclose(fid);
