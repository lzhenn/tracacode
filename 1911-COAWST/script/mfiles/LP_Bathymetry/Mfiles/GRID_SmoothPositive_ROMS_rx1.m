function RetBathy=GRID_SmoothPositive_ROMS_rx1(...
    MSK_rho, Hobs, rx1max, ARVD)
%
% This program optimizes the bathymetry for the rx1 factor by increasing it.
% GRID_SmoothPositive_ROMS_rx1(MSK, Hobs, rx1max, ThetaS, ThetaB, N, hc)
%
% ---MSK_rho(eta_rho,xi_rho) is the mask of the grid
%      1 for sea
%      0 for land
% ---Hobs(eta_rho,xi_rho) is the raw depth of the grid
% ---rx1max is the target rx1 roughness factor
% ---ARVD contains the description of vertical stratification
%    of the ROMS model with the same values
%  One typical example:
%   ARVD.Vtransform=2;
%   ARVD.Vstretching=1;
%   ARVD.ThetaS=4; % in ROMS it is THETA_S
%   ARVD.ThetaB=0.35; % in ROMS it is THETA_B
%   ARVD.N=30;
%   ARVD.hc=10; & in ROMS it is TCLINE

[Sc_w, Cs_w, Sc_r, Cs_r]=GRID_GetSc_Cs_V2(ARVD);

[Z_r, Z_w]=GetVerticalLevels2(Hobs, MSK_rho, ARVD);
RX1matrix=GRID_ComputeMatrixRx1_V2(Z_w, MSK_rho);
OrigRx1=max(RX1matrix(:));
disp(['Original rx1=' num2str(OrigRx1)]);


if (ARVD.Vtransform == 1)
  RetBathy=GRID_SmoothPositive_Vtrans1_rx1(MSK_rho, Hobs, rx1max, ...
				   Sc_w, Cs_w, ARVD.hc);
elseif (ARVD.Vtransform == 2)
  RetBathy=GRID_SmoothPositive_Vtrans2_rx1(...
      MSK_rho, Hobs, rx1max, Sc_w, Cs_w, ARVD.hc, RX1matrix);
else
  disp('Put value of ARVD.Vtransform');
  error('Please correct');
end;
[NewZ_r, NewZ_w]=GetVerticalLevels2(RetBathy, MSK_rho, ARVD);
NewRX1matrix=GRID_ComputeMatrixRx1_V2(NewZ_w, MSK_rho);
NewRx1max=max(NewRX1matrix(:));
disp(['New rx1=' num2str(NewRx1max)]);
