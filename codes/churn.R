# ========================
# Customer Churn Analysis
# ========================

# Load required libraries
library(dplyr)
library(ggplot2)
library(caret)
library(rpart)
library(rpart.plot)
library(ggcorrplot)

cat("✅ Libraries loaded\n")

# ----------------------------
# 1. Load and Preprocess Dataset
# ----------------------------

data <- read.csv("D:/AST LAB/7/7.csv", stringsAsFactors = FALSE)
cat("✅ Dataset loaded with", nrow(data), "rows and", ncol(data), "columns\n")

# Remove customer ID
data$customerID <- NULL

# Handle missing TotalCharges
data$TotalCharges[data$TotalCharges == ""] <- NA
data$TotalCharges <- as.numeric(data$TotalCharges)
data <- na.omit(data)

# Convert character columns to factors
data <- data %>% mutate_if(is.character, as.factor)

# Add tenure groups for segmentation
data$tenure_group <- cut(data$tenure,
                         breaks = c(0, 12, 24, 48, 60, 72),
                         labels = c("0-12", "13-24", "25-48", "49-60", "61-72"))

cat("✅ Data cleaned and encoded\n")

# ----------------------------
# 2. Exploratory Data Analysis
# ----------------------------

# Churn distribution
ggplot(data, aes(x = Churn, fill = Churn)) +
  geom_bar() +
  labs(title = "Churn Distribution", x = "Churn", y = "Count") +
  theme_minimal()

# Churn by contract type
ggplot(data, aes(x = Contract, fill = Churn)) +
  geom_bar(position = "fill") +
  labs(title = "Churn by Contract Type", y = "Proportion") +
  theme_minimal()

# Churn by internet service
ggplot(data, aes(x = InternetService, fill = Churn)) +
  geom_bar(position = "fill") +
  labs(title = "Churn by Internet Service", y = "Proportion") +
  theme_minimal()

# Churn by tenure group
ggplot(data, aes(x = tenure_group, fill = Churn)) +
  geom_bar(position = "fill") +
  labs(title = "Churn by Tenure Group", y = "Proportion") +
  theme_minimal()

# Correlation matrix of numeric features
num_data <- select_if(data, is.numeric)
cor_matrix <- round(cor(num_data), 2)

ggcorrplot(cor_matrix, hc.order = TRUE, type = "lower",
           lab = TRUE, lab_size = 3, method = "circle",
           colors = c("tomato2", "white", "springgreen3"),
           title = "Correlation Matrix", ggtheme = theme_minimal())

cat("✅ EDA completed with churn visualizations\n")

# ----------------------------
# 3. Build Classification Models
# ----------------------------

# Split dataset
set.seed(123)
trainIndex <- createDataPartition(data$Churn, p = 0.8, list = FALSE)
train <- data[trainIndex, ]
test <- data[-trainIndex, ]

# Logistic Regression
log_model <- glm(Churn ~ ., data = train, family = "binomial")
log_pred <- predict(log_model, test, type = "response")
log_class <- ifelse(log_pred > 0.5, "Yes", "No")
log_class <- factor(log_class, levels = levels(test$Churn))

# Decision Tree
tree_model <- rpart(Churn ~ ., data = train, method = "class")
tree_pred <- predict(tree_model, test, type = "class")

cat("✅ Models trained: Logistic Regression and Decision Tree\n")

# ----------------------------
# 4. Evaluate Model Performance
# ----------------------------

# Confusion Matrix - Logistic Regression
cat("\n📌 Logistic Regression Results:\n")
conf_log <- confusionMatrix(log_class, test$Churn, positive = "Yes")
print(conf_log)

# Confusion Matrix - Decision Tree
cat("\n📌 Decision Tree Results:\n")
conf_tree <- confusionMatrix(tree_pred, test$Churn, positive = "Yes")
print(conf_tree)

# Plot Confusion Matrix - Logistic Regression
conf_table <- as.data.frame(conf_log$table)
colnames(conf_table) <- c("Prediction", "Reference", "Count")

ggplot(conf_table, aes(x = Prediction, y = Reference, fill = Count)) +
  geom_tile(color = "black") +
  geom_text(aes(label = Count), size = 6, color = "white") +
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  labs(title = "Confusion Matrix - Logistic Regression") +
  theme_minimal()

cat("✅ Model evaluation completed\n")

# ----------------------------
# 5. Visualize Feature Importance
# ----------------------------

# Logistic Regression Coefficients
log_coef <- summary(log_model)$coefficients
log_coef_df <- data.frame(Feature = rownames(log_coef), Coef = log_coef[, "Estimate"])
log_coef_df <- log_coef_df[2:11, ]  # Skip intercept

ggplot(log_coef_df, aes(x = reorder(Feature, Coef), y = Coef)) +
  geom_bar(stat = "identity", fill = "orange") +
  coord_flip() +
  labs(title = "Top Logistic Regression Coefficients", x = "Feature", y = "Coefficient") +
  theme_minimal()

# Decision Tree Importance
importance <- as.data.frame(varImp(tree_model))
importance$Feature <- rownames(importance)
importance <- importance[order(importance$Overall, decreasing = TRUE), ]

ggplot(importance[1:10, ], aes(x = reorder(Feature, Overall), y = Overall)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 10 Important Features (Decision Tree)", x = "Feature", y = "Importance") +
  theme_minimal()

# Decision Tree Plot
rpart.plot(tree_model, main = "Decision Tree for Customer Churn")

cat("\n✅ Feature importance visualized and tree plotted. 🎉 Analysis complete!\n")
