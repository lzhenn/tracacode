FileSave='GRID_ADRIA02';
load(FileSave, 'mreza');

rx0max=0.2;
disp(['Target for rx0=' num2str(rx0max)]);

disp('Doing smoothing with Laplacian filter');
NewBathy_Lapl=GRID_LaplacianSelectSmooth_rx0(...
    mreza.MSK_rho, mreza.SampledBathy, rx0max);

disp('Doing the Martinho Bateen method');
NewBathy_MB=GRID_SmoothPositive_rx0(...
    mreza.MSK_rho, mreza.SampledBathy, rx0max);

disp('Doing MB volume bathymetry filtering');
NewBathy_MBvol=GRID_SmoothPositiveVolume_rx0(...
    mreza.MSK_rho, mreza.SampledBathy, rx0max, mreza.AreaMatrix);

disp('Using Mellor-Ezer-Oey method');
[NewBathy_MEO1, TotalHmodif, ValueFct]=GRID_PlusMinusScheme_rx0(...
    mreza.MSK_rho, mreza.SampledBathy, rx0max, mreza.AreaMatrix);

disp('Using Bathymetry decreasing method');
NewBathy=GRID_SmoothNegative_rx0(...
    mreza.MSK_rho, mreza.SampledBathy, rx0max);

disp('Using Mellor-Ezer-Oey method');
[NewBathy_MEO2, TotalHmodif]=GRID_LinProgSmoothVertVert_rx0(...
    mreza.MSK_rho, mreza.SampledBathy, rx0max, ...
    mreza.AreaMatrix);

disp('Using LP method');
NewBathy_LP=GRID_LinearProgrammingSmoothing_rx0_simple(...
    mreza.MSK_rho, mreza.SampledBathy, rx0max);

disp('Using LP method with heuristic');
NewBathy_Lapl=GRID_LinProgHeuristic_rx0(...
    mreza.MSK_rho, mreza.SampledBathy, rx0max);

disp('Using LP volume method');
NewBathy_LPvol=GRID_LinearProgrammingSmoothing_rx0_volume(...
    mreza.MSK_rho, mreza.SampledBathy, rx0max, mreza.AreaMatrix);

