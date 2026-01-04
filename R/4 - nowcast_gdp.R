rm(list = ls()); gc()
library(stats)
library(data.table)

data <- fread("data/raw_fred_data.csv")
scoring_data <- fread('data/quarterly_bvar_forecast_blended.csv')
scoring_data <- scoring_data[1]

dfm_model <- readRDS('models/dyfactort_model.rds')

X <- as.matrix(scoring_data[, !"date"])
X_demean <- sweep(X, 2, dfm_model$center, `-`)
X_scaled <- sweep(X_demean, 2, dfm_model$scale, `/`)

F_q <- X_scaled %*% dfm_model$pca$rotation[, 1, drop = FALSE]
F_q2 <- X_scaled %*% dfm_model$pca$rotation[, 2, drop = FALSE]

gdp_nowcast <- predict(dfm_model$gdp_model, newdata = data.frame(F_q = F_q, F_q2 = F_q2))
gdp_nowcast <- exp(gdp_nowcast/100)
gdp_lastQ <- data[!is.na(GDP) , .(GDP, date, max_date = max(date))][date == max_date, GDP]

growth <- (gdp_nowcast - gdp_lastQ) / gdp_nowcast

print(growth)
