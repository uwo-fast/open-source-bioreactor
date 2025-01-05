# plot_actuators.py
import pandas as pd
import matplotlib.pyplot as plt
import os

# Path to the CSV file
csv_path = os.path.join(os.path.dirname(__file__), "microalgae_Nov19th2pm_cleaned2.csv")

# Load the CSV file into a pandas DataFrame
df = pd.read_csv(csv_path)

# Convert Unix timestamp to datetime
df["time"] = pd.to_datetime(df["time"], unit="s")

# Second figure for stirring motor and sample pump
fig2, ax2 = plt.subplots(figsize=(15, 8))

# Plot Stirring Motor as a step plot
ax2.step(
    df["time"],
    df["stirring motor"].astype(int),
    label="Stirring Motor",
    color="tab:orange",
    where="post",
)

# Plot Sample Pump as a step plot
ax2.step(
    df["time"],
    df["sample pump"].astype(int),
    label="Sample Pump",
    color="tab:purple",
    where="post",
)

# Set titles and labels for second figure
ax2.set_title("Stirring Motor and Sample Pump")
ax2.set_xlabel("Time")
ax2.set_ylabel("On (1) / Off (0)")
ax2.legend()
ax2.grid(True)

# Save the figure as a PNG file
output_file = os.path.join(os.path.dirname(__file__), "plot_actuator.png")
plt.savefig(output_file)

# Show the plot
plt.show()

print(f"Actuator plot saved as: {output_file}")
