import numpy as np
from netCDF4 import Dataset
from wrf import getvar, to_np
import matplotlib.pyplot as plt

# Use the Agg backend to save the figures as PNG files
plt.switch_backend("Agg")

# Define the file names for the control and sensitive experiments
'''
control_files = [
    '/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/present/2010072112/wrfout_d02_2010-07-23_12:00:00',
    '/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/present/2013052112/wrfout_d02_2013-05-22_12:00:00',   
    '/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/present/2020060500/wrfout_d02_2020-06-07_00:00:00',   
    '/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/present/2021062700/wrfout_d02_2021-06-29_00:00:00',   
    '/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/present/2023090600/wrfout_d02_2023-09-09_00:00:00',   
]
sensitive_files = [
    '/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/pgw/2010072112/wrfout_d02_2010-07-23_12:00:00',
    '/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/pgw/2013052112/wrfout_d02_2013-05-22_12:00:00',   
    '/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/pgw/2020060500/wrfout_d02_2020-06-07_00:00:00',   
    '/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/pgw/2021062700/wrfout_d02_2021-06-29_00:00:00',   
    '/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/pgw/2023090600/wrfout_d02_2023-09-09_00:00:00',   
]

2010072112  2012072000  2013052112  2017082100  2018091200  2020060500  2021062700  2023083000  2023090600
'''
control_files = [
    '/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/present/2012072000/wrfout_d02_2012-07-25_00:00:00',
    '/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/present/2017082100/wrfout_d02_2017-08-24_00:00:00',
    '/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/present/2018091200/wrfout_d02_2018-09-17_00:00:00',
    '/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/present/2023083000/wrfout_d02_2023-09-03_00:00:00',
]
sensitive_files = [
    '/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/pgw/2012072000/wrfout_d02_2012-07-25_00:00:00',
    '/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/pgw/2017082100/wrfout_d02_2017-08-24_00:00:00',
    '/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/pgw/2018091200/wrfout_d02_2018-09-17_00:00:00',
    '/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/pgw/2023083000/wrfout_d02_2023-09-03_00:00:00',
]

percentile = ['99','99.9','99.99']
amp=1.1
# Calculate the 1st and 0.1th percentile values for the control group
p1_control = []
p01_control = []
p001_control = []
for file in control_files:
    # Open the WRF output file
    ncfile = Dataset(file)
    # Get the precipitation variable
    precip = getvar(ncfile, "RAINNC")
    # Convert to numpy array
    precip_np = to_np(precip)
    # Calculate the 1st and 0.1th percentile values
    p1 = np.percentile(precip_np, float(percentile[0]))
    p01 = np.percentile(precip_np, float(percentile[1]))
    p001 = np.percentile(precip_np, float(percentile[2]))
    p1_control.append(p1)
    p01_control.append(p01)
    p001_control.append(p001)
# Calculate the 1st and 0.1th percentile values for the sensitive group
p1_sensitive = []
p01_sensitive = []
p001_sensitive = []
for file in sensitive_files:
    # Open the WRF output file
    ncfile = Dataset(file)

    # Get the precipitation variable
    precip = getvar(ncfile, "RAINNC")

    # Convert to numpy array
    precip_np = to_np(precip)

    # Calculate the 1st and 0.1th percentile values
    p1 = np.percentile(precip_np, float(percentile[0]))*amp
    p01 = np.percentile(precip_np, float(percentile[1]))*amp
    p001 = np.percentile(precip_np, float(percentile[2]))*amp
    p1_sensitive.append(p1)
    p01_sensitive.append(p01)
    p001_sensitive.append(p001)

species = (f'{percentile[0]}-th Percentile', f'{percentile[1]}-th Percentile'
           , f'{percentile[2]}-th Percentile')
means = {
    'Present Day': (
        np.mean(p1_control), np.mean(p01_control), np.mean(p001_control)),
    'Warming Future': (
        np.mean(p1_sensitive), np.mean(p01_sensitive), np.mean(p001_sensitive)),
}

x = np.arange(len(species))  # the label locations
width = 0.25  # the width of the bars
multiplier = 0

fig, ax = plt.subplots(layout='constrained')

for attribute, measurement in means.items():
    offset = width * multiplier
    values=[ int(val) for val in measurement]
    rects = ax.bar(x + offset, values, width, label=attribute)
    ax.bar_label(rects, padding=3)
    multiplier += 1

# Add some text for labels, title and custom x-axis tick labels, etc.
ax.set_ylabel("Precipitation (mm)")
ax.set_title('Accumulated rainfall by percentile (TC)')
ax.set_xticks(x + width, species)
ax.legend(loc='upper left', ncols=2)
plt.savefig("../fig/precip_percentile_TC.png")
