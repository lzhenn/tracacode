FileSave='GRID_ADRIA02';
load(FileSave, 'mreza');

rx0max=0.2;
disp(['Target for rx0=' num2str(rx0max)]);

[eta_rho, xi_rho]=size(mreza.MSK_rho);
SignConst=zeros(eta_rho, xi_rho);
AmpConst=10000*ones(eta_rho, xi_rho);
MaxSimilarity=2.5;
NewBathy=GRID_LinearProgrammingSmoothing_rx0_similarity(...
    mreza.MSK_rho, mreza.SampledBathy, rx0max, ...
    SignConst, AmpConst, MaxSimilarity);

PRS=zeros(eta_rho, xi_rho);
for iEta=1:eta_rho
  if (MSK_rho(iEta, xi_rho) == 1)
    PRS(iEta, xi_rho)=1;
  end;
end;

NewBathy=GRID_LinearProgrammingSmoothing_rx0_fixed(...
    mreza.MSK_rho, mreza.SampledBathy, PRS, rx0max);
