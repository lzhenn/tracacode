import pandas as pd
import numpy as np
import matplotlib, os
import matplotlib.pyplot as plt

matplotlib.use('agg')
# Constants
BIGFONT=32
MIDFONT=12
SMFONT=10
#work_path='/home/lzhenn/array129/poseidon/2018091200_2050thermo/'
work_path='/home/lzhenn/array130/poseidon/2018091200_noluzon/'
#work_path='/home/lzhenn/array129/poseidon/2018091200/'
# File paths
tide_file = '/disk/r074/lzhenn/data/luna/2045060100/tides.2045060100'
site_file = '/home/lzhenn/array74/workspace/luna-kit/db/site.csv'
#hwave_sim='/home/lzhenn/array129/poseidon/2018091400_fc1.1/stas_Hwave_ts.csv'
hwave_sim=f'{work_path}/stas_Hwave_ts.csv'
#zeta_sim='/home/lzhenn/array129/poseidon/2018091400_fc1.1/stas_zeta_ts.csv'
zeta_sim=f'{work_path}/stas_zeta_ts.csv'
obv_data='/home/lzhenn/array74/data/hko_tide/mangkhut_obv.csv'

# Define the time range
start_time = '2045-06-01 00:00:00'
end_time = '2045-11-01 00:00:00'


# Reading the tide data
tide_df = pd.read_csv(tide_file, delim_whitespace=True, skiprows=7,
                      names=['Lat', 'Lon', 'mm.dd.yyyy', 'hh:mm:ss', 'z(m)', 'Depth(m)'])

# Reading the site data
site_df = pd.read_csv(site_file)


# Convert 'mm.dd.yyyy hh:mm:ss' to datetime format
tide_df['datetime'] = pd.to_datetime(tide_df['mm.dd.yyyy'] + ' ' + tide_df['hh:mm:ss'], format='%m.%d.%Y %H:%M:%S')
tide_df = tide_df[(tide_df['datetime'] >= start_time) & (tide_df['datetime'] <= end_time)]

for index, site in site_df.iterrows():
    site_name = site['name']
    lon = site['lon']
    lat = site['lat']
    base=site['base']
     
    # Filter tide data for the current site
    site_tide_data = tide_df[(tide_df['Lat'] == lat) & (tide_df['Lon'] == lon)]
    tfs=site_tide_data['datetime']
    tide=site_tide_data['z(m)']+base
    
    print(site_name, np.max(tide.values))
    # Create a new figure for each site
    plt.figure(figsize=(12, 2))
    
    # Plot the data
    plt.plot(layout='tight' )
    
    
    plt.fill_between(
            tfs, 0, tide, 
            label='Tide',color='lightblue',alpha=0.8)
    plt.plot(tfs, tide, color='blue',linestyle='-',linewidth=0.5)
    
   
    # Add labels, title, legend, and grid
    plt.xticks( fontsize=SMFONT, rotation=15)
    plt.yticks( fontsize=SMFONT) 
    plt.xlabel('Time', fontsize=SMFONT)
    plt.ylabel('Water Level (m)', fontsize=SMFONT)
    plt.title(f'{site_name}', fontsize=MIDFONT)
    plt.legend(fontsize=SMFONT)
    plt.grid(True)
    plt.ylim((0,3.0))
    plt.savefig(os.path.join(f'../fig/{site_name}_tide.png'), 
        dpi=300, bbox_inches='tight', pad_inches=0)