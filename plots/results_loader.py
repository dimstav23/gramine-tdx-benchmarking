import os
import pandas as pd
import numpy as np

variants_label_map = {
  "native"                :   "Native",
  "socat-native"          :   "Native w/ socat",
  "efi"                   :   "Normal VM",
  "td"                    :   "Intel TDX VM",
  "bm-gramine-sgx"        :   "Gramine-SGX",
  "gramine-tdx"           :   "Gramine-TDX",
  "gramine-vm"            :   "Gramine-VM",
  "socat-efi"             :   "Normal VM w/ socat",
  "socat-td"              :   "Intel TDX VM w/ socat"
}

class ResultsLoader:
  def __init__(self, directories):
    self.directories = directories

  def filter_data(self, data, experiments_filter):
    filtered_data = {k: v for k, v in data.items() if k in experiments_filter}
    return filtered_data

  def load_data(self, experiments_filter):
    data = {}
    directories = self.directories.split(":")

    for directory in directories:
      files = [f for f in os.listdir(directory) if f.endswith('.csv')]

      for file in sorted(files):
        filepath = os.path.join(directory, file)
        filename_parts = file.split('_')

        # Extract the experiment name (if applicable)
        if len(filename_parts) == 2:
          experiment, variant = filename_parts
        else:
          experiment, variant = "default", filename_parts[0]

        # Keep only the variant name
        variant = variant.split('.csv')[0]
        # Replace variant with its label
        if variant in variants_label_map.keys():
          variant = variants_label_map[variant]

        # Read csv file into dataframe
        df = pd.read_csv(filepath, header=None)
        # Transpose df to have threads as index and the values as columns
        df = df.transpose()
        # Set the thread values as indexes
        df.set_index(df.columns[0], inplace=True)
        # Set the first row as column names (Threads, Metric)
        df.columns = df.iloc[0]
        # Remove the first row
        df = df[1:]
        # Convert the thread values to integers
        df.index = df.index.astype(int)

        if experiment not in data:
          data[experiment] = {}
        if variant not in data[experiment]:
          data[experiment][variant] = {}
        data[experiment][variant][directory] = df

    for experiment in experiments_filter:
      if experiment not in data:
        print(f"Error: Experiment {experiment} does not exist in {self.directories}")
        exit()

    # get the avg and std error for the accummulated results
    data_avg = {}
    data_std = {}
    for experiment in data.keys():
      if experiment not in data_avg:
        data_avg[experiment] = {}
      if experiment not in data_std:
        data_std[experiment] = {}
      for variant in data[experiment].keys():
        # temp_data gathers the results of each run
        temp_data = []
        for directory in data[experiment][variant].keys():
          temp_data.append(data[experiment][variant][directory].iloc[:].to_numpy().flatten())

        # convert the list to NumPy array for easier calculation
        temp_data = np.array(temp_data)
        # ensure that all the elements are of numeric type (float)
        temp_data = temp_data.astype(float)
        # get the mean
        mean_data = np.mean(temp_data, axis=0)
        # get the std error and replace the NaN with 0s if we have only 1 run
        std_data = np.nan_to_num(np.std(temp_data, axis=0, ddof=1)/np.sqrt(len(temp_data)))

        # Copy the structure of the df for the mean data dictionary
        data_avg[experiment][variant] = data[experiment][variant][directory].copy(deep=True)
        # Zero out the mean data dictionary
        data_avg[experiment][variant].iloc[0:0]
        # Set the values of the mean data dictionary
        for idx, mean_val in enumerate(mean_data):
          data_avg[experiment][variant].iloc[idx] = mean_val

        # Copy the structure of the df for the standard error data dictionary
        data_std[experiment][variant] = data[experiment][variant][directory].copy(deep=True)
        # Zero out the standard error data dictionary
        data_std[experiment][variant].iloc[0:0]
        # Set the values of the standard error data dictionary
        for idx, std_val in enumerate(std_data):
          data_std[experiment][variant].iloc[idx] = std_val
    
    data_avg = self.filter_data(data_avg, experiments_filter)
    data_std = self.filter_data(data_std, experiments_filter)
    return (data_avg, data_std)