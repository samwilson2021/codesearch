import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load dataset
df = pd.read_excel('5.xlsx')

# Display first few rows
print("Initial Data Snapshot:")
print(df.head())

# Check for missing values
print("\nMissing values:\n", df.isnull().sum())

# Drop missing values
df.dropna(inplace=True)

# Combine Date and Time columns into a single datetime column
df['Datetime'] = pd.to_datetime(df['Date'].astype(str) + ' ' + df['Time'].astype(str))
df.set_index('Datetime', inplace=True)
df.drop(columns=['Date', 'Time'], inplace=True)

# ---- Detect extreme pollution events using CO(GT) ----
threshold = df['CO(GT)'].quantile(0.95)
extreme_events = df[df['CO(GT)'] >= threshold]
print(f"\nTop 5% Extreme CO(GT) Days (CO ≥ {threshold:.2f}):")
print(extreme_events[['CO(GT)']])

# ---- Monthly average pollutant trends ----
monthly_avg = df.resample('M').mean(numeric_only=True)

plt.figure(figsize=(12, 6))
for col in ['CO(GT)', 'NOx(GT)', 'NO2(GT)', 'C6H6(GT)']:
    if col in df.columns:
        monthly_avg[col].plot(label=col)

plt.title('Monthly Average Pollutant Levels')
plt.xlabel('Month')
plt.ylabel('Concentration')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()

# ---- Seasonal variation in CO(GT) ----
df['Month'] = df.index.month
df['Season'] = df['Month'].apply(lambda x: (
    'Winter' if x in [12, 1, 2] else
    'Spring' if x in [3, 4, 5] else
    'Summer' if x in [6, 7, 8] else
    'Autumn'))

plt.figure(figsize=(8, 5))
sns.boxplot(x='Season', y='CO(GT)', data=df)
plt.title('Seasonal Variation in CO(GT)')
plt.ylabel('CO(GT)')
plt.grid(True)
plt.tight_layout()
plt.show()

# ---- Correlation between pollutants and meteorological data ----
pollutants = ['CO(GT)', 'NOx(GT)', 'NO2(GT)', 'C6H6(GT)']
meteorological = ['T', 'RH', 'AH']

available_columns = df.columns.tolist()
available_pollutants = [col for col in pollutants if col in available_columns]
available_meteo = [col for col in meteorological if col in available_columns]

if available_pollutants and available_meteo:
    corr_matrix = df[available_pollutants + available_meteo].corr()

    print("\nCorrelation Matrix:\n", corr_matrix)

    plt.figure(figsize=(10, 6))
    sns.heatmap(corr_matrix, annot=True, cmap='coolwarm', fmt='.2f')
    plt.title('Correlation Between Pollutants and Meteorological Variables')
    plt.tight_layout()
    plt.show()
else:
    print("\nRequired columns for correlation analysis are missing.")
