# Nowcasting GDP Script

# Load necessary libraries
library(readr)  # For reading CSV files
library(dplyr)  # For data manipulation
library(forecast)  # For forecasting functions
library(tidyr)  # For data tidying

# Load the trained models
dyfactort_model <- readRDS("../models/dyfactort_model.rds")

# Load the transformed FRED data
transformed_data <- read_csv("../data/transformed_fred_data.csv")

# Function to generate GDP nowcasts
generate_nowcast <- function(data, model) {
  # Prepare the data for prediction
  # This may involve selecting relevant features and transforming the data as needed
  
  # Generate predictions using the dynamic factor model
  nowcast <- predict(model, newdata = data)
  
  return(nowcast)
}

# Generate the nowcast
gdp_nowcast <- generate_nowcast(transformed_data, dyfactort_model)

# Output the nowcast results
write_csv(gdp_nowcast, "../data/gdp_nowcast_results.csv")

# Print a message indicating completion
cat("GDP nowcast has been generated and saved to data/gdp_nowcast_results.csv\n")