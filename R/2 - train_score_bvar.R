# Load necessary libraries
library(vars)  # For VAR modeling
library(readr)  # For reading CSV files
library(dplyr)  # For data manipulation
library(tidyr)  # For data tidying

# Function to train and score BVAR model
train_score_bvar <- function(data, p = 2) {
  # Fit the BVAR model
  bvar_model <- VAR(data, p = p, type = "const")
  
  # Generate forecasts
  forecast <- predict(bvar_model, n.ahead = 10)
  
  # Calculate performance metrics (e.g., RMSE)
  actuals <- data[(nrow(data) - 9):nrow(data), ]  # Last 10 observations
  predictions <- forecast$fcst
  
  # Calculate RMSE for each variable
  rmse <- sqrt(mean((actuals - predictions)^2, na.rm = TRUE))
  
  return(list(model = bvar_model, forecast = forecast, rmse = rmse))
}

# Main execution
if (interactive()) {
  # Load the transformed FRED data
  transformed_data <- read_csv("../data/transformed_fred_data.csv")
  
  # Train and score the BVAR model
  results <- train_score_bvar(transformed_data)
  
  # Print RMSE
  print(paste("RMSE of the BVAR model:", results$rmse))
}