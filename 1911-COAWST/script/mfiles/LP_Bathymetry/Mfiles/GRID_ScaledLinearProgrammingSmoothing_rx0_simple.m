function NewBathy=GRID_ScaledLinearProgrammingSmoothing_rx0_simple(...
    MSK, DEP, rx0max)
%
% this is a program for doing linear programming optimization
% of the bathymetry.
% GRID_ScaledLinearProgrammingSmoothing_rx0_simple(MSK, DEP, rx0max)
%
% ---MSK is the mask of the grd
%      1 for sea
%      0 for land
% ---DEP is the raw depth of the grid
% ---rx0max is the target rx0 roughness factor

[eta_rho, xi_rho]=size(DEP);
SignConst=zeros(eta_rho, xi_rho);
AmpConst=10000*ones(eta_rho, xi_rho);

NewBathy=GRID_ScaledLinearProgrammingSmoothing(...
    MSK, DEP, rx0max, ...
    SignConst, AmpConst);
