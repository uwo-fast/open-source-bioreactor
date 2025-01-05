import pandas as pd
import os

# Path to the input CSV file
csv_path = os.path.join(os.path.dirname(__file__), "microalgae_Nov19th2pm_cleaned1.csv")

# Load the CSV file into a pandas DataFrame
df = pd.read_csv(csv_path)

# Filter out rows where pH < 7 since this is erroneous data from the sensor settling
df_cleaned = df[df["pH"] >= 7]

# Path to the output CSV file
output_filename = os.path.join(
    os.path.dirname(__file__), "microalgae_Nov19th2pm_cleaned2.csv"
)

# Save the cleaned DataFrame to a new CSV file
df_cleaned.to_csv(output_filename, index=False)

print(f"Cleaned CSV saved as: {output_filename}")
