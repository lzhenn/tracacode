addpath(genpath('/users/b145872/project/1911-COAWST/script/mfiles'));
netcdf_load('/users/b145872/project-dir/app/COAWST-sandy/wrfinput_d01')
figure
pcolorjw(XLONG,XLAT,double(1-LANDMASK))
hold on
title('WRF LANDMASK grid, Lambert conformal proj')
xlabel('longitude'); ylabel('latitiude')

% pick connors
xl=-82; xr=-65;
yb= 28; yt= 43;

% pick numbers
numx=86; numy=64;


% make matrix
dx=(xr-xl)/numx; dy=(yt-yb)/numy;
[lon, lat]=meshgrid(xl:dx:xr, yb:dy:yt);
lon=lon.';lat=lat.';
plot(lon,lat,'k-')
plot(lon',lat','k-')
text(-75,27,'- - - roms grid')

% Call generic grid creation.
roms_grid='/users/b145872/project-dir/app/COAWST-sandy/Sandy_roms_grid.nc';
rho.lat=lat; rho.lon=lon;
rho.depth=zeros(size(rho.lon))+100; % for now just make zeros
rho.mask=zeros(size(rho.lon)); % for now just make zeros
spherical='T';
%projection='lambert conformal conic';
projection='mercator';
save temp_jcw33.mat rho spherical projection
eval(['mat2roms_mw(''temp_jcw33.mat'',''',roms_grid,''');'])
!del temp_jcw33.mat
%User needs to edit roms variables
disp([' '])
disp(['Created roms grid --> ',roms_grid])
disp([' '])
disp(['You need to edit depth in ',roms_grid])
disp([' '])

% ROMS grid masking
% Start out with the WRF mask.
F = scatteredInterpolant(double(XLONG(:)),double(XLAT(:)), double(1-LANDMASK(:)),'nearest');
roms_mask=F(lon,lat);
figure
pcolorjw(lon,lat,roms_mask)
title('ROMS 1-LANDMASK grid, Mercator proj')
xlabel('longitude'); ylabel('latitiude')

% Compute mask on rho, u, v, and psi points

water = double(roms_mask);
u_mask = water(1:end-1,:) & water(2:end,:);
v_mask= water(:,1:end-1) & water(:,2:end);
psi_mask= water(1:end-1,1:end-1) & water(1:end-1,2:end) & water(2:end,1:end-1) & water(2:end,2:end);
ncwrite(roms_grid,'mask_rho',roms_mask);
ncwrite(roms_grid,'mask_u',double(u_mask));
ncwrite(roms_grid,'mask_v',double(v_mask));
ncwrite(roms_grid,'mask_psi',double(psi_mask));

%editmask('Sandy_roms_grid.nc','coastline.mat');
