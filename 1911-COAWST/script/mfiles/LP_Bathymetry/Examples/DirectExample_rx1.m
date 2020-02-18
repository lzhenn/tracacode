FileSave='GRID_ADRIA02';
load(FileSave, 'mreza');

TheChoice=2;
disp(['TheChoice=' num2str(TheChoice)]);
if (TheChoice == 1)
  ARVD.Vtransform=1;
  ARVD.Vstretching=1;
  ARVD.ThetaS=3;
  ARVD.ThetaB=0.35;
  ARVD.N=20;
  ARVD.hc=3;
elseif (TheChoice == 2)
  ARVD.Vtransform=2;
  ARVD.Vstretching=1;
  ARVD.ThetaS=4;
  ARVD.ThetaB=0.35;
  ARVD.N=30;
  ARVD.hc=3;
else
  disp('Please put your mind here');
  error('Please correct');
end;
rx1max=6;

disp('Using Bathymetry increasing method with rx1');
RetBathy=GRID_SmoothPositive_ROMS_rx1(...
    mreza.MSK_rho, mreza.SampledBathy, rx1max, ARVD);
