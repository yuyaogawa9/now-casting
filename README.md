# Nowcasting Project

This repository contains scripts and data for nowcasting economic indicators using various statistical models. The primary focus is on generating GDP nowcasts and forecasting monthly time series data.

## Project Structure

- **R/**: Contains R scripts for data processing, model training, and forecasting.
  - `1 - update_data.R`: Updates the dataset used in the analysis, including functions to fetch and preprocess data.
  - `2 - train_score_bvar.R`: Trains a Bayesian Vector Autoregression (BVAR) model and evaluates its performance.
  - `3 - train_dyfactort.R`: Trains a dynamic factor model, including functions for model fitting and parameter estimation.
  - `4 - nowcast_gdp.R`: Generates GDP nowcasts using the trained models.
  - `fcst.monthly.series.R`: Forecasts monthly time series data.

- **data/**: Contains datasets used in the analysis.
  - `quarterly_bvar_forecast_blended.csv`: Blended forecasts from the BVAR model.
  - `raw_fred_data.csv`: Raw data sourced from the Federal Reserve Economic Data (FRED).
  - `transformed_fred_data.csv`: Transformed version of the raw FRED data, ready for analysis.

- **models/**: Stores trained models.
  - `dyfactort_model.rds`: The trained dynamic factor model in R's serialized format.

- **.github/**: Contains GitHub Actions workflows.
  - `workflows/r-cmd-check.yml`: Defines a workflow for R CMD check to ensure code quality.

- **.gitignore**: Specifies files and directories to be ignored by Git.

- **LICENSE**: Licensing information for the project.

- **README.md**: Documentation for the project.

- **docs/**: Contains additional documentation.
  - `CONTRIBUTING.md`: Guidelines for contributing to the project.

## Installation

To get started with this project, clone the repository and install the required R packages. You may need to install the following packages:

```R
install.packages(c("forecast", "vars", "dplyr", "ggplot2"))
```

## Usage

1. Update the dataset by running `R/1 - update_data.R`.
2. Train the BVAR model using `R/2 - train_score_bvar.R`.
3. Train the dynamic factor model with `R/3 - train_dyfactort.R`.
4. Generate GDP nowcasts by executing `R/4 - nowcast_gdp.R`.
5. Forecast monthly time series data using `R/fcst.monthly.series.R`.

## Contributing

Please refer to `docs/CONTRIBUTING.md` for guidelines on how to contribute to this project.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.