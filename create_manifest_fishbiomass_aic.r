# ---- settings ----
dataset <- "fishbiomass"

analysis <- "aic"
base_dir <- file.path(dataset, analysis)
out_file <- file.path(base_dir, "manifest.csv")

# ---- helpers ----
get_id_from_file <- function(x, plot_type) {
  x <- basename(x)
  x <- sub("\\.(png|jpg|jpeg)$", "", x, ignore.case = TRUE)

  if (plot_type %in% c("classif", "detection")) {
    return(sub("_(aic|aicasd).*$", "", x))
  }

  x
}

make_manifest_block <- function(dataset, analysis, plot_type) {
  plot_dir <- file.path(dataset, analysis, plot_type)

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
    analysis = analysis,
    series_id = get_id_from_file(files, plot_type),
    plot_type = plot_type,
    path = file.path(dataset, analysis, plot_type, files),
    stringsAsFactors = FALSE
  )
}

# ---- checks ----
if (!dir.exists(base_dir)) {
  stop("Base folder does not exist: ", base_dir, call. = FALSE)
}

# ---- detect available plot folders ----
all_plot_types <- c("classif", "detection", "dynfoot")

plot_types <- all_plot_types[
  dir.exists(file.path(dataset, analysis, all_plot_types))
]

if (length(plot_types) == 0) {
  stop("No plot folders found in: ", base_dir, call. = FALSE)
}

# ---- create manifest ----
manifest <- do.call(
  rbind,
  lapply(plot_types, function(plot_type) {
    make_manifest_block(dataset, analysis, plot_type)
  })
)

if (is.null(manifest) || nrow(manifest) == 0) {
  stop("No plot files found for dataset: ", dataset, "/", analysis, call. = FALSE)
}

manifest <- manifest[order(manifest$series_id, manifest$plot_type), ]

write.csv(manifest, out_file, row.names = FALSE)

message("Manifest written to: ", out_file)
message("Rows: ", nrow(manifest))
message("Plot types included: ", paste(unique(manifest$plot_type), collapse = ", "))
