import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load dataset
df = pd.read_csv("4.csv", encoding='ISO-8859-1')

# -----------------------------
# Data Cleaning
# -----------------------------

# Drop rows with missing CustomerID or InvoiceNo
df.dropna(subset=['CustomerID', 'InvoiceNo'], inplace=True)

# Remove negative or zero quantity and price (likely returns or errors)
df = df[(df['Quantity'] > 0) & (df['UnitPrice'] > 0)]

# Remove duplicates
df.drop_duplicates(inplace=True)

# Calculate Total Price
df['TotalPrice'] = df['Quantity'] * df['UnitPrice']

# Convert InvoiceDate to datetime
df['InvoiceDate'] = pd.to_datetime(df['InvoiceDate'])

# Convert GBP to USD (assume a rate for analysis)
GBP_to_USD = 1.3
df['TotalPriceUSD'] = df['TotalPrice'] * GBP_to_USD

# -----------------------------
# Analyze Country-Level Spending
# -----------------------------

country_spending = df.groupby('Country')['TotalPriceUSD'].sum().sort_values(ascending=False)
country_avg_spending = df.groupby('Country')['TotalPriceUSD'].mean().sort_values(ascending=False)

print("\nTop 10 Countries by Total Spending:")
print(country_spending.head(10).apply(lambda x: f"${x:,.2f}"))

print("\nTop 10 Countries by Average Order Spending:")
print(country_avg_spending.head(10).apply(lambda x: f"${x:,.2f}"))

# -----------------------------
# Identify Top 5% High-Value Customers
# -----------------------------

customer_spending = df.groupby('CustomerID')['TotalPriceUSD'].sum()
threshold = customer_spending.quantile(0.95)
top_customers = customer_spending[customer_spending >= threshold]

print(f"\nTop 5% High-Value Customers (Threshold: ${threshold:.2f}):")
print(top_customers.sort_values(ascending=False).head().apply(lambda x: f"${x:,.2f}"))

# Analyze their purchase behavior
df_top = df[df['CustomerID'].isin(top_customers.index)]
top_customer_countries = df_top['Country'].value_counts()
top_customer_products = df_top['Description'].value_counts().head(10)

print("\nTop Countries Among Top 5% Customers:")
print(top_customer_countries)

print("\nTop 10 Products Bought by Top Customers:")
print(top_customer_products)

# -----------------------------
# Monthly Purchase Activity (Time Series)
# -----------------------------

df['InvoiceMonth'] = df['InvoiceDate'].dt.to_period('M')
monthly_spending = df.groupby('InvoiceMonth')['TotalPriceUSD'].sum()

# Plot time-series
plt.figure(figsize=(12, 6))
monthly_spending.plot(marker='o')
plt.title("Monthly Purchase Activity (USD)")
plt.xlabel("Month")
plt.ylabel("Total Spending (USD)")
plt.grid(True)
plt.tight_layout()
plt.show()

# -----------------------------
# Visualization: Top 10 Countries by Total Spending
# -----------------------------

plt.figure(figsize=(10, 6))
sns.barplot(
    x=country_spending.head(10).values,
    y=country_spending.head(10).index,
    hue=None,
    legend=False,
    palette="magma"
)
plt.title("Top 10 Countries by Total Customer Spending (USD)")
plt.xlabel("Total Spending (USD)")
plt.ylabel("Country")
plt.tight_layout()
plt.show()

# -----------------------------
# Visualization: Top Products by Revenue
# -----------------------------

product_revenue = df.groupby('Description')['TotalPriceUSD'].sum().sort_values(ascending=False).head(10)

plt.figure(figsize=(10, 6))
sns.barplot(
    x=product_revenue.values,
    y=product_revenue.index,
    hue=None,
    legend=False,
    palette="viridis"
)
plt.title("Top 10 Products by Revenue (USD)")
plt.xlabel("Total Revenue (USD)")
plt.ylabel("Product Description")
plt.tight_layout()
plt.show()
