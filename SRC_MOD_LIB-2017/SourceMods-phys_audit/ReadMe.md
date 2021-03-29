# SourceMods-phys_audit

## Overview 

PHYS_AUDIT is an online, process-based audit module in CAM physics package. The idea is sourced from [Lu and Cai (2010)](https://link.springer.com/content/pdf/10.1007/s00382-009-0673-x.pdf) in an idealized CGCM to quantify contributions to polar warming amplification.
Please use keyword "LZN" to lock the modification parts in source code. Please [refer this](https://github.com/Novarizark/tracacode/blob/master/SRC_MOD_LIB-2017/ReadMe.md) for how to embed this module in CESM workflow.

## Catagory
    
* [Subprocesses and Variables](#subprocesses-and-variables)
* [Audit the Budget](#audit-the-budget)
* [Customize Your Output](#customize-your-output)
* [Core Subroutine](#core-subroutine)

### Subprocesses and Variables

Currently, the `physpkg.F90` in CAM workflow has been seperated into the following subprocesses for audit. Note that they are not seperated in "elemental" processes presenting in `physpkg.F90`.
For example, we combined Rayleigh friction, PBL vertical diffusion, and aerosol dry deposition together as `SFVD`.

| Short Name | Long Name                         |
| ----       | ----                              |
|DPCV        | deep convection                   |
|SLCV        | shallow convection                |
|SFVD        | surf. exc. PBL diff. and dry depo.|
|MIPH        | stratiform and microphysics       |
|WTAR        | aerosol wet chemistry             |
|RADI        | radiation                         |
|GWDG        | gravity wave drag                 |
|ENFX        | energy fixer                      |
|DRAD        | dry adjustment                    |
|DYCO        | dynamical core                    |

The following variables have been archived before/after each round of individual subprocess execution. 

| Short Name | Long Name                                        | Unit      |
| ----       | ----                                             | ----      |
|M           | Gridbox air mass                                 | kg        |
|INTE        | Gridbox internal energy                          | J         |
|KNTE        | Gridbox kinetic energy                           | J         |
|LATE        | Gridbox unreleased water vapor latent heat       | J         |
|T           | Air temperature                                  | K         |
|U           | Zonal wind                                       | m/s       |
|V           | Meridional wind                                  | m/s       |
|S           | Dry static energy                                | J/kg      |
|W           | Vertical velocity                                | Pa/s      |
|PDEL        | Gridbox vertical layer thickness                 | Pa        |
|ZM          | Midpoint geopotential hiehgt                     | m         |
|Q           | Water vapor mixing ratio                         | kg/kg     |
|PS          | Surface pressure                                 | Pa        |

Therefore, if output complete list of variables before/after each round of subprocess execution in additional files, there would be **2x10x13=260** additional variables in output flow.

### Audit the Budget

If you hope to audit the budget of one specific variable (e.g. gridbox air mass) before and after a certain physical process (e.g. deep convection), please locate the following variables in `*cam.h{i}*`:

``` bash
float M_BF_DPCV(time, lev, lat, lon) ;
    M_BF_DPCV:mdims = 1 ;
    M_BF_DPCV:units = "kg" ;
    M_BF_DPCV:long_name = "Gridbox air mass before deep convection" ;
    M_BF_DPCV:cell_methods = "time: mean" ;
float M_AF_DPCV(time, lev, lat, lon) ;
    M_AF_DPCV:mdims = 1 ;
    M_AF_DPCV:units = "kg" ;
    M_AF_DPCV:long_name = "Gridbox air mass after deep convection" ;
    M_AF_DPCV:cell_methods = "time: mean" ;
```

The **average** surplus/deficit of gridbox air mass after **single call** of deep convection can be given by:

>**M_budget=(M_AF_DPCV-M_BF_DPCV)**

If you are interested in the budget in unit time or a single day:

>M_budget_v=M_budget/dt
>M_budget_day=M_budget_v*SECONDS_IN_A_DAY

where `dt` is the CAM physical timestep, by default, `dt=1800s`. Obviously, `SECONDS_IN_A_DAY=86400s`.


### Customize Your Output

You could add/delete desired variables, adjust the sampling frequency to average the budget, or organize the *cam.h{i}* file in `user_cam_nl`, 
please refer the official document of CESM1.2. 
([doc1](https://www.cesm.ucar.edu/models/cesm1.2/cesm/doc/usersguide/x2268.html),
[doc2](https://www.cesm.ucar.edu/models/cesm1.2/cesm/doc/usersguide/x2172.html).)

A sample for monthly averaged, full-list output `user_cam_nl` is presented below:

```
avgflag_pertape = 'A', 'A', 'A', 'A'
nhtfrq = 0, 0,  0,  0
mfilt  = 1,  1,  1, 1
fincl2 = 'T_BF_DPCV', 'U_BF_DPCV', 'V_BF_DPCV', 'S_BF_DPCV', 'W_BF_DPCV', 'PDEL_BF_DPCV', 'ZM_BF_DPCV', 'Q_BF_DPCV', 'PS_BF_DPCV', 'T_AF_DPCV', 'U_AF_DPCV', 'V_AF_DPCV', 'S_AF_DPCV', 'W_AF_DPCV', 'PDEL_AF_DPCV', 'ZM_AF_DPCV', 'Q_AF_DPCV', 'PS_AF_DPCV', 
'T_BF_SLCV', 'U_BF_SLCV', 'V_BF_SLCV', 'S_BF_SLCV', 'W_BF_SLCV', 'PDEL_BF_SLCV', 'ZM_BF_SLCV', 'Q_BF_SLCV', 'PS_BF_SLCV', 'T_AF_SLCV', 'U_AF_SLCV', 'V_AF_SLCV', 'S_AF_SLCV', 'W_AF_SLCV', 'PDEL_AF_SLCV', 'ZM_AF_SLCV', 'Q_AF_SLCV', 'PS_AF_SLCV' , 
'T_BF_SFVD', 'U_BF_SFVD', 'V_BF_SFVD', 'S_BF_SFVD', 'W_BF_SFVD', 'PDEL_BF_SFVD', 'ZM_BF_SFVD', 'Q_BF_SFVD', 'PS_BF_SFVD', 'T_AF_SFVD', 'U_AF_SFVD', 'V_AF_SFVD', 'S_AF_SFVD', 'W_AF_SFVD', 'PDEL_AF_SFVD', 'ZM_AF_SFVD', 'Q_AF_SFVD', 'PS_AF_SFVD' , 
'T_BF_MIPH', 'U_BF_MIPH', 'V_BF_MIPH', 'S_BF_MIPH', 'W_BF_MIPH', 'PDEL_BF_MIPH', 'ZM_BF_MIPH', 'Q_BF_MIPH', 'PS_BF_MIPH', 'T_AF_MIPH', 'U_AF_MIPH', 'V_AF_MIPH', 'S_AF_MIPH', 'W_AF_MIPH', 'PDEL_AF_MIPH', 'ZM_AF_MIPH', 'Q_AF_MIPH', 'PS_AF_MIPH', 
'T_BF_WTAR', 'U_BF_WTAR', 'V_BF_WTAR', 'S_BF_WTAR', 'W_BF_WTAR', 'PDEL_BF_WTAR', 'ZM_BF_WTAR', 'Q_BF_WTAR', 'PS_BF_WTAR', 'T_AF_WTAR', 'U_AF_WTAR', 'V_AF_WTAR', 'S_AF_WTAR', 'W_AF_WTAR', 'PDEL_AF_WTAR', 'ZM_AF_WTAR', 'Q_AF_WTAR', 'PS_AF_WTAR' , 
'T_BF_RADI', 'U_BF_RADI', 'V_BF_RADI', 'S_BF_RADI', 'W_BF_RADI', 'PDEL_BF_RADI', 'ZM_BF_RADI', 'Q_BF_RADI', 'PS_BF_RADI', 'T_AF_RADI', 'U_AF_RADI', 'V_AF_RADI', 'S_AF_RADI', 'W_AF_RADI', 'PDEL_AF_RADI', 'ZM_AF_RADI', 'Q_AF_RADI', 'PS_AF_RADI' 
fincl3 = 'T_BF_GWDG', 'U_BF_GWDG', 'V_BF_GWDG', 'S_BF_GWDG', 'W_BF_GWDG', 'PDEL_BF_GWDG', 'ZM_BF_GWDG', 'Q_BF_GWDG', 'PS_BF_GWDG', 'T_AF_GWDG', 'U_AF_GWDG', 'V_AF_GWDG', 'S_AF_GWDG', 'W_AF_GWDG', 'PDEL_AF_GWDG', 'ZM_AF_GWDG', 'Q_AF_GWDG', 'PS_AF_GWDG', 
'T_BF_ENFX', 'U_BF_ENFX', 'V_BF_ENFX', 'S_BF_ENFX', 'W_BF_ENFX', 'PDEL_BF_ENFX', 'ZM_BF_ENFX', 'Q_BF_ENFX', 'PS_BF_ENFX', 'T_AF_ENFX', 'U_AF_ENFX', 'V_AF_ENFX', 'S_AF_ENFX', 'W_AF_ENFX', 'PDEL_AF_ENFX', 'ZM_AF_ENFX', 'Q_AF_ENFX', 'PS_AF_ENFX' , 
'T_BF_DRAD', 'U_BF_DRAD', 'V_BF_DRAD', 'S_BF_DRAD', 'W_BF_DRAD', 'PDEL_BF_DRAD', 'ZM_BF_DRAD', 'Q_BF_DRAD', 'PS_BF_DRAD', 'T_AF_DRAD', 'U_AF_DRAD', 'V_AF_DRAD', 'S_AF_DRAD', 'W_AF_DRAD', 'PDEL_AF_DRAD', 'ZM_AF_DRAD', 'Q_AF_DRAD', 'PS_AF_DRAD' , 
'T_BF_DYCO', 'U_BF_DYCO', 'V_BF_DYCO', 'S_BF_DYCO', 'W_BF_DYCO', 'PDEL_BF_DYCO', 'ZM_BF_DYCO', 'Q_BF_DYCO', 'PS_BF_DYCO', 'T_AF_DYCO', 'U_AF_DYCO', 'V_AF_DYCO', 'S_AF_DYCO', 'W_AF_DYCO', 'PDEL_AF_DYCO', 'ZM_AF_DYCO', 'Q_AF_DYCO', 'PS_AF_DYCO' 
fincl4 = 'M_BF_DPCV', 'M_AF_DPCV', 'M_BF_SLCV', 'M_AF_SLCV', 'M_BF_SFVD', 'M_AF_SFVD', 'M_BF_MIPH', 'M_AF_MIPH', 'M_BF_WTAR', 'M_AF_WTAR', 'M_BF_RADI','M_AF_RADI','M_BF_GWDG','M_AF_GWDG','M_BF_ENFX','M_AF_ENFX','M_BF_DRAD','M_AF_DRAD','M_BF_DYCO','M_AF_DYCO', 
'INTE_BF_DPCV', 'INTE_AF_DPCV', 'INTE_BF_SLCV', 'INTE_AF_SLCV', 'INTE_BF_SFVD', 'INTE_AF_SFVD', 'INTE_BF_MIPH', 'INTE_AF_MIPH', 'INTE_BF_WTAR', 'INTE_AF_WTAR', 'INTE_BF_RADI','INTE_AF_RADI','INTE_BF_GWDG','INTE_AF_GWDG','INTE_BF_ENFX','INTE_AF_ENFX','INTE_BF_DRAD','INTE_AF_DRAD','INTE_BF_DYCO','INTE_AF_DYCO', 
'KNTE_BF_DPCV', 'KNTE_AF_DPCV', 'KNTE_BF_SLCV', 'KNTE_AF_SLCV', 'KNTE_BF_SFVD', 'KNTE_AF_SFVD', 'KNTE_BF_MIPH', 'KNTE_AF_MIPH', 'KNTE_BF_WTAR', 'KNTE_AF_WTAR', 'KNTE_BF_RADI','KNTE_AF_RADI','KNTE_BF_GWDG','KNTE_AF_GWDG','KNTE_BF_ENFX','KNTE_AF_ENFX','KNTE_BF_DRAD','KNTE_AF_DRAD','KNTE_BF_DYCO','KNTE_AF_DYCO', 
'LATE_BF_DPCV', 'LATE_AF_DPCV', 'LATE_BF_SLCV', 'LATE_AF_SLCV', 'LATE_BF_SFVD', 'LATE_AF_SFVD', 'LATE_BF_MIPH', 'LATE_AF_MIPH', 'LATE_BF_WTAR', 'LATE_AF_WTAR', 'LATE_BF_RADI','LATE_AF_RADI','LATE_BF_GWDG','LATE_AF_GWDG','LATE_BF_ENFX','LATE_AF_ENFX','LATE_BF_DRAD','LATE_AF_DRAD','LATE_BF_DYCO','LATE_AF_DYCO'
 
```
### Core Subroutine

`phys_audit` is the key subroutine embedded in `physpkg.F90` to audit the subprocesses. 
It will be called before and after each round of individual execution of subprocess, with proper string indicating calling position.
The snippet of `phys_audit` can be found below:

```fortran
subroutine phys_audit(proc_str, state)
    
    use cam_history,    only: outfld
    use physconst, only: pi, rearth, cpair, gravit, latvap
    use phys_grid, only: get_area_all_p

    character(len=*), intent(in) ::  proc_str  
    type(physics_state), intent(inout) :: state
    
    integer :: ichnk, k                        ! chunk idx, vertical loop idx

    real(r8) :: area(pcols)           ! area in radians squared for each grid point
    
    real(r8) ::int_eng      (pcols,pver) ! total internal energy in the grid box (J)
    real(r8) ::knt_eng      (pcols,pver) ! total  kinetic energy in the grid box (J)
    real(r8) ::lat_eng      (pcols,pver) ! total latent heat of water vapor in the grid box (J)
    real(r8) ::mass      (pcols,pver) ! total mass in the grid box (kg)
    ichnk=state%lchnk
    
    call get_area_all_p(ichnk, pcols, area) ! get grid area in steradian
    
    area(:pcols)=area(:pcols)*rearth**2 ! transfer steradian to area (m^2)
    do k = 1, pver
        mass(:pcols,k)=state%pdel(:pcols,k)*area(:pcols)/gravit
        int_eng(:pcols,k)=cpair*state%t(:pcols,k)*mass(:pcols,k)
        knt_eng(:pcols,k)=0.5_r8*mass(:pcols,k)*(state%u(:pcols,k)*state%u(:pcols,k)+state%v(:pcols,k)*state%v(:pcols,k))
        lat_eng(:pcols,k)=latvap*mass(:pcols,k)*state%q(:pcols,k,1)
    end do

    call outfld('T_'//trim(proc_str), state%t, pcols, ichnk)
    call outfld('U_'//trim(proc_str), state%u, pcols, ichnk)
    call outfld('V_'//trim(proc_str), state%v, pcols, ichnk)
    call outfld('S_'//trim(proc_str), state%s, pcols, ichnk)
    call outfld('W_'//trim(proc_str), state%omega, pcols, ichnk)
    call outfld('PDEL_'//trim(proc_str), state%pdel, pcols, ichnk)
    call outfld('ZM_'//trim(proc_str), state%zm, pcols, ichnk)
    call outfld('Q_'//trim(proc_str), state%q(:,:,1), pcols, ichnk)
    call outfld('PS_'//trim(proc_str), state%ps, pcols, ichnk)

    call outfld('M_'//trim(proc_str), mass, pcols, ichnk)
    call outfld('INTE_'//trim(proc_str), int_eng, pcols, ichnk)
    call outfld('KNTE_'//trim(proc_str), knt_eng, pcols, ichnk)
    call outfld('LATE_'//trim(proc_str), lat_eng, pcols, ichnk)
end subroutine phys_audit

```

Mar 20, 2021
