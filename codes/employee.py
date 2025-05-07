# Import required libraries
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix

# Load the dataset
df = pd.read_csv("3.csv")

# -----------------------------
# Data Preprocessing
# -----------------------------

# Convert Attrition to binary
df['Attrition'] = df['Attrition'].map({'Yes': 1, 'No': 0})

# Encode categorical features
label_encoder = LabelEncoder()
categorical_cols = df.select_dtypes(include='object').columns
if 'EmployeeNumber' in categorical_cols:
    categorical_cols = categorical_cols.drop('EmployeeNumber')

for col in categorical_cols:
    df[col] = label_encoder.fit_transform(df[col])

# Drop columns that are constant or identifiers
drop_cols = ['EmployeeNumber', 'Over18', 'StandardHours', 'EmployeeCount']
df.drop(columns=[col for col in drop_cols if col in df.columns], inplace=True)

# Fill missing values if any
df.fillna(df.mean(numeric_only=True), inplace=True)

# -----------------------------
# Attrition Rate Calculations
# -----------------------------

print("\nAttrition Rate by Job Role:")
job_attrition = df.groupby('JobRole')['Attrition'].mean().sort_values(ascending=False)
print(job_attrition)

print("\nAttrition Rate by Department:")
dept_attrition = df.groupby('Department')['Attrition'].mean().sort_values(ascending=False)
print(dept_attrition)

print("\nAttrition Rate by Years at Company:")
years_attrition = df.groupby('YearsAtCompany')['Attrition'].mean()
print(years_attrition)

# Visualization
plt.figure(figsize=(14, 4))

plt.subplot(1, 3, 1)
sns.barplot(x=job_attrition.index, y=job_attrition.values)
plt.xticks(rotation=90)
plt.title("Attrition by Job Role")

plt.subplot(1, 3, 2)
sns.barplot(x=dept_attrition.index, y=dept_attrition.values)
plt.title("Attrition by Department")

plt.subplot(1, 3, 3)
sns.lineplot(x=years_attrition.index, y=years_attrition.values)
plt.title("Attrition by Years at Company")

plt.tight_layout()
plt.show()

# -----------------------------
# Feature and Target Setup
# -----------------------------

X = df.drop('Attrition', axis=1)
y = df['Attrition']

# Split into training and test sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

# Standardize features for Logistic Regression
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# -----------------------------
# Logistic Regression Model
# -----------------------------

logreg = LogisticRegression(max_iter=1000)
param_grid_logreg = {
    'C': [0.01, 0.1, 1, 10],
    'penalty': ['l2'],
    'solver': ['lbfgs', 'liblinear']
}
grid_logreg = GridSearchCV(logreg, param_grid_logreg, cv=5, scoring='accuracy')
grid_logreg.fit(X_train_scaled, y_train)

print("\nBest Logistic Regression Parameters:", grid_logreg.best_params_)
y_pred_logreg = grid_logreg.predict(X_test_scaled)

print("\nLogistic Regression Accuracy:", accuracy_score(y_test, y_pred_logreg))
print("Classification Report (Logistic Regression):\n", classification_report(y_test, y_pred_logreg))

# Confusion Matrix - Logistic Regression
sns.heatmap(confusion_matrix(y_test, y_pred_logreg), annot=True, fmt='d', cmap='Blues')
plt.title("Confusion Matrix - Logistic Regression")
plt.xlabel("Predicted")
plt.ylabel("Actual")
plt.show()

# -----------------------------
# Random Forest Model
# -----------------------------

rf = RandomForestClassifier(random_state=42)
param_grid_rf = {
    'n_estimators': [100, 200],
    'max_depth': [10, 20, None],
    'min_samples_split': [2, 5],
    'min_samples_leaf': [1, 2]
}
grid_rf = GridSearchCV(rf, param_grid_rf, cv=5, scoring='accuracy', n_jobs=-1)
grid_rf.fit(X_train, y_train)

print("\nBest Random Forest Parameters:", grid_rf.best_params_)
y_pred_rf = grid_rf.predict(X_test)

print("\nRandom Forest Accuracy:", accuracy_score(y_test, y_pred_rf))
print("Classification Report (Random Forest):\n", classification_report(y_test, y_pred_rf))

# Confusion Matrix - Random Forest
sns.heatmap(confusion_matrix(y_test, y_pred_rf), annot=True, fmt='d', cmap='Greens')
plt.title("Confusion Matrix - Random Forest")
plt.xlabel("Predicted")
plt.ylabel("Actual")
plt.show()

# -----------------------------
# Feature Importance
# -----------------------------

importances = pd.Series(grid_rf.best_estimator_.feature_importances_, index=X.columns)
importances = importances.sort_values(ascending=False)

plt.figure(figsize=(10, 6))
sns.barplot(x=importances.values, y=importances.index)
plt.title("Feature Importance - Random Forest")
plt.xlabel("Importance")
plt.ylabel("Feature")
plt.tight_layout()
plt.show()
