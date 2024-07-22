import os
import csv

# Define the column names for the CSV file
catagories={'AQ': 'Air Quality Data', 
            'AWS': 'Automatical Weather Station / Profile Data', 
            'BIOM':'Biomass Data', 
            'CAM':'Camera Images',
            'CHEM':'Chemical Data', 
            'CLI':'Climatological Information', 
            'COAPS':'South China Sea MM5/POM Predictions',
            'COAST':'Coastal Data', 
            'COVID19':'Coronavirus disease 2019 (COVID-19) Data', 
            'EMIS':'Emissions Data', 
            'ENERGY':'Energy Related Data', 
            'GIS':'GIS Data', 
            'GLPRECIP':'Global Precipitation Data', 
            'GRMC':'Guangdong Meteorology Information', 
            'HKO':'HK Observatory Data', 
            'LDM':'Internet Data Distribution (LDM) Data',
            'NCAR':'NCAR Data', 
            'NCEP':'NCEP Data', 
            'NMODEL':'Numerical Model Input / Output Data', 
            'OTHER':'Other Information', 
            'RADAR':'Radar Data', 
            'RS':'Satellite Data'} 
columns = ['Name', 'Catagory', 'Readme', 'GUI', 'Source', 'DataLocation', 
           'AvailFrom', 'AvailTo', 'InProg', 'TOutWarning', 
           'TOutError', 'MailTo', 'AllowUsers', 'AllowHosts']
src_dir='/home/dataop/index/data/'
out_file='/home/lzhenn/array74/data/envf_db/db.csv'
   # Open the text file
with open(out_file, 'w', newline='') as fo:
    writer = csv.DictWriter(fo, fieldnames=columns)
    writer.writeheader()
    data = {}
    for key1, val in catagories.items():
        cat =f'{key1} ({val})'
        data['Catagory']=cat
        loop_dir=os.path.join(src_dir,key1)
        # Loop over the text files in the directory
        for filename in os.listdir(loop_dir):
            with open(os.path.join(loop_dir,filename), 'r') as fi:
                # Initialize a dictionary to store the data
                # Loop over the lines in the file
                for line in fi:
                    # Skip empty lines and comment lines
                    if not line.strip() or line.startswith('#'):
                        continue
                    # Split the line into key and value
                    try:
                        key2, value = line.strip().split(':', 1)
                    except ValueError:
                        value=''
                    # Store the value in the dictionary
                    if key2 in columns:
                        data[key2] = value.strip()
                    else:
                        print(key2)
                        continue
            # Write the data to a CSV file
            writer.writerow(data)
