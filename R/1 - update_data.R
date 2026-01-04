# Load necessary libraries
library(dplyr)
library(readr)

# Function to update the dataset
update_dataset <- function() {
  # Fetch raw data from FRED
  raw_data <- read_csv("data/raw_fred_data.csv")
  
  # Perform necessary preprocessing steps
  transformed_data <- raw_data %>%
    # Example preprocessing: filter, mutate, etc.
    filter(!is.na(value)) %>%
    mutate(date = as.Date(date)) %>%
    arrange(date)
  
  # Save the transformed data
  write_csv(transformed_data, "data/transformed_fred_data.csv")
  
  # Optionally, update the blended forecast data
  # This part can include logic to generate new forecasts based on the updated data
  # For now, we will just copy the existing blended forecast as a placeholder
  file.copy("data/quarterly_bvar_forecast_blended.csv", "data/quarterly_bvar_forecast_blended.csv")
  
  message("Dataset updated successfully.")
}

# Run the update function
update_dataset()