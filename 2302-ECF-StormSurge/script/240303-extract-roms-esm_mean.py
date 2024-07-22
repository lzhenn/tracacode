import xarray as xr
import os
import concurrent.futures

path = '/home/lzhenn/array74/data/archive/poseidon/2018091600LTtmr'
workers=2

def take_esm_mean(folders, idx, fn):
    ensemble_data = []
    print(f'Processing file:{idx:02d}:{fn}')
    for folder in folders:
        file_path = os.path.join(path, folder, fn)
        ensemble_data.append(xr.load_dataset(file_path))
    ensemble_dataset = xr.concat(ensemble_data, dim='ensemble_member')
    ensemble_mean = ensemble_dataset.mean(dim='ensemble_member')
    ensemble_mean.to_netcdf(os.path.join(path, 'mean', fn))
    
def main():
    # list all the ensemble member folders
    folders = [f for f in os.listdir(path) if f.startswith('esm_')]
    fn_lst=[f for f in os.listdir(os.path.join(path,'esm_00')) if f.startswith('roms')] 
    # create the esm_mean directory if it doesn't exist
    esm_mean_dir = os.path.join(path, 'mean')
    if not os.path.exists(esm_mean_dir):
        os.makedirs(esm_mean_dir)

    with concurrent.futures.ProcessPoolExecutor(max_workers=workers) as executor:
        futures = [executor.submit(
            take_esm_mean, folders, idx, fn) for idx, fn in enumerate(fn_lst)] 
        concurrent.futures.wait(futures)
        
        for idx, f in enumerate(futures):
            if f.exception(): 
                print(f.result(),idx)
                exit()
                
                
if __name__ == '__main__':
    main()