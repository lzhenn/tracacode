

netcdf_load('/users/b145872/project-dir/app/COAWST-GBA/Projects/GBA/roms-grid/GBA_roms_grid_org.nc')

rx0max=0.3;
disp(['Target for rx0=' num2str(rx0max)]);

disp('Using LP method with heuristic');

h0=GRID_LinProgHeuristic_rx0(mask_rho, h, rx0max);

figure
pcolorjw(lon_rho,lat_rho,h0-h)
hold on
caxis([-2500 2500]); colorbar
title('ROMS bathy diff')
xlabel('longitude'); ylabel('latitiude')
ncwrite('/users/b145872/project-dir/app/COAWST-GBA/Projects/GBA/roms-grid/GBA_roms_grid.nc','h',h0);
