# Load required libraries
library(ggplot2)
library(reshape2) # For visualizing the correlation matrix

# Step 1: Load the Dataset
dataset_path <- "D:/AST LAB/10/10.csv"

# Check if file exists
if (!file.exists(dataset_path)) {
  stop("Error: Dataset not found! Check file path.")
}

# Load dataset
data <- read.csv(dataset_path, stringsAsFactors = FALSE)

# View first few rows
cat("\n✅ First few rows of the dataset:\n")
print(head(data))

# Step 2: Handling Missing Data
data$Age[is.na(data$Age)] <- mean(data$Age, na.rm = TRUE)
data$Embarked[is.na(data$Embarked)] <- "S"

cat("\n✅ Missing data handled.\n")

# Step 3: Convert Categorical Variables to Factors
data$Survived <- as.factor(data$Survived)
data$Sex <- as.factor(data$Sex)
data$Embarked <- as.factor(data$Embarked)
data$Pclass <- as.factor(data$Pclass)

cat("\n✅ Categorical variables converted to factors.\n")

# Step 4: Correlation Analysis (Numerical Variables)
numeric_vars <- data[, sapply(data, is.numeric)]
cor_matrix <- cor(numeric_vars, use = "complete.obs")

cat("\n📊 Correlation Matrix of Numerical Variables:\n")
print(cor_matrix)

# Visual Representation of Correlation Matrix (Heatmap)
melted_cor_matrix <- melt(cor_matrix)
correlation_heatmap <- ggplot(melted_cor_matrix, aes(Var2, Var1, fill = value)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "blue", mid = "white", high = "red",
                       midpoint = 0, limit = c(-1, 1), space = "Lab",
                       name = "Pearson\nCorrelation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1,
                                   size = 10, hjust = 1)) +
  coord_fixed() +
  ggtitle("Correlation Heatmap of Numerical Features")

print(correlation_heatmap)
cat("\n📊 Correlation heatmap generated. Check the 'Plots' tab.\n")

# Step 5: Regression Analysis
# Predicting survival based on Age, Fare, and Pclass
model <- glm(Survived ~ Age + Fare + Pclass, data = data, family = binomial)

cat("\n📈 Regression Model Summary (Predicting Survival):\n")
print(summary(model))

# Visual Representation of Regression Analysis (using predicted probabilities)
predicted_probabilities <- predict(model, type = "response")
data$PredictedSurvival <- factor(ifelse(predicted_probabilities > 0.5, "Yes", "No"))

regression_scatterplot <- ggplot(data, aes(x = Age, y = Fare, color = PredictedSurvival)) +
  geom_point(alpha = 0.6) +
  labs(color = "Predicted Survival") +
  ggtitle("Scatter Plot of Age vs Fare with Predicted Survival") +
  theme_minimal()

print(regression_scatterplot)
cat("\n📊 Scatter plot with predicted survival generated. Check the 'Plots' tab.\n")

# Comparison of Actual vs Predicted Survival
comparison_plot <- ggplot(data, aes(x = Survived, fill = PredictedSurvival)) +
  geom_bar(position = "dodge") +
  labs(fill = "Predicted Survival") +
  ggtitle("Comparison of Actual vs Predicted Survival") +
  theme_minimal()

print(comparison_plot)
cat("\n📊 Bar plot comparing actual and predicted survival generated. Check the 'Plots' tab.\n")

# Step 6: Additional Data Visualizations

# Scatter Plot of Age vs Fare with Survival Coloring
scatter_age_fare_survival <- ggplot(data, aes(x = Age, y = Fare, color = Survived)) +
  geom_point(alpha = 0.6) +
  ggtitle("Scatter Plot of Age vs Fare by Survival Status") +
  theme_minimal()

print(scatter_age_fare_survival)
cat("\n📊 Scatter plot of Age vs Fare by Survival Status generated. Check the 'Plots' tab.\n")

# Boxplot of Age by Survival
boxplot_age_survival <- ggplot(data, aes(x = Survived, y = Age, fill = Survived)) +
  geom_boxplot() +
  ggtitle("Age Distribution by Survival") +
  theme_minimal()

print(boxplot_age_survival)
cat("\n📊 Boxplot of Age by Survival generated. Check the 'Plots' tab.\n")

# Bar Plot for Survival Rate by Pclass
barplot_survival_pclass <- ggplot(data, aes(x = Pclass, fill = Survived)) +
  geom_bar(position = "dodge") +
  ggtitle("Survival by Passenger Class") +
  theme_minimal() +
  labs(x = "Passenger Class")

print(barplot_survival_pclass)
cat("\n📊 Bar plot of Survival by Passenger Class generated. Check the 'Plots' tab.\n")

# Histogram of Fare Distribution
histogram_fare <- ggplot(data, aes(x = Fare)) +
  geom_histogram(binwidth = 10, fill = "blue", color = "black") +
  ggtitle("Fare Distribution of Passengers") +
  theme_minimal()

print(histogram_fare)
cat("\n📊 Histogram of Fare Distribution generated. Check the 'Plots' tab.\n")

cat("\n✅ R program completed successfully! Check the 'Console' for results and the 'Plots' tab for graphs.\n")
