import pandas as pd
import matplotlib.pyplot as plt
import os

# Define the min and max wavelength for the plot
min_wavelength = 300  # Set the minimum wavelength (nm)
max_wavelength = 800  # Set the maximum wavelength (nm)

# Define the y-axis limits for Absolute Irradiance
y_min = 0  # Minimum y-value
y_max = 140  # Maximum y-value

# Get the directory of the current script
script_dir = os.path.dirname(os.path.abspath(__file__))

# Define the file paths and trials to plot for each spreadsheet
datasets = [
    {"file": "spectroscopy_data_led1cm.csv", "trial": 1},
    {"file": "spectroscopy_data_flor1cm.csv", "trial": 2},
    {"file": "spectroscopy_data_flor90uWpeak.csv", "trial": 3},
]

# Define the color map for each dataset
colors = ["blue", "green", "red"]

# Create the plot
plt.figure(figsize=(10, 6))

for i, dataset in enumerate(datasets):
    csv_path = os.path.join(script_dir, dataset["file"])
    trial = dataset["trial"]

    # Check if the file exists
    if not os.path.isfile(csv_path):
        print(f"CSV file not found: {csv_path}")
        continue

    # Read the CSV file into a DataFrame
    df = pd.read_csv(csv_path)

    # Extract the part after 'data_' in the CSV file name for labeling
    csv_name = os.path.basename(csv_path)
    label_name = csv_name.split("data_")[1].split(".")[0]

    # Columns for the selected trial
    col_wavelength = f"Wavelength {trial}"
    col_irradiance = f"Absolute Irradiance {trial}"

    # Replace negative values with NaN and interpolate
    df[col_irradiance] = df[col_irradiance].apply(lambda x: None if x < 0 else x)
    df[col_irradiance] = df[col_irradiance].interpolate()

    # Filter the data based on the wavelength range
    mask = (df[col_wavelength] >= min_wavelength) & (
        df[col_wavelength] <= max_wavelength
    )
    trial_wavelength = df[col_wavelength][mask]
    trial_irradiance = df[col_irradiance][mask]

    # Plot the trial data
    plt.plot(
        trial_wavelength,
        trial_irradiance,
        color=colors[i],
        label=f"{label_name} - Trial {trial}",
    )

# Customize the plot
plt.title("Absolute Irradiance vs Wavelength for Multiple Spreadsheets")
plt.xlabel("Wavelength (nm)")
plt.ylabel("Absolute Irradiance")
plt.grid(True)
plt.legend()

# Set the y-axis limits
plt.ylim(y_min, y_max)

# Output directory and file name
output_file = os.path.join(script_dir, "combined_irradiance_plot.png")

# Save the plot as a PNG file
plt.savefig(output_file)

# Display the plot (optional)
plt.show()

print(f"Plot saved to {output_file}")
