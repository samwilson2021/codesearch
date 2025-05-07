import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Load dataset
df = pd.read_csv("1.csv")

# Clean column names
df.columns = [col.strip().lower().replace(" ", "_") for col in df.columns]

# Check and drop missing values
df = df.dropna()

# ========== 1. AVERAGE SCORES GROUPED BY DEMOGRAPHICS ==========

# Grouped by race/ethnicity
avg_by_ethnicity = df.groupby("race/ethnicity")[["math_score", "reading_score", "writing_score"]].mean()

# Grouped by gender
avg_by_gender = df.groupby("gender")[["math_score", "reading_score", "writing_score"]].mean()

# Grouped by lunch
avg_by_lunch = df.groupby("lunch")[["math_score", "reading_score", "writing_score"]].mean()

# ========== 2. VISUALIZATIONS ==========

# ----- Bar chart: Average scores by ethnic group -----
plt.figure(figsize=(10, 6))
avg_by_ethnicity.plot(kind='bar')
plt.title("Average Scores by Ethnic Group")
plt.ylabel("Average Score")
plt.xlabel("Ethnic Group")
plt.xticks(rotation=45)
plt.grid(axis='y')
plt.tight_layout()
plt.show()

# ----- Pie chart: Gender distribution -----
gender_counts = df['gender'].value_counts()
plt.figure(figsize=(6, 6))
plt.pie(gender_counts, labels=gender_counts.index, autopct='%1.1f%%', startangle=140)
plt.title("Gender Distribution")
plt.axis('equal')
plt.show()

# ----- Bar chart: Average scores by gender -----
avg_by_gender.plot(kind='bar', color=['skyblue', 'salmon', 'limegreen'])
plt.title("Average Scores by Gender")
plt.ylabel("Average Score")
plt.xticks(rotation=0)
plt.grid(axis='y')
plt.tight_layout()
plt.show()

# ----- Bar chart: Average scores by lunch type -----
avg_by_lunch.plot(kind='bar', color=['gold', 'purple', 'teal'])
plt.title("Average Scores by Lunch Type")
plt.ylabel("Average Score")
plt.xticks(rotation=0)
plt.grid(axis='y')
plt.tight_layout()
plt.show()

# ========== 3. TOP 10% STUDENTS BASED ON OVERALL PERFORMANCE ==========

# Add a total score column
df["total_score"] = df["math_score"] + df["reading_score"] + df["writing_score"]

# Calculate 90th percentile threshold
threshold = df["total_score"].quantile(0.9)

# Filter top 10% students
top_10_percent = df[df["total_score"] >= threshold]

# Mean scores for top 10% students
top_scores = top_10_percent[["math_score", "reading_score", "writing_score"]].mean()

# ----- Bar chart: Subject-wise strengths of top students -----
plt.figure(figsize=(8, 6))
top_scores.plot(kind='bar', color=['skyblue', 'lightcoral', 'lightgreen'])
plt.title("Top 10% Students - Average Subject Scores")
plt.ylabel("Average Score")
plt.xticks(rotation=0)
plt.grid(axis='y')
plt.tight_layout()
plt.show()

# ========== 4. SAVE RESULTS ==========

# Export grouped averages and top students to CSV
avg_by_ethnicity.to_csv("average_by_ethnicity.csv")
avg_by_gender.to_csv("average_by_gender.csv")
avg_by_lunch.to_csv("average_by_lunch.csv")
top_10_percent.to_csv("top_10_percent_students.csv", index=False)
