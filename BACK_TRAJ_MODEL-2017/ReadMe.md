# Backward trajectory calculation based on ERA-Interim 6-hr UVW.

**Backward trajectory calculation is based on the linear interpolation and first-guess velocity for efficiency. Detailed accurate calculation can be found in http://journals.ametsoc.org/doi/abs/10.1175/BAMS-D-14-00110.1**

##control-run-traj-model.py
Control script to run the traj_model with multiple input files. Integration step and other parameters can be set here. You may run this script for batch calculation.

##back_traj_model-multi-input-files.py 
Core calculation script with multiple input files. You can modify this file to utilize accurate algrithm.

##back_traj_model-one-input-file.py
Calculation script with only one input file (multiple timeframes).

