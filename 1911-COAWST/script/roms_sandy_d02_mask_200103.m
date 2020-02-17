proj_path='/users/b145872/project-dir/app/COAWST-sandy/Projects/Sandy/';
cwst_root='/users/b145872/project-dir/app/COAWST-sandy/';
addpath(genpath('/users/b145872/project/1911-COAWST/script/mfiles'));

netcdf_load([cwst_root,'wrfinput_d01'])
figure
pcolorjw(XLONG,XLAT,double(1-LANDMASK))
hold on
netcdf_load([cwst_root,'wrfinput_d02'])
pcolorjw(XLONG,XLAT,double(1-LANDMASK))
plot(XLONG(1,:),XLAT(1,:),'r'); plot(XLONG(end,:),XLAT(end,:),'r')
plot(XLONG(:,1),XLAT(:,1),'r'); plot(XLONG(:,end),XLAT(:,end),'r')

% plot roms parent grid
netcdf_load([cwst_root,'Sandy_roms_grid.nc']);
plot(lon_rho(1,:),lat_rho(1,:),'k'); plot(lon_rho(end,:),lat_rho(end,:),'k')
plot(lon_rho(:,1),lat_rho(:,1),'k'); plot(lon_rho(:,end),lat_rho(:,end),'k')
text(-75,29,'roms parent grid')
text(-77,27,'wrf parent grid')
text(-77.2,34,'wrf child grid')
title('LANDMASKS')
xlabel('longitude'); ylabel('latitiude')

%Select child indices and plot location of roms child grid.
Istr=22; Iend=60; Jstr=26; Jend=54;
plot(lon_rho(Istr,Jstr),lat_rho(Istr,Jstr),'m+')
plot(lon_rho(Istr,Jend),lat_rho(Istr,Jend),'m+')
plot(lon_rho(Iend,Jstr),lat_rho(Iend,Jstr),'m+')
plot(lon_rho(Iend,Jend),lat_rho(Iend,Jend),'m+')
ref_ratio=3;
roms_child=[cwst_root,'Sandy_roms_grid_ref3.nc'];
F=coarse2fine([cwst_root,'Sandy_roms_grid.nc'],[cwst_root,'Sandy_roms_grid_ref3.nc'], ...
ref_ratio,Istr,Iend,Jstr,Jend);
Gnames={[cwst_root,'Sandy_roms_grid.nc'],[cwst_root,'Sandy_roms_grid_ref3.nc']};
[S,G]=contact(Gnames,[cwst_root,'Sandy_roms_contact.nc']);

%compute bath for the child
netcdf_load(roms_child)
load([proj_path,'USeast_bathy.mat']);
h=griddata(h_lon,h_lat,h_USeast,lon_rho,lat_rho);
h(isnan(h))=5;
h(2:end-1,2:end-1)=0.2*(h(1:end-2,2:end-1)+h(2:end-1,2:end-1)+h(3:end,2:end-1)+ ...
h(2:end-1,1:end-2)+h(2:end-1,3:end));
figure
pcolorjw(lon_rho,lat_rho,h)
hold on
load([proj_path,'coastline.mat']);
plot(lon,lat,'r')
caxis([5 2500]); colorbar
title('ROMS bathy')
xlabel('longitude'); ylabel('latitiude')
ncwrite(roms_child,'h',h);

%Recompute child mask based on WRF mask
netcdf_load([cwst_root,'wrfinput_d01']);
F = TriScatteredInterp(double(XLONG(:)),double(XLAT(:)), ...
double(1-LANDMASK(:)),'nearest');
roms_mask=F(lon_rho,lat_rho);
figure
pcolorjw(lon_rho,lat_rho,roms_mask)
title('ROMS child mask')
xlabel('longitude'); ylabel('latitiude')
hold on
plot(lon,lat,'r')
water = double(roms_mask);
u_mask = water(1:end-1,:) & water(2:end,:);
v_mask= water(:,1:end-1) & water(:,2:end);
psi_mask= water(1:end-1,1:end-1) & water(1:end-1,2:end) & water(2:end,1:end-1) & water(2:end,2:end);
ncwrite(roms_child,'mask_rho',roms_mask);
ncwrite(roms_child,'mask_u',double(u_mask));
ncwrite(roms_child,'mask_v',double(v_mask));
ncwrite(roms_child,'mask_psi',double(psi_mask));

