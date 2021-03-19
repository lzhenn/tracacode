### SourceMods-phys_audit
PHYS_AUDIT is an online, process-based audit module in CAM physics package. The idea is sourced from [Lu and Cai (2010)](https://link.springer.com/content/pdf/10.1007/s00382-009-0673-x.pdf) in an idealized CGCM to quantify contributions to polar warming amplification.
Please use keyword "LZN" to lock the modification parts.

``` fortran
   call  define_audit_fld('BF_DPCV', 'before deep convection')
   call  define_audit_fld('AF_DPCV', 'after deep convection')

   call  define_audit_fld('BF_SLCV', 'before shallow convection')
   call  define_audit_fld('AF_SLCV', 'after shallow convection')
   
   call  define_audit_fld('BF_SFVD', 'before surf. exc. PBL diff. and dry depo.')
   call  define_audit_fld('AF_SFVD', 'after surf. exc. PBL diff. and dry depo.')
   
   call  define_audit_fld('BF_MIPH', 'before stratiform and microphysics')
   call  define_audit_fld('AF_MIPH', 'after stratiform and microphysics')
   
   call  define_audit_fld('BF_WTAR', 'before aerosol wet chemistry')
   call  define_audit_fld('AF_WTAR', 'after aerosol wet chemistry')
   
   call  define_audit_fld('BF_RADI', 'before radiation')
   call  define_audit_fld('AF_RADI', 'after radiation')
   
   call  define_audit_fld('BF_GWDG', 'before gravity wave drag')
   call  define_audit_fld('AF_GWDG', 'after gravity wave drag')
   
   call  define_audit_fld('BF_ENFX', 'before energy fixer')
   call  define_audit_fld('AF_ENFX', 'after energy fixer')
   
   call  define_audit_fld('BF_DRAD', 'before dry adjustment')
   call  define_audit_fld('AF_DRAD', 'after dry adjustment')
   
   call  define_audit_fld('BF_DYCO', 'before dynamical core')
   call  define_audit_fld('AF_DYCO', 'after dynamical core')
```

**Use external input aiming fields. Please use keyword "LZN" to lock the modification parts.**


