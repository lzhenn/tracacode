; Those are functions that I use for ROMS model visualization via NCL
; Ivica, 2012
; ivica@irb.hr
;
; u2rho     transfer variable from u coords to rho
; v2rho     transfer variable from v coords to rho
; uv_rot    rotate u,v for given angle
; roms_3d_interp    interpolates 3D var onto given depth at the rho points
;           if variable is not on the rho it is internaly put
undef("u2rho")
function u2rho(u:numeric)
;*************************************************************************
; u is variable defined on "u" coordinate of staggered ROMS C grid 
; output is at the rho points by averaging and adding the first/last record
; Example:
; ur=u2rho(u)
;       u can be 2, 3 or 4 dim array but operation is done on the 
;       last 2 dimensions
;*************************************************************************
local dims,nd,dimX,dimY

begin
  dims  = dimsizes(u)
  nd    = dimsizes(dims)
  dimY  = dims(nd-2)
  dimX  = dims(nd-1)

  if (nd.eq.2) then
    ur = new((/dimY,dimX+1/),typeof(u))
    ur(:,1:dimX-1) = 0.5*(u(:,:dimX-2) + u(:,1:dimX-1))
    ur(:,0)=ur(:,1)
    ur(:,dimX)=ur(:,dimX-1)
  end if
  if (nd.eq.3) then
        ur = new((/dims(0),dimY,dimX+1/),typeof(u))
    ur(:,:,1:dimX-1) = 0.5*(u(:,:,:dimX-2) + u(:,:,1:dimX-1))
    ur(:,:,0)=ur(:,:,1)
    ur(:,:,dimX)=ur(:,:,dimX-1)
  end if
  if (nd.eq.4) then
        ur = new((/dims(0),dims(1),dimY,dimX+1/),typeof(u))
    ur(:,:,:,1:dimX-1) = 0.5*(u(:,:,:,:dimX-2) + u(:,:,:,1:dimX-1))
    ur(:,:,:,0)=ur(:,:,:,1)
    ur(:,:,:,dimX)=ur(:,:,:,dimX-1)
  end if

  ur@coordinates = "lon_rho lat_rho"
  ur@longName = "unstaggered u"
  return(ur)
end
;------------------------------------------------------------------------------
undef("v2rho")
function v2rho(v:numeric)
;*************************************************************************
; v is variable defined on "v" coordinate of staggered ROMS C grid 
; output is at the rho points by averaging and adding the first/last record
; Example:
; vr=v2rho(v)
;       v can be 2, 3 or 4 dim array but operation is done on the 
;       last 2 dimensions
;*************************************************************************
local dims,nd,dimX,dimY
begin
  dims  = dimsizes(v)
  nd    = dimsizes(dims)
  dimY  = dims(nd-2)
  dimX  = dims(nd-1)

  if (nd.eq.2) then
    vr = new((/dimY+1,dimX/),typeof(v))
    vr(1:dimY-1,:) = 0.5*(v(:dimY-2,:) + v(1:dimY-1,:))
    vr(0,:)=vr(1,:)
    vr(dimY,:)=vr(dimY-1,:)
  end if
  if (nd.eq.3) then
        vr = new((/dims(0),dimY+1,dimX/),typeof(v))
    vr(:,1:dimY-1,:) = 0.5*(v(:,:dimY-2,:) + v(:,1:dimY-1,:))
    vr(:,0,:)=vr(:,1,:)
    vr(:,dimY,:)=vr(:,dimY-1,:)
  end if
  if (nd.eq.4) then
        vr = new((/dims(0),dims(1),dimY+1,dimX/),typeof(v))
    vr(:,:,1:dimY-1,:) = 0.5*(v(:,:,:dimY-2,:) + v(:,:,1:dimY-1,:))
    vr(:,:,0,:)=vr(:,:,1,:)
    vr(:,:,dimY,:)=vr(:,:,dimY-1,:)
  end if

  vr@coordinates = "lon_rho lat_rho"
  vr@longName = "unstaggered v"
  return(vr)
end
;------------------------------------------------------------------------------
undef("uv_rot")
function uv_rot(ur:numeric,vr:numeric,angle:numeric)
;*************************************************************************
; ur,vr are variables defined on "rho" coordinate of staggered ROMS C grid
; using function like u2rho and v2rho.
; Angle is given rotation angle (radians) defined on the "rho" coords. 
; Output is urot,vrot at the rho point rotated for given angle
; Example:
; ur=v2rho(u)
; vr=v2rho(v)
; uvrot=uv_rot(ur,vr,angle)
;       ur,vr can be 2, 3 or 4 dim array but operation is done on the 
;       last 2 dimensions
; urot=uvrot(0,:) vrot=uvrot(1,:)
;*************************************************************************
local ca, sa, dims, nd, a 
begin
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
a=dble2flt(angle)
dims=dimsizes(ur)
nd=dimsizes(dims)
if (nd.eq.2)
    uvrot=new((/2,dims(0),dims(1)/),typeof(ur))
    uvrot(0,:,:)=ur*cos(a)-vr*sin(a)
    uvrot(1,:,:)=ur*sin(a)+vr*cos(a)
