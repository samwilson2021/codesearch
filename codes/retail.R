# Load required libraries
library(tidyverse)
library(lubridate)
library(forecast)
library(ggplot2)
library(Metrics)
library(patchwork)

# Step 1: Load data
data <- read_csv("D:/AST LAB/9/9.csv")

# Step 2: Parse and clean Order Date
data <- data %>% 
  mutate(`Order Date` = suppressWarnings(dmy(`Order Date`))) %>% 
  filter(!is.na(`Order Date`))

# Step 3: Aggregate monthly sales
monthly_sales <- data %>% 
  mutate(Month = floor_date(`Order Date`, "month")) %>% 
  group_by(Month) %>% 
  summarise(Monthly_Sales = sum(Sales, na.rm = TRUE)) %>% 
  arrange(Month)

# Step 4: Visualize sales trend (Line plot)
sales_trend_plot <- ggplot(monthly_sales, aes(x = Month, y = Monthly_Sales)) +
  geom_line(color = "darkgreen", linewidth = 1) +
  labs(title = "Monthly Retail Sales Trend",
       x = "Month", y = "Sales") +
  theme_minimal()
print(sales_trend_plot)

# Step 5: Visualize seasonality (Sales across months of different years)
seasonality_plot <- monthly_sales %>%
  mutate(Year = year(Month), Month = factor(month(Month), labels = month.name)) %>%
  ggplot(aes(x = Month, y = Monthly_Sales, group = Year, color = factor(Year))) +
  geom_line(linewidth = 1) +
  labs(title = "Seasonal Sales Patterns by Year",
       x = "Month", y = "Sales", color = "Year") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_color_viridis_d()
print(seasonality_plot)

# Step 6: Convert to time series object
start_year <- year(min(monthly_sales$Month))
start_month <- month(min(monthly_sales$Month))
sales_ts <- ts(monthly_sales$Monthly_Sales,
               start = c(start_year, start_month),
               frequency = 12)

# Step 7: Decompose time series (Additive decomposition)
decomposed <- decompose(sales_ts)

# Step 8: Plot decomposition of the time series
trend_plot <- autoplot(decomposed$trend) +
  labs(title = "Trend Component of Sales", x = "Time", y = "Sales Trend") +
  theme_minimal()
print(trend_plot)

seasonal_component_plot <- autoplot(decomposed$seasonal) +
  labs(title = "Seasonal Component of Sales", x = "Time", y = "Sales Seasonality") +
  theme_minimal()
print(seasonal_component_plot)

residual_plot <- autoplot(decomposed$random) +
  labs(title = "Residual (Noise) Component of Sales", x = "Time", y = "Sales Noise") +
  theme_minimal()
print(residual_plot)

# Step 9: Seasonal plot with forecast package
seasonal_plot_full <- ggseasonplot(sales_ts, year.labels = TRUE, continuous = TRUE) +
  labs(title = "Seasonal Sales Pattern", x = "Month", y = "Sales") +
  theme_minimal()
print(seasonal_plot_full)

# Step 10: Forecasting with ARIMA
fit_arima <- auto.arima(sales_ts)
fc_arima <- forecast(fit_arima, h = 12)

# Step 11: Forecasting with ETS
fit_ets <- ets(sales_ts)
fc_ets <- forecast(fit_ets, h = 12)

# Step 12: Plot forecasts
arima_forecast_plot <- autoplot(fc_arima) +
  labs(title = "ARIMA Forecast", x = "Time", y = "Sales") +
  theme_minimal()
print(arima_forecast_plot)

ets_forecast_plot <- autoplot(fc_ets) +
  labs(title = "ETS Forecast", x = "Time", y = "Sales") +
  theme_minimal()
print(ets_forecast_plot)

# Step 13: Model Evaluation (Train/Test Split)
n <- length(sales_ts)
train_ts <- window(sales_ts, end = c(time(sales_ts)[n - 12]))
test_ts <- window(sales_ts, start = c(time(sales_ts)[n - 11]))

# Fit models on training set
fit_arima_train <- auto.arima(train_ts)
fc_arima_test <- forecast(fit_arima_train, h = 12)

fit_ets_train <- ets(train_ts)
fc_ets_test <- forecast(fit_ets_train, h = 12)

# Calculate RMSE
rmse_arima <- rmse(test_ts, fc_arima_test$mean)
rmse_ets <- rmse(test_ts, fc_ets_test$mean)

cat("✅ RMSE (ARIMA):", round(rmse_arima, 2), "\n")
cat("✅ RMSE (ETS):", round(rmse_ets, 2), "\n")

# Step 14: Compare actual vs forecasted
comparison_plot <- autoplot(test_ts, series = "Actual") +
  autolayer(fc_arima_test$mean, series = "ARIMA Forecast", linetype = "dashed") +
  autolayer(fc_ets_test$mean, series = "ETS Forecast", linetype = "dotted") +
  labs(title = "Actual vs Forecasted Sales",
       y = "Sales", x = "Time") +
  theme_minimal() +
  guides(colour = guide_legend(title = "Forecast Method"))
print(comparison_plot)
