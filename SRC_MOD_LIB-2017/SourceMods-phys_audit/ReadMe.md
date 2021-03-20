### SourceMods-phys_audit
PHYS_AUDIT is an online, process-based audit module in CAM physics package. The idea is sourced from [Lu and Cai (2010)](https://link.springer.com/content/pdf/10.1007/s00382-009-0673-x.pdf) in an idealized CGCM to quantify contributions to polar warming amplification.
Please use keyword "LZN" to lock the modification parts.

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

The following variables have been archived before/after each round of individual subprocess executions. 

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


If you hope to diagnose the budget of one variable before and after a certain physical process, surplus/deficit can be given by:


**Use external input aiming fields. Please use keyword "LZN" to lock the modification parts.**


