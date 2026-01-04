
rm(list = ls()); gc()
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

series_ids <- c(
  # Output & demand
  "GDP", "INDPRO", "IPMAN", "TCU","ACDGNO","IPN3311A2RS", "MRTSSM44000USS",
  "RSAFS", "RRSFS", "PCE", "DGORDER","IPG3361T3S","IPG3344S",
  # Labor
  "PAYEMS", "UNRATE", "ICSA", "CCSA",
  "CES3000000008", "CES0500000030","JTSJOL",
  # Income & consumption
  "PI",
  # Housing
  "HOUST", "PERMIT", "HSN1F",
  # Prices & inflation
  "CPIAUCSL",
  # Financial conditions
  "FEDFUNDS", "GS10", # "T10Y2Y",
  "BAA10YM", "NASDAQCOM", "VIXCLS",
  # Money & credit
  "M2SL", "BUSLOANS",
  # Sentiment
  "UMCSENT",
  # Trade
  "IMPCH"
)

used_id1 <- c("date","UNRATE","PERMIT","IPG3344S","IPN3311A2RS","UMCSENT","INDPRO","GS10",
              "PI","JTSJOL","MRTSSM44000USS","FEDFUNDS","BUSLOANS","CPIAUCSL","M2SL",
              "VIXCLS","CES3000000008","BAA10YM","IMPCH","HOUST")

used_id2 <- c("date","UNRATE","PERMIT","INDPRO","GS10",
              "PI","FEDFUNDS","BUSLOANS","CPIAUCSL","M2SL",
              "CES3000000008","BAA10YM","HOUST", "PAYEMS")

monthly_final <- monthly_final[, ..used_id1]

# find a row that has no NAs
train_end_dt <- monthly_final[which(rowSums(is.na(monthly_final)) == 0), max(date)]
train_start_dt <- monthly_final[which(rowSums(is.na(monthly_final)) == 0), min(date)]
forecast_start_dt <- train_end_dt + months(1)

monthly_final_train <-
  monthly_final[date >= train_start_dt & date <= train_end_dt]

# Train the BVAR model on monthly_final (data enters in levels)
y <- as.matrix(monthly_final_train[, !c("date")])
y <- na.omit(y)

month_fcst_data <-
  fcast.monthly.series(train_matrix = y,
                       h = 6,
                       transformation = "level",
                       start_dt = forecast_start_dt)

actual_data <- monthly_final[date >= forecast_start_dt]
names(actual_data)[2:ncol(actual_data)] <- paste0(names(actual_data)[2:ncol(actual_data)], "_actual")

vars <- setdiff(names(month_fcst_data), "date")

blend_data <- merge(month_fcst_data, actual_data, by = "date", all = TRUE)

blend_data[
  , (vars) := lapply(vars, function(v) {
    fcoalesce(get(paste0(v, "_actual")), get(v))
  })][, grep("_actual$", names(blend_data), value = TRUE) := NULL]


quarterly_fcst_data <- toquarterly(blend_data)

fwrite(quarterly_fcst_data, 'data/quarterly_bvar_forecast_blended.csv')
