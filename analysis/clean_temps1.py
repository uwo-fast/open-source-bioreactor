import pandas as pd
import os

# Path to the CSV file
csv_path = os.path.join(os.path.dirname(__file__), "microalgae_Nov19th2pm_cleaned0.csv")

# Load the CSV file into a pandas DataFrame
df = pd.read_csv(csv_path)

# Filter out rows where the temperature is below 20°C or above 45°C since these are considered to be outliers
# Safe to assume since there was no active heating or cooling system and the reactor was in a controlled environment
df_cleaned = df[(df["temperature"] >= 20) & (df["temperature"] <= 45)]

# Save the cleaned DataFrame to a new CSV file
output_filename = os.path.join(
    os.path.dirname(__file__), "microalgae_Nov19th2pm_cleaned1.csv"
)
df_cleaned.to_csv(output_filename, index=False)

print(f"Cleaned CSV saved as: {output_filename}")
