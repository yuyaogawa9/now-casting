
rm(list = ls()); gc()
library(stats)
library(data.table)

setwd('/Users/yuyaogawa/Documents/Home Work/nowcasting')
source("R/fcst.monthly.series.R")
# Convert to quarterly data
toquarterly <- function(data) {
  vars <- setdiff(names(data), "date")
  data[
    , lapply(.SD, mean, na.rm = TRUE),
    by = .(date = lubridate::ceiling_date(date, 'quarter')),
    .SDcols = vars]
}

data <- fread('data/raw_fred_data.csv')
monthly_final <- fread('data/transformed_fred_data.csv')

used_id1 <- c("date","UNRATE","PERMIT","IPG3344S","IPN3311A2RS","UMCSENT","INDPRO","GS10",
              "PI","JTSJOL","MRTSSM44000USS","FEDFUNDS","BUSLOANS","CPIAUCSL","M2SL",
              "VIXCLS","CES3000000008","BAA10YM","IMPCH","HOUST")

used_id2 <- c("date","UNRATE","PERMIT","INDPRO","GS10",
              "PI","FEDFUNDS","BUSLOANS","CPIAUCSL","M2SL",
              "CES3000000008","BAA10YM","HOUST", "PAYEMS","GS10")

monthly_final <- monthly_final[, ..used_id1]

# find a row that has no NAs
train_start_dt <- monthly_final[which(rowSums(is.na(monthly_final)) == 0), min(date)]
train_end_dt <- data[!is.na(GDP), max(date)] - months(1)

monthly_final_train <-
  monthly_final[date >= train_start_dt & date <= train_end_dt]

quarterly_final_train <-
  toquarterly(monthly_final_train)

quarterly_final_train <- merge(
  quarterly_final_train,
  data[!is.na(GDP), .(date, GDP = 100 * log(GDP))],
  by = "date",
  all.x = TRUE
)

X_q <- as.matrix(quarterly_final_train[, !c("GDP", "date")])
X_q_scaled <- scale(X_q)

X_center <- attr(X_q_scaled, "scaled:center")
X_scale  <- attr(X_q_scaled, "scaled:scale")

pca <- prcomp(X_q_scaled, center = FALSE, scale. = FALSE)

F_q <- X_q_scaled %*% pca$rotation[, 1, drop = FALSE]
F_q2 <- X_q_scaled %*% pca$rotation[, 2, drop = FALSE]

gdp_model <- lm(GDP ~ F_q + F_q2, data = data.table(
  GDP = quarterly_final_train$GDP,
  F_q = F_q,
  F_q2 = F_q2
))

summary(gdp_model)
gdp_model$residuals

dfm_model <- list(
  pca        = pca,
  gdp_model = gdp_model,
  center    = X_center,
  scale     = X_scale
)

saveRDS(dfm_model, file = 'models/dyfactort_model.rds')
