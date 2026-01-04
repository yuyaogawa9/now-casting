# train_dyfactort.R

# This script trains a dynamic factor model using the provided dataset.
# It includes functions for model fitting and parameter estimation.

# Load necessary libraries
library(dyfactor)

# Function to load and preprocess data
load_data <- function(file_path) {
  data <- read.csv(file_path)
  # Add any necessary preprocessing steps here
  return(data)
}

# Function to train the dynamic factor model
train_dyfactort_model <- function(data) {
  # Fit the dynamic factor model
  model <- dyfactor(data)
  return(model)
}

# Main execution
data_file <- "../data/transformed_fred_data.csv"  # Adjust path as necessary
data <- load_data(data_file)
dyfactort_model <- train_dyfactort_model(data)

# Save the trained model
saveRDS(dyfactort_model, "../models/dyfactort_model.rds")  # Adjust path as necessary

# Print a message indicating the model has been trained and saved
cat("Dynamic factor model trained and saved successfully.\n")