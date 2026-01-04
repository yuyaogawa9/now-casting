fcast.monthly.series <-
  function(train_matrix = y,
           h = 6,
           transformation = 'level',
           start_dt = as.Date("2025-09-01"),
           lambda_mode = 0.1,
           lambda_sd = 0.1,
           alpha_mode = 1.5,
           alpha_sd = 0.5,
           n.lags = 12,
           n.draw = 20000,
           n.burn = 5000
           ) {

  if (transformation == 'level') {
    psi <- apply(train_matrix, 2, function(x) {
      stats::var(diff(x), na.rm = TRUE)
    })
  } else {
    psi <- "auto"
  }

  priors <- BVAR::bv_priors(
    mn = BVAR::bv_mn(
      psi    = BVAR::bv_psi(mode = psi),
      lambda = BVAR::bv_lambda(mode = lambda_mode, sd = lambda_sd),
      alpha  = BVAR::bv_alpha(mode = alpha_mode,  sd = alpha_sd)
    )
  )

  bvar_fit <- BVAR::bvar(
    train_matrix,
    lags   = n.lags,        # standard for monthly macro data
    n_draw = n.draw,
    n_burn = n.burn,
    priors = priors,
    verbose = TRUE
  )

  fcst <- stats::predict(bvar_fit, horizon = h)

  fcst_mean <- apply(fcst$fcast, c(2, 3), mean)

  colnames(fcst_mean) <- fcst$variables

  fcst_dt <- data.table(
    date = seq(from = start_dt, by = "month", length.out = nrow(fcst_mean)),
    fcst_mean
  )

  return(fcst_dt)

}
