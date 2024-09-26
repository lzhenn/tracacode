import os
import xarray as xr
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import pandas as pd
matplotlib.use('agg')
# Define your parameters
ix = 476
iys = 384
iye = 404 
# Initialize a list to store flow values
flow_values = []
#work_path='/home/lzhenn/array130/poseidon/2018091200_noluzon/'
work_path='/home/lzhenn/array129/poseidon/2018091200/'
# File paths
# Loop through the files
ts_pd=pd.date_range('2018-09-15 12:00:00', '2018-09-17 00:00:00', freq='15T')
for i in range(145, 290):
    roms_fn=f'{work_path}/roms_his_d03_{i:05d}.nc'
    try:
        ds = xr.open_dataset(roms_fn)
    except:
        continue
    # Extract the necessary variables
    h = ds['h'].isel(xi_rho=ix, eta_rho=slice(iys, iye))
    vbar = ds['vbar'].isel(xi_v=ix, eta_v=slice(iys, iye))

    # Calculate the flow (vbar * h)
    flow = -(vbar * h*100.0).sum().item()

    # Append the flow value
    flow_values.append(flow)

    ds.close()
flow_values=np.array(flow_values)
# Plot the timeseries
plt.figure(figsize=(10, 4))
plt.plot(ts_pd, flow_values, marker='.', linestyle='-',color='black')
plt.fill_between(
        ts_pd,0, np.where(flow_values > 0, flow_values, 0),
        label='charging current', color='lightcoral',alpha=0.8)
plt.fill_between(
        ts_pd, np.where(flow_values < 0, flow_values, 0), 0,
        label='Discharging current',color='lightblue',alpha=0.8)
plt.xlabel('Time')
plt.ylabel('Channel Flow (m^3/s)')
plt.title('Channel Flow Time Series')
plt.grid(True)
plt.savefig(os.path.join(f'../fig/tolo_harbour_channel_flow.png'), 
    dpi=300, bbox_inches='tight', pad_inches=0)