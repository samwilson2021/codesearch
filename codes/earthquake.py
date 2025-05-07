import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import geopandas as gpd
from sklearn.preprocessing import LabelEncoder

# Load dataset
df = pd.read_csv("2.csv")
df.columns = df.columns.str.strip()  # Clean column names

# Initial preview
print(df.head())
print("\nMissing values:\n", df.isnull().sum())

# Handle missing data more carefully
# Drop only if critical fields are missing (mag, latitude, longitude, depth)
df = df.dropna(subset=['mag', 'latitude', 'longitude', 'depth'])

# Fill less critical missing data
df['place'] = df['place'].fillna('Unknown')
df['Time'] = pd.to_datetime(df['time'], errors='coerce')
df['Time'] = df['Time'].dt.hour.fillna(0)

# Create time of day category
df['TimeOfDay'] = pd.cut(df['Time'], bins=[0, 6, 12, 18, 24], labels=['Night', 'Morning', 'Afternoon', 'Evening'], right=False)

# Encode categorical variables
le = LabelEncoder()
df['Location_encoded'] = le.fit_transform(df['place'])
df['TimeOfDay_encoded'] = le.fit_transform(df['TimeOfDay'].astype(str))

# Final check
if df.empty:
    raise ValueError("Dataset is empty after preprocessing!")

# ========== VISUALIZATION ==========

plt.figure(figsize=(8, 6))
sns.histplot(df['mag'], kde=True, color='blue')
plt.title("Distribution of Earthquake Magnitudes")
plt.xlabel("Magnitude")
plt.ylabel("Frequency")
plt.show()

# Spatial plot with geopandas
try:
    gdf = gpd.GeoDataFrame(df, geometry=gpd.points_from_xy(df['longitude'], df['latitude']))
    gdf.plot(marker='o', color='red', markersize=5, figsize=(10, 6))
    plt.title("Spatial Distribution of Earthquakes")
    plt.xlabel("Longitude")
    plt.ylabel("Latitude")
    plt.show()
except Exception as e:
    print("Geo plot error:", e)

# Heatmap
plt.figure(figsize=(10, 6))
corr = df[['mag', 'depth', 'latitude', 'longitude', 'Time', 'Location_encoded', 'TimeOfDay_encoded']].corr()
sns.heatmap(corr, annot=True, cmap='coolwarm', fmt=".2f")
plt.title("Correlation Heatmap")
plt.show()

# ========== MODELING ==========

X = df[['depth', 'latitude', 'longitude', 'Location_encoded', 'TimeOfDay_encoded']]
y = df['mag']

if len(df) < 2:
    raise ValueError("Not enough data to train/test a model!")

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Linear Regression
linear_model = LinearRegression()
linear_model.fit(X_train, y_train)
y_pred_linear = linear_model.predict(X_test)

# Random Forest
rf_model = RandomForestRegressor(n_estimators=100, random_state=42)
rf_model.fit(X_train, y_train)
y_pred_rf = rf_model.predict(X_test)

# ========== EVALUATION ==========

print("\nLinear Regression Evaluation:")
print(f"MAE: {mean_absolute_error(y_test, y_pred_linear):.4f}")
print(f"MSE: {mean_squared_error(y_test, y_pred_linear):.4f}")
print(f"R2:  {r2_score(y_test, y_pred_linear):.4f}")

print("\nRandom Forest Evaluation:")
print(f"MAE: {mean_absolute_error(y_test, y_pred_rf):.4f}")
print(f"MSE: {mean_squared_error(y_test, y_pred_rf):.4f}")
print(f"R2:  {r2_score(y_test, y_pred_rf):.4f}")

# ========== FEATURE IMPORTANCE ==========

plt.figure(figsize=(10, 6))
plt.barh(X.columns, rf_model.feature_importances_, color='teal')
plt.title("Feature Importance (Random Forest)")
plt.xlabel("Importance")
plt.ylabel("Features")
plt.show()

# ========== SCATTER PLOTS ==========

plt.figure(figsize=(8, 6))
plt.scatter(y_test, y_pred_linear, color='blue')
plt.title("Linear Regression: Predicted vs Actual")
plt.xlabel("Actual Magnitude")
plt.ylabel("Predicted Magnitude")
plt.show()

plt.figure(figsize=(8, 6))
plt.scatter(y_test, y_pred_rf, color='green')
plt.title("Random Forest: Predicted vs Actual")
plt.xlabel("Actual Magnitude")
plt.ylabel("Predicted Magnitude")
plt.show()
