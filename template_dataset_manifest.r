# ---- settings ----
dataset <- "" # NAME DATASET

analysis <- "" # NAME ANALYSIS (options : "aic", "aicasd", "loo")

base_dir <- file.path(dataset, analysis)
out_file <- file.path(base_dir, "manifest.csv")

# ---- helpers ----
get_id_from_file <- function(x, plot_type) {
  x <- basename(x)

  if (plot_type %in% c("classif", "detection")) {
    x <- sub("\\.(png|jpg|jpeg)$", "", x, ignore.case = TRUE)
    return(sub("_(aic|aicasd).*$", "", x))
  }

  if (plot_type == "dynfoot") {
    return(sub("\\.(png|jpg|jpeg)$", "", x, ignore.case = TRUE))
  }

  sub("\\.(png|jpg|jpeg)$", "", x, ignore.case = TRUE)
}

make_manifest_block <- function(dataset, plot_type) {
  plot_dir <- file.path(dataset, analysis, plot_type)

  if (!dir.exists(plot_dir)) {
    warning("Missing folder: ", plot_dir)
    return(data.frame())
  }

  files <- list.files(
    plot_dir,
    pattern = "\\.(png|jpg|jpeg)$",
    full.names = FALSE,
    ignore.case = TRUE
  )

  if (length(files) == 0) {
    warning("No image files found in: ", plot_dir)
    return(data.frame())
  }

  data.frame(
    dataset = dataset,
    series_id = get_id_from_file(files, plot_type),
    plot_type = plot_type,
    path = file.path(dataset, analysis, plot_type, files),
    stringsAsFactors = FALSE
  )
}

# ---- create manifest ----
plot_types <- c("classif", "detection", "dynfoot")

manifest <- do.call(
  rbind,
  lapply(plot_types, function(plot_type) {
    make_manifest_block(dataset, plot_type)
  })
)

if (is.null(manifest) || nrow(manifest) == 0) {
  stop("No plot files found for dataset: ", dataset, call. = FALSE)
}

manifest <- manifest[order(manifest$series_id, manifest$plot_type), ]

write.csv(manifest, out_file, row.names = FALSE)

message("Manifest written to: ", out_file)
message("Rows: ", nrow(manifest))
