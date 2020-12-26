function [fn]=updatclim_coawst_mw_local_exp930(T1, gn, clm, clmname, wdr, url)
% Modified by Brandy Armstrong January 2012 to use only NCTOOLBOX 
% and Matlab builtin functions to read and write netcdf files
% jcw Feb 2019 - only use matalb BI
%
%T1 = date for climatology file
%gn = data from grid
%clm = data of hycom indices
%wdr = the working directory
%clmname = grid name prefix for climatology filenames
%url = where get data from

%
%determine indices for time period of interpolation
%

day_of_year=day(T1,'dayofyear');
url2d=[url,'archv.',datestr(T1,'yyyy'),'_',int2str(day_of_year),'_12_2d.nc'];
urlu=[url,'archv.',datestr(T1,'yyyy'),'_',int2str(day_of_year),'_12_3zu.nc'];
urlv=[url,'archv.',datestr(T1,'yyyy'),'_',int2str(day_of_year),'_12_3zv.nc'];
urls=[url,'archv.',datestr(T1,'yyyy'),'_',int2str(day_of_year),'_12_3zs.nc'];
urlt=[url,'archv.',datestr(T1,'yyyy'),'_',int2str(day_of_year),'_12_3zt.nc'];

tid1=ncread(url2d,'time');
tid1=tid1/24;
tid1=tid1+51544; % shift to matlab modified julian date
fn=[clmname];
disp(['creating netcdf file ',fn]);
create_roms_netcdf_clm_mwUL(fn,gn,1);% converted to BI functions
%fill grid dims using builtin (BI) functions
RN=netcdf.open(fn,'NC_WRITE');
lonid=netcdf.inqVarID(RN,'lon_rho');
netcdf.putVar(RN,lonid,gn.lon_rho);
latid=netcdf.inqVarID(RN,'lat_rho');
netcdf.putVar(RN,latid,gn.lat_rho);
netcdf.close(RN)

