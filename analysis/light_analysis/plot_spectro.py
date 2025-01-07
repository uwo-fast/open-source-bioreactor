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

# Define the trials to plot (e.g., [1, 2, 3])
trials = [1]

# Define the path to the CSV file
# csv_path = os.path.join(script_dir, "spectroscopy_data_led1cm.csv")
# csv_path = os.path.join(script_dir, "spectroscopy_data_flor1cm.csv")
csv_path = os.path.join(script_dir, "spectroscopy_data_flor90uWpeak.csv")

# Extract the part after 'data_' in the CSV file name for dynamic naming of image to avoid overwriting
csv_name = os.path.basename(csv_path)  # Get the file name
output_name = csv_name.split("data_")[1].split(".")[0]  # Extract part after 'data_'

# Check if the file exists
if not os.path.isfile(csv_path):
    print(f"CSV file not found: {csv_path}")
else:
    # Read the CSV file into a DataFrame
    df = pd.read_csv(csv_path)

    # Replace negative values with NaN (assuming these were replaced by blanks previously)
    for trial in trials:
        col_wavelength = f"Wavelength {trial}"
        col_irradiance = f"Absolute Irradiance {trial}"

        # Handle NaN replacement and interpolation
        df[col_irradiance] = df[col_irradiance].apply(lambda x: None if x < 0 else x)
        df[col_irradiance] = df[col_irradiance].interpolate()

    # Define the color map for plotting
    colors = ["blue", "green", "red"]  # Adjust colors for the trials

    # Create the plot
    plt.figure(figsize=(10, 6))

    for i, trial in enumerate(trials):
        col_wavelength = f"Wavelength {trial}"
        col_irradiance = f"Absolute Irradiance {trial}"

        # Filter the data based on the wavelength range
        mask = (df[col_wavelength] >= min_wavelength) & (
            df[col_wavelength] <= max_wavelength
        )
        trial_wavelength = df[col_wavelength][mask]
        trial_irradiance = df[col_irradiance][mask]

        # Plot the trial data
        plt.plot(
            trial_wavelength, trial_irradiance, color=colors[i], label=f"Trial {trial}"
        )

    # Customize the plot
    plt.title(f"Absolute Irradiance vs Wavelength for {output_name}")
    plt.xlabel("Wavelength (nm)")
    plt.ylabel("Absolute Irradiance")
    plt.grid(True)
    plt.legend()

    # Set the y-axis limits
    plt.ylim(y_min, y_max)

    # Output directory and file name
    output_file = os.path.join(script_dir, f"irradiance_plot_{output_name}.png")

    # Save the plot as a PNG file
    plt.savefig(output_file)

    # Display the plot (optional)
    plt.show()

    print(f"Plot saved to {output_file}")
