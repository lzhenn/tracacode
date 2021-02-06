import matplotlib.pyplot as plt
import numpy as np

import cartopy.crs as ccrs



def main():
    fig = plt.figure(figsize=(10, 5))
    ax = fig.add_subplot(1, 1, 1, projection=ccrs.Mollweide())

    lons, lats, data = sample_data()

    ax.contourf(lons, lats, data,
                transform=ccrs.PlateCarree(),
                cmap='nipy_spectral')
    ax.coastlines()
    ax.set_global()
    plt.show()


if __name__ == '__main__':
    main()
