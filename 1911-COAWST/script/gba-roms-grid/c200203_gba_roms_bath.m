
str_path='/users/b145872/project-dir/app/COAWST-sandy/Projects/Sandy/';

netcdf_load('/users/b145872/project-dir/app/COAWST-GBA/Projects/GBA/roms-grid/GBA_roms_grid.nc')
netcdf_load('/users/b145872/project-dir/data/bath/ETOPO1_Ice_g_gmt4.grd.nc')
h=griddata(x,y,z,lon_rho,lat_rho);
h(isnan(h))=5;

%smooth h a little
h(2:end-1,2:end-1)=0.2*(h(1:end-2,2:end-1)+h(2:end-1,2:end-1)+h(3:end,2:end-1)+h(2:end-1,1:end-2)+h(2:end-1,3:end));

figure
pcolorjw(lon_rho,lat_rho,h)
hold on
plot(lon,lat,'k')
caxis([5 2500]); colorbar
title('ROMS bathy')
xlabel('longitude'); ylabel('latitiude')
ncwrite('/users/b145872/project-dir/app/COAWST-GBA/Projects/GBA/roms-grid/GBA_roms_grid_bath.nc','h',h);
