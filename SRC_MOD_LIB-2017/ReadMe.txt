This folder archives all source code modifications to CESM1.2 (or other models in the future) that I have implemented during my research.

++SourceMods-CAM4-MAM-heat
    Intensify/Suppress convective heating rate (J/kg/s) over a certain region/time, a detailed introduction can be found in the Methods section in https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4962042/ 

++SourceMods-Nudging    
    Nudge a user-specified field (3-D structure evolves in time) in the model runtime.

++SourceMods-ideal-folding-heat
    Impose a 3-D heating anomaly over a certain region/time in the idealized simulation (F_IDEAL).
 
++SourceMods-mod_canopyNgrd_albd
    Dynamically modify the albedo calculation before the radiation allocation and update in the land surface model (CLM4).
 
++SourceMods-shf
    Remove the vertical diffusion (turbulance) caused heating to the atmosphere over the Tibetan Platau. This process can be treated as, instead of redistributing the surface heating, the turbulance eats up all surface heating like a black hole. Therefore, this is nearly shutdown the surface heating by the TP.


    LZN
    Sep 18, 2017
