import pandas as pd
import matplotlib, os
import matplotlib.pyplot as plt

matplotlib.use('agg')
# Constants
BIGFONT=32
MIDFONT=28
SMFONT=22
# File paths
tide_file = '/disk/r074/lzhenn/data/luna/2018091400/tides.2018091400'
site_file = '/home/lzhenn/array74/workspace/luna-kit/db/site.csv'
hwave_sim='/home/lzhenn/array129/poseidon/2018091400_fc1.1/stas_Hwave_ts.csv'
#hwave_sim='/home/lzhenn/array74/data/archive/poseidon/2018091200/stas_Hwave_ts.csv'
zeta_sim='/home/lzhenn/array129/poseidon/2018091400_fc1.1/stas_zeta_ts.csv'
#zeta_sim='/home/lzhenn/array74/data/archive/poseidon/2018091200/stas_zeta_ts.csv'
obv_data='/home/lzhenn/array74/data/hko_tide/mangkhut_obv.csv'

# Define the time range
start_time = '2018-09-14 00:00:00'
end_time = '2018-09-17 00:00:00'


hwave_df=pd.read_csv(hwave_sim,parse_dates=True, date_format='%Y-%m-%d %H:%M:%S',index_col=0)
zeta_df=pd.read_csv(zeta_sim,parse_dates=True, date_format='%Y-%m-%d %H:%M:%S',index_col=0)
# Reading the tide data
tide_df = pd.read_csv(tide_file, delim_whitespace=True, skiprows=7,
                      names=['Lat', 'Lon', 'mm.dd.yyyy', 'hh:mm:ss', 'z(m)', 'Depth(m)'])


# Reading the site data
site_df = pd.read_csv(site_file)

obv_df=pd.read_csv(obv_data,parse_dates=True,index_col=0)
obv_df.index=obv_df.index+pd.Timedelta(hours=-8)
obv_df=obv_df[start_time:end_time]

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
    
    zeta=zeta_df[site_name]
    zeta_all=zeta.values+tide.values
    
    hw=hwave_df[site_name]
    lv_all=zeta_all+hw*0.4
    print(site_name)
    print(tide)
    print(zeta)
    print(zeta_all)
    # Create a new figure for each site
    plt.figure(figsize=(10, 8))
    
    # Plot the data
    plt.plot(layout='tight' )
    
    plt.fill_between(
            tfs, 0, tide, 
            label='Tide',color='lightblue',alpha=0.5)
    plt.fill_between(
            tfs, zeta_all, tide, 
            label='Tide+Surge',color='dodgerblue',alpha=0.5)
    plt.fill_between(
            tfs, lv_all, zeta_all, 
            label='Tide+Surge+Wave Setup',color='blue',alpha=0.5)
    plt.plot(tfs, lv_all, color='darkblue',linestyle='-',linewidth=2)
    plt.plot(tfs, zeta_all, color='blue',linestyle='--',linewidth=2)
    plt.plot(tfs, zeta, color='dodgerblue',linestyle='-',linewidth=2)
    plt.plot(tfs, tide, color='lightblue',linestyle=':',linewidth=2)
    plt.plot(obv_df.index, obv_df[site_name], color='black',marker='*',
             linestyle='',markersize=10, label='Observation')
    
    # Add labels, title, legend, and grid
    plt.xticks( fontsize=SMFONT, rotation=15)
    plt.yticks( fontsize=SMFONT) 
    plt.xlabel('Time', fontsize=SMFONT)
    plt.ylabel('Water Level (m)', fontsize=SMFONT)
    plt.title(f'{site_name}', fontsize=MIDFONT)
    plt.legend(fontsize=SMFONT)
    plt.grid(True)
    plt.ylim((0,7))
    plt.savefig(os.path.join(f'../fig/{site_name}_pgw.png'), 
        dpi=100, bbox_inches='tight', pad_inches=0)