# ----------------------------------------
# Car Price Prediction using Linear Regression
# Based on: horsepower, enginesize, highwaympg
# ----------------------------------------

# Load Required Libraries
library(dplyr)
library(ggplot2)
library(caret)
library(corrplot)

# -------------------------------
# 1. Load and Preprocess Dataset
# -------------------------------
setwd("D:/AST LAB/8")  # Change path if needed
data <- read.csv("8.csv", stringsAsFactors = TRUE)
cat("✅ Dataset Loaded.\n")

# Show structure
str(data)

# Drop rows with missing values
data <- na.omit(data)
cat("✅ Missing values removed.\n")

# Encode categorical variables (if any)
data <- data %>%
  mutate(across(where(is.factor), ~as.numeric(as.factor(.))))
cat("✅ Categorical variables encoded (if any).\n")

# Select relevant features for modeling
selected_features <- c("horsepower", "enginesize", "highwaympg", "price")
numeric_data <- data[, selected_features]

# -------------------------------
# 2. Correlation Analysis
# -------------------------------
cat("📊 Correlation Matrix:\n")
cor_matrix <- cor(numeric_data)
print(cor_matrix)

# Correlation heatmap
corrplot(cor_matrix, method = "color", tl.col = "black", number.cex = 0.7)

# Scatter plots for each feature vs Price
features <- setdiff(selected_features, "price")
for (feature in features) {
  print(
    ggplot(numeric_data, aes_string(x = feature, y = "price")) +
      geom_point(color = "steelblue") +
      geom_smooth(method = "lm", color = "darkgreen", se = FALSE) +
      ggtitle(paste(feature, "vs Price"))
  )
}

# -------------------------------
# 3. Train Linear Regression Model
# -------------------------------
# Split into train and test sets
set.seed(123)
train_index <- createDataPartition(numeric_data$price, p = 0.8, list = FALSE)
train_data <- numeric_data[train_index, ]
test_data <- numeric_data[-train_index, ]

# Train linear regression model
model_formula <- price ~ horsepower + enginesize + highwaympg
model <- train(model_formula, data = train_data, method = "lm")
cat("✅ Linear Regression Model Trained.\n")
cat("📈 Model Summary:\n")
print(summary(model$finalModel))

# -------------------------------
# 4. Model Evaluation
# -------------------------------
predictions <- predict(model, newdata = test_data)

# Compute metrics
mae <- mean(abs(predictions - test_data$price))
mse <- mean((predictions - test_data$price)^2)
r2 <- cor(predictions, test_data$price)^2

cat("\n📊 Model Evaluation Metrics:\n")
cat("Mean Absolute Error (MAE):", round(mae, 2), "\n")
cat("Mean Squared Error (MSE):", round(mse, 2), "\n")
cat("R-squared:", round(r2, 4), "\n")

# -------------------------------
# 5. Feature Importance & Residuals
# -------------------------------
# Feature Importance
importance <- varImp(model, scale = TRUE)
print(importance)
plot(importance, main = "Feature Importance")

# Residual plot
residuals <- predictions - test_data$price
ggplot(data.frame(Predicted = predictions, Residuals = residuals),
       aes(x = Predicted, y = Residuals)) +
  geom_point(color = "darkred") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  ggtitle("Residuals vs Predicted Price")

# -------------------------------
# 6. Predict Price from User Input
# -------------------------------
# Prompt for user input
input_vals <- list()
input_vals$horsepower <- as.numeric(readline(prompt = "Enter value for horsepower: "))
input_vals$enginesize <- as.numeric(readline(prompt = "Enter value for enginesize: "))
input_vals$highwaympg <- as.numeric(readline(prompt = "Enter value for highwaympg: "))

new_data <- as.data.frame(input_vals)
predicted_price <- predict(model, newdata = new_data)

cat("\n💰 Predicted Car Price: USD", format(round(predicted_price, 2), big.mark = ","), "\n")
