# SourceMods-phys_audit

PHYS_AUDIT is an online, process-based audit module in CAM physics package. The idea is sourced from [Lu and Cai (2010)](https://link.springer.com/content/pdf/10.1007/s00382-009-0673-x.pdf) in an idealized CGCM to quantify contributions to polar warming amplification.
Please use keyword "LZN" to lock the modification parts in source code.

Currently, the `physpkg.F90` in CAM workflow has been seperated into the following subprocesses for audit. Note that they are not seperated in "elemental" processes presenting in `physpkg.F90`.
For example, we combined Rayleigh friction, PBL vertical diffusion, and aerosol dry deopsition together as `SFVD`.

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

>M_budget=(M_AF_DPCV-M_BF_DPCV)

If you are interested in the budget in unit time or a single day:

```
M_budget_v=M_budget/dt

M_budget_day=M_budget_v*SECONDS_IN_A_DAY
```

where `dt` is the CAM physical timestep, by default, `dt=1800s`. Obviously, `SECONDS_IN_A_DAY=86400s`.



