import xarray as xr
import numpy as np
from scipy.ndimage import generic_filter

# Load your dataset
ds = xr.open_dataset('/home/lzhenn/array130/poseidon/2018091200_noluzon/roms_his_d03_00001.nc')
mask_rho = ds['mask_rho'].values  # Assuming mask_rho is the variable name

# Function to classify each grid based on its neighbors
def classify_grid(values):
    center = values[4]  # Center value
    neighbors = values[:4].tolist() + values[5:].tolist()  # 8 neighbors

    # Check if we have valid neighbors
    valid_neighbors = [n for n in neighbors if n is not None]
    
    if center == 0:  # Land
        if all(n == 0 for n in valid_neighbors):
            return 0  # All land
        else:
            return 1  # At least one sea neighbor
    else:  # Sea
        if all(n == 1 for n in valid_neighbors):
            return 3  # All sea
        else:
            return 2  # At least one land neighbor

# Apply the classification function using a 3x3 window
classified_mask = generic_filter(mask_rho, classify_grid, size=(3, 3), mode='constant', cval=1)

# Convert the result to an xarray DataArray
classified_mask_da = ds['mask_rho'].copy()
classified_mask_da.values=classified_mask

# Save the result or further process
classified_mask_da.to_netcdf('/home/lzhenn/array74/workspace/uranus/uranus/domaindb/poseidon_1500m_L12/classified_mask.nc')