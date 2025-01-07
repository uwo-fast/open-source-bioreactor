import os
import pandas as pd

# Get the directory of the currently running script
script_dir = os.path.dirname(os.path.abspath(__file__))

# Define the input and output file paths relative to the script's directory
input_file = os.path.join(
    script_dir, "spectroscopy_data.csv"
)  # Going up two levels
output_file = os.path.join(script_dir, "spectroscopy_data_cleaned1.csv")

# Check if the file exists
if not os.path.exists(input_file):
    raise FileNotFoundError(f"The file {input_file} does not exist.")

# Load the CSV file, skipping the first row that describes the conditions
data = pd.read_csv(input_file, header=1)

# Iterate over each column and replace negative values with NaN (which will show as blank in the output)
for col in data.columns:
    if "Absolute Irradiance" in col:  # Check if the column contains irradiance data
        data[col] = data[col].apply(lambda x: None if x < 0 else x)

# Save the cleaned data to a new file
data.to_csv(output_file, index=False)

print(f"Cleaned data has been saved to {output_file}")
