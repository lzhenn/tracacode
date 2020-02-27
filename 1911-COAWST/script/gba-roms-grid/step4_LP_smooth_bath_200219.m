raw_fn='/users/b145872/project-dir/app/COAWST-GBA/Projects/GBA/roms-grid/GBA_roms_grid_test.nc';
out_fn='/users/b145872/project-dir/app/COAWST-GBA/Projects/GBA/roms-grid/GBA_roms_grid_train.nc'

netcdf_load(raw_fn);

rx0max=0.2;
disp(['Target for rx0=' num2str(rx0max)]);

disp('Using LP method with heuristic');

h0=GRID_LinProgHeuristic_rx0(mask_rho, h, rx0max);

figure
pcolorjw(lon_rho,lat_rho,h0-h)
hold on
caxis([-100 100]); colorbar
title('ROMS bathy diff')
xlabel('longitude'); ylabel('latitiude')
ncwrite(out_fn,'h',h0);
