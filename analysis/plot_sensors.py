# plot_sensors.py
import pandas as pd
import matplotlib.pyplot as plt
import os

# Path to the CSV file
csv_path = os.path.join(os.path.dirname(__file__), "microalgae_Nov19th2pm_cleaned2.csv")

# Load the CSV file into a pandas DataFrame
df = pd.read_csv(csv_path)

# Convert Unix timestamp to datetime
df["time"] = pd.to_datetime(df["time"], unit="s")

# Control variables for rolling averages (window size)
temp_window = 30  # Window size for temperature
do_window = 5  # Window size for dissolved oxygen
ph_window = 5  # Window size for pH

# Apply rolling average filter to temperature, dissolved oxygen, and pH
df["temp_rolling"] = df["temperature"].rolling(window=temp_window, min_periods=1).mean()
df["do_rolling"] = (
    df["dissolved oxygen"].rolling(window=do_window, min_periods=1).mean()
)
df["ph_rolling"] = df["pH"].rolling(window=ph_window, min_periods=1).mean()

# First figure for temperature, dissolved oxygen, and pH with separate axes
fig, (ax1, ax2, ax3) = plt.subplots(3, 1, figsize=(15, 12), sharex=True)

# Plot Temperature
ax1.plot(df["time"], df["temp_rolling"], label="Temperature (°C)", color="tab:red")
ax1.set_title("Temperature")
ax1.set_ylabel("°C")
# ax1.set_ylim(20, 40)  # Set y-axis limits for temperature
ax1.legend()
ax1.grid(True)

# Plot Dissolved Oxygen
ax2.plot(df["time"], df["do_rolling"], label="Dissolved Oxygen (%)", color="tab:blue")
ax2.set_title("Dissolved Oxygen")
ax2.set_ylabel("%")
# ax2.set_ylim(0, 80)  # Set y-axis limits for dissolved oxygen
ax2.legend()
ax2.grid(True)

# Plot pH
ax3.plot(df["time"], df["ph_rolling"], label="pH", color="tab:green")
ax3.set_title("pH")
ax3.set_xlabel("Time")
ax3.set_ylabel("pH")
# ax3.set_ylim(6.5, 8.5)  # Set y-axis limits for pH
ax3.legend()
ax3.grid(True)

# Adjust layout for better spacing
plt.tight_layout()

# Save the figure as a PNG file
output_file = os.path.join(os.path.dirname(__file__), "plot_sensor.png")
plt.savefig(output_file)

# Show the plot
plt.show()

print(f"Sensor plot saved as: {output_file}")
