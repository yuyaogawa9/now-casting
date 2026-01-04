
rm(list = ls()); gc()
library(keyring)
library(data.table)
library(fredr)
library(pbapply)

setwd('/Users/yuyaogawa/Documents/Home Work/nowcasting')

# Set FRED API key
# keyring::key_set(service = "FRED_API_KEY", username = "yuya")
fredr::fredr_set_key(key = key_get('FRED_API_KEY', 'yuya'))

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


get_fred_series <- function(id, start = "1947-01-01") {
  df <- data.table(
    fredr(
      series_id = id,
      observation_start = as.Date(start)
    )
  )
  df[, .(date, value)]
}

to_monthly <- function(df, freq) {
  if (freq == "Monthly") {
    df[, date := as.Date(date)]
    return(df)
  }

  if (freq == "Quarterly") {
    df[, date := lubridate::floor_date(date, "month")]
    return(df)
  }

  if (grepl("Weekly|Daily", freq)) {
    df[
      , .(value = mean(value, na.rm = TRUE)),
      by = .(date = lubridate::floor_date(date, "month"))
    ]
  }
}

get_freq <- function(id) {
  fredr_series(id)$frequency
}

monthly_panel <- rbindlist(
  pblapply(series_ids, function(id) {
    freq <- get_freq(id)
    df   <- get_fred_series(id)
    df_m <- to_monthly(df, freq)
    df_m[, series_id := id]
    df_m
  }),
  fill = TRUE
)

monthly_data_all <- dcast(
  monthly_panel,
  date ~ series_id,
  value.var = "value"
)[order(date)]

fwrite(monthly_data_all, 'data/raw_fred_data.csv')

# Data filtering
monthly_data <- monthly_data_all[, -"GDP"][order(date)]

# Apply transformations
rate_cols <- c(
  "UNRATE", "FEDFUNDS", "GS10",
  "BAA10YM" #,"T10Y2Y"
)

level_cols <- setdiff(names(monthly_data), c("date", rate_cols))

monthly_transform <-
  copy(monthly_data[, ..level_cols])[, (level_cols) := lapply(.SD, function(x) 100 * log(x)), .SDcols = level_cols]


monthly_final <- cbind(date = monthly_data[, date], monthly_transform, monthly_data[, ..rate_cols])

fwrite(monthly_final, 'data/transformed_fred_data.csv')