%%
tz_levs=length(clm.z);
X=repmat(clm.lon,1,length(clm.lat));
Y=repmat(clm.lat,length(clm.lon),1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Interpolating u for ',datestr(T1)]);
clm.u=zeros([length(clm.z) size(gn.lon_rho)]);
tmpt=ncread(urlu,'water_u',[clm.ig0 clm.jg0 1 1],[clm.ig1-clm.ig0+1 clm.jg1-clm.jg0+1 tz_levs 1 ] );
for k=1:tz_levs
    disp(['doing griddata u for HYCOM level ' num2str(k)]);
    tmp=double(squeeze(tmpt(:,:,k)));
    F = scatteredInterpolant(X(:),Y(:),tmp(:));
    cff = F(gn.lon_rho,gn.lat_rho);
    clm.u(k,:,:)=maplev(cff);
end
%== Vertical interpolation (t,s,u,v) from standard z-level to s-level
u=roms_from_stdlev_mw(gn.lon_rho,gn.lat_rho,clm.z,clm.u,gn,'u',0);
clm=rmfield(clm,'u');
save u.mat u
clear u;
disp(['Interpolating v for ',datestr(T1)]);
ttv=1;
clm.v=zeros([length(clm.z) size(gn.lon_rho)]);
try
    tmpt=ncread(urlv,'water_v',[clm.ig0 clm.jg0 1 1],[clm.ig1-clm.ig0+1 clm.jg1-clm.jg0+1 tz_levs 1 ] );
    for k=1:tz_levs
        disp(['doing griddata v for HYCOM level ' num2str(k)]);
        tmp=double(squeeze(tmpt(:,:,k)));
        F = scatteredInterpolant(X(:),Y(:),tmp(:));
        cff = F(gn.lon_rho,gn.lat_rho);
        clm.v(k,:,:)=maplev(cff);
    end
    ttv=0;
catch
    disp(['catch v Unable to download HYCOM v data at' datestr(now)]);
    fid=fopen('coawstlog.txt','a');
    fprintf(fid,'Unable to download HYCOM v data at');
    fprintf(fid,datestr(now));
    fprintf(fid,'\n');
end
%== Vertical interpolation (t,s,u,v) from standard z-level to s-level
v=roms_from_stdlev_mw(gn.lon_rho,gn.lat_rho,clm.z,clm.v,gn,'v',0);
clm=rmfield(clm,'v');
save v.mat v
clear v;

%== Rotate the velocity
theta=exp(-sqrt(-1)*mean(mean(gn.angle)));
load u.mat; load v.mat
disp('doing rotation to grid for u and v');
uv=(u2rho_3d_mw(u)+sqrt(-1)*v2rho_3d_mw(v)).*theta;
u=rho2u_3d_mw(real(uv)); v=rho2v_3d_mw(imag(uv));
disp(u(15,200:202,100:102))
clear uv
%% == output
RN=netcdf.open(fn,'NC_WRITE');

tempid=netcdf.inqVarID(RN,'u');
netcdf.putVar(RN,tempid,shiftdim(u,1));

tempid=netcdf.inqVarID(RN,'v');
netcdf.putVar(RN,tempid,shiftdim(v,1));

clear u; clear v;
tempid=netcdf.inqVarID(RN,'ocean_time');
netcdf.putVar(RN,tempid,tid1);
tempid=netcdf.inqVarID(RN,'zeta_time');
netcdf.putVar(RN,tempid,tid1);
tempid=netcdf.inqVarID(RN,'v2d_time');
netcdf.putVar(RN,tempid,tid1);
tempid=netcdf.inqVarID(RN,'v3d_time');
netcdf.putVar(RN,tempid,tid1);
tempid=netcdf.inqVarID(RN,'salt_time');
netcdf.putVar(RN,tempid,tid1);
tempid=netcdf.inqVarID(RN,'temp_time');
netcdf.putVar(RN,tempid,tid1);
netcdf.close(RN);
%%
%== Depth averaging u, v to get Ubar
load u.mat; load v.mat
cc=roms_zint_mw(u,gn);  ubar=rho2u_2d_mw(u2rho_2d_mw(cc)./gn.h);
cc=roms_zint_mw(v,gn);  vbar=rho2v_2d_mw(v2rho_2d_mw(cc)./gn.h);
%== Rotate the velocity
uv=(u2rho_2d_mw(ubar)+sqrt(-1)*v2rho_2d_mw(vbar)).*theta;
ubar=rho2u_2d_mw(real(uv)); vbar=rho2v_2d_mw(imag(uv));
clear u
clear v

RN=netcdf.open(fn,'NC_WRITE');
tempid=netcdf.inqVarID(RN,'ubar');
netcdf.putVar(RN,tempid,ubar);
tempid=netcdf.inqVarID(RN,'vbar');
netcdf.putVar(RN,tempid,vbar);
netcdf.close(RN);

clear ubar
clear vbar
clear uv
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% interpolate the zeta data
disp(['Interpolating zeta for ',datestr(T1)]);
ttz=1;
try
    tmpt=ncread(url2d,'surf_el',[clm.ig0 clm.jg0 1],[clm.ig1-clm.ig0+1 clm.jg1-clm.jg0+1 1 ] );
    tmp=double(squeeze(tmpt(:,:)));
    disp(['doing griddata zeta for HYCOM ']);
    F = scatteredInterpolant(X(:),Y(:),tmp(:));
    cff = F(gn.lon_rho,gn.lat_rho);
    zeta=maplev(cff);
    ttz=0;
catch
    disp(['catch z Unable to download HYCOM ssh data at' datestr(now)]);
    fid=fopen('coawstlog.txt','a');
    fprintf(fid,'Unable to download HYCOM ssh data at');
    fprintf(fid,datestr(now));
    fprintf(fid,'\n');
end
clear tmp
%
%== output zeta
%
RN=netcdf.open(fn,'NC_WRITE');
tempid=netcdf.inqVarID(RN,'zeta');
netcdf.putVar(RN,tempid,zeta);
netcdf.close(RN);
clear zeta;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Interpolating temp for ',datestr(T1)]);
ttt=1;
clm.temp=zeros([length(clm.z) size(gn.lon_rho)]);
try
    tmpt=ncread(urlt,'water_temp',[clm.ig0 clm.jg0 1 1],[clm.ig1-clm.ig0+1 clm.jg1-clm.jg0+1 tz_levs 1 ] );
    for k=1:tz_levs
        disp(['doing griddata temp for HYCOM level ' num2str(k)]);
        tmp=double(squeeze(tmpt(:,:,k)));
        F = scatteredInterpolant(X(:),Y(:),tmp(:));
        cff = F(gn.lon_rho,gn.lat_rho);
%           cff(cff<0)=nan;
        clm.temp(k,:,:)=maplev(cff);
    end
    ttt=0;
catch
    disp(['catch temp Unable to download HYCOM temp data at' datestr(now)]);
    fid=fopen('coawstlog.txt','a');
    fprintf(fid,'Unable to download HYCOM temp data at');
    fprintf(fid,datestr(now));
    fprintf(fid,'\n');
end
%
%== Vertical interpolation (t,s,u,v) from standard z-level to s-level
%
temp=roms_from_stdlev_mw(gn.lon_rho,gn.lat_rho,clm.z,clm.temp,gn,'rho',0);
clm=rmfield(clm,'temp');
%
%== output temp
%
RN=netcdf.open(fn,'NC_WRITE');
tempid=netcdf.inqVarID(RN,'temp');
netcdf.putVar(RN,tempid,shiftdim(temp,1));
netcdf.close(RN);
clear temp;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Interpolating salt for ',datestr(T1)]);
tts=1;
clm.salt=zeros([length(clm.z) size(gn.lon_rho)]);
try
    tmpt=ncread(urls,'salinity',[clm.ig0 clm.jg0 1 1],[clm.ig1-clm.ig0+1 clm.jg1-clm.jg0+1 tz_levs 1 ] );
    for k=1:tz_levs
        disp(['doing griddata salt for HYCOM level ' num2str(k)]);
        tmp=double(squeeze(tmpt(:,:,k)));
        F = scatteredInterpolant(X(:),Y(:),tmp(:));
        cff = F(gn.lon_rho,gn.lat_rho);
        cff(cff<0)=nan;
        clm.salt(k,:,:)=maplev(cff);
    end
    tts=0;
catch
    disp(['catch temp Unable to download HYCOM temp data at' datestr(now)]);
    fid=fopen('coawstlog.txt','a');
    fprintf(fid,'Unable to download HYCOM temp data at');
    fprintf(fid,datestr(now));
    fprintf(fid,'\n');
end
%
%== Vertical interpolation (t,s,u,v) from standard z-level to s-level
%
salt=roms_from_stdlev_mw(gn.lon_rho,gn.lat_rho,clm.z,clm.salt,gn,'rho',0);
clm=rmfield(clm,'salt');
%
%== output salt
%
RN=netcdf.open(fn,'NC_WRITE');
tempid=netcdf.inqVarID(RN,'salt');
netcdf.putVar(RN,tempid,shiftdim(salt,1));
netcdf.close(RN);
clear salt;

disp(['Finished creating clim file at ' datestr(now)]);
%%
