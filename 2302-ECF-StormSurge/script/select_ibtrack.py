import pandas as pd
import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('agg')
# Constants
BIGFONT=22
MIDFONT=18
SMFONT=14

MAP_RES='10m'
FIG_FMT='pdf'



data_dir="/home/lzhenn/array74/data/ecf/"
# Read in the ibtracs csv file
ibtracs = pd.read_csv(data_dir+"ibtracs.WP.1979.csv", header=0, skiprows=[1],na_values={"NaN":' '})
filtered_data = ibtracs.loc[(ibtracs.SEASON>=1993)]
filtered_data = filtered_data.loc[(ibtracs.USA_STATUS.isin(["TY", "HU", "SU"]))] 
filtered_data['USA_LAT'] = pd.to_numeric(filtered_data['USA_LAT'], errors='coerce').astype(float)
filtered_data['USA_LON'] = pd.to_numeric(filtered_data['USA_LON'], errors='coerce').astype(float)
filtered_data=filtered_data.loc[
    (filtered_data.DIST2LAND <= 500) & 
    (filtered_data.USA_LAT > 10) & (filtered_data.USA_LAT < 28) &
    (filtered_data.USA_LON > 105) & (filtered_data.USA_LON < 127)]
filtered_data['USA_WIND']=pd.to_numeric(filtered_data.USA_WIND)
filtered_data=filtered_data.loc[filtered_data.USA_WIND >= 90]


print(filtered_data['SID'].unique())
print(len(filtered_data['SID'].unique()))


filtered_data.to_csv(data_dir+"ibtracs.WP.selected.csv", index=False)


# Create the figure
fig = plt.figure(figsize=(10, 10))
ax = fig.add_subplot(1, 1, 1, projection=ccrs.PlateCarree())
ax.coastlines()

# Plot typhoon tracks
for name, group in filtered_data.groupby('SID'):
    ax.plot(group['USA_LON'], group['USA_LAT'], label=name)

#ax.legend()
plt.savefig('../fig/trck.png', dpi=300, bbox_inches='tight')

# Save the filtered data to a new csv file
#filtered_data.to_csv(data_dir+"ibtracs.WP.selected.csv", index=False)