end if
if (nd.eq.3)
ang=conform(dims,a,2);
    uvrot=new((/2,dims(0),dims(1),dims(2)/),typeof(ur))
    uvrot(0,:,:,:)=ur*cos(ang)-vr*sin(ang)
    uvrot(1,:,:,:)=ur*sin(ang)+vr*cos(ang)
end if
if (nd.eq.4)
ang=conform(dims,a,(/2,3/));
    uvrot=new((/2,dims(0),dims(1),dims(2),dims(3)/),typeof(ur))
    uvrot(0,:,:,:,:)=ur*cos(ang)-vr*sin(ang)
    uvrot(1,:,:,:,:)=ur*sin(ang)+vr*cos(ang)
end if

return(uvrot)
end
;------------------------------------------------------------------------------
undef("roms_3d_interp")
function roms_3d_interp( file_handle, var:string, \
rec:integer, z:numeric )
;*************************************************************************
; slice=roms_3d_interp(file_handle,"temp",record,-10)
; interpolates from file_handle variable "temp" for time record at -10m depth
; if record is -1 than I have no time, i.e. pure 3D (like in avg file)
; if inside file_handle I can find zeta it will be used in depth calculation
; otherwise it is assumed zero. Depth constants are must.
;*************************************************************************
local h, Cs_r, hc, Sc_r, zeta, depth, \
hinv, N, cff, cffr, x, y, yi, vtransform
begin
err = NhlGetErrorObjectId()
  setvalues err
    "errLevel" : "Fatal"          ; only report Fatal errors
  end setvalues

if(typeof(file_handle).eq."file") then
    ISFILE = True
    nc_file = file_handle
  else if(typeof(file_handle).eq."list") then
    ISFILE = False
    nc_file = file_handle[0]
  else
    print("roms_interp_3d: error: the first argument must be a file or a list of files opened with addfile or addfiles")
    return
  end if
end if


if (rec.eq.-1) then
    if(ISFILE) then
        vin = nc_file->$var$(0,:,:,:)
    else
        vin = file_handle[:]->$var$
    end if
else
    if(ISFILE) then
                vin = nc_file->$var$(rec,:,:,:)
        else
                vin = file_handle[:]->$var$(rec,:,:,:)
        end if
end if
; chech if it is defined on "u" coords and transfer it on the "rho"
if(var.eq."u") then
    vin_rho=u2rho(vin)
    delete(vin)
    vin=vin_rho
    delete(vin_rho)
end if

; chech if it is defined on "v" coords and transfer it on the "rho"
if(var.eq."v") then
    vin_rho=v2rho(vin)
    delete(vin)
    vin=vin_rho
    delete(vin_rho)
end if

if(isfilevar(nc_file,"h"))
    h = nc_file->h
else
    print("Do not have h in file needed for depth calculations")
    return
end if

if(isfilevar(nc_file,"hc"))
    hc = nc_file->hc
else
    print("Do not have hc in file needed for depth calculations")
    return
end if

if(isfilevar(nc_file,"Cs_r"))
    Cs_r = nc_file->Cs_r
else
    print("Do not have Cs_r in file needed for depth calculations")
    return
end if

if(isfilevar(nc_file,"s_rho"))
    Sc_r = nc_file->s_rho
else
    print("Do not have Sc_r in file needed for depth calculations")
    return
end if

if(isfilevar(nc_file,"Vtransform"))
    vtransform = nc_file->Vtransform
else
    print("Do not have Vtransform in file needed for depth calculations, using 2 as default")
    vtransform = 2
    return
end if

zeta=new(dimsizes(h),typeof(h))
zeta=0

; have all I need for depth calculation
dims=dimsizes(vin)
depth=new(dims,typeof(vin))
hinv=1./h
N=dims(0)
if (vtransform.eq.2)
 do k=0,N-1
    cff = 1./(hc + h);
    cffr = hc*Sc_r(k) + h*Cs_r(k);
    depth(k,:,:)=doubletofloat(zeta + ( zeta + h )*cffr*cff)
 end do
 end if

 if (vtransform.eq.1)
 do k=0,N-1
    cffr = hc*(Sc_r(k) - Cs_r(k))
    depth(k,:,:)=doubletofloat(cffr+Cs_r(k)*h + zeta*(1+(cffr+Cs_r(k)*h)*hinv))
 end do
 end if
 print(depth)
 out=new(dimsizes(h),typeof(vin))
 do i=0,dims(1)-1
  do j=0,dims(2)-1
    x=depth(:,i,j)
    y=vin(:,i,j)
    yi=linint1(x,y,False,z,0);
    if(.not.all(ismissing(yi)))
    out(i,j)=yi;
    end if
   end do
 end do
return(out)
end
;------------------------------------------------------------------------------
undef("add_2d")
procedure add_2d(x:numeric, lat2d[*][*]:numeric, lon2d[*][*]:numeric)
;*************************************************************************
; trivial utility to attach lat and lon arrays
; D. Shea 
;*************************************************************************
begin
  x@lat2d = lat2d  
  x@lon2d = lon2d  
end

