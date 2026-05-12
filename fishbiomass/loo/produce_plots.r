data(fishbiomass)
data <- prep_data(fishbiomass, id = "stockid", time = "year", var = "TBbest")
fishbiomass_classif <- run_classif(
    data,
    min_len = 20, str = "aic_asd",
    run_loo = TRUE, two_bkps = FALSE,
    ind_plot = NULL,
    dirname = "[....]/fishbiomass/aic/classif", save_plot = TRUE, cores = 1
)
fishbiomass_dynfoot2 <- run_dynfoot(
    fishbiomass_classif,
    detrend.type = "asclassif",
    min.length = 30,
    winsize = 50,
    winsize_is_percentage = TRUE, makeplots = TRUE, dirname = "[....]/fishbiomass/aic/dynfoot"
)
