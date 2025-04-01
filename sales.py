import pandas as pd

# Load the Excel file
file_path = "cafe123.xlsx"  # Change to your file name
xls = pd.ExcelFile(file_path)

# Read all sheets and combine them
df_list = [xls.parse(sheet) for sheet in xls.sheet_names]
merged_df = pd.concat(df_list, ignore_index=True)

# Save as CSV
merged_df.to_csv("merged_file.csv", index=False)
