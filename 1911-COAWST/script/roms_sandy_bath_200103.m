
str_path='/users/b145872/project-dir/app/COAWST-sandy/Projects/Sandy/';
addpath(genpath('/users/b145872/project/1911-COAWST/script/mfiles'));

load([str_path,'USeast_bathy.mat']);
netcdf_load('/users/b145872/project-dir/app/COAWST-sandy/Sandy_roms_grid.nc')
h=griddata(h_lon,h_lat,h_USeast,lon_rho,lat_rho);
h(isnan(h))=5;

%smooth h a little
h(2:end-1,2:end-1)=0.2*(h(1:end-2,2:end-1)+h(2:end-1,2:end-1)+h(3:end,2:end-1)+h(2:end-1,1:end-2)+h(2:end-1,3:end));

figure
pcolorjw(lon_rho,lat_rho,h)
hold on
load([str_path,'coastline.mat']);
plot(lon,lat,'k')
caxis([5 2500]); colorbar
title('ROMS bathy')
xlabel('longitude'); ylabel('latitiude')
ncwrite('/users/b145872/project-dir/app/COAWST-sandy/Sandy_roms_grid.nc','h',h);
