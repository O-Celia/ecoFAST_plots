# ---- settings ----
dataset <- "fishbiomass"

base_dir <- dataset
out_file <- file.path(base_dir, "manifest.csv")

# ---- helpers ----
get_id_from_file <- function(x, plot_type) {
  x <- basename(x)

  if (plot_type %in% c("classif", "detection")) {
    return(sub("_aicasd_.*$", "", x))
  }

  if (plot_type == "dynfoot") {
    return(sub("\\.png$", "", x))
  }

  sub("\\.png$", "", x)
}

make_manifest_block <- function(dataset, plot_type) {
  plot_dir <- file.path(dataset, plot_type)

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
    path = file.path(dataset, plot_type, files),
    stringsAsFactors = FALSE
  )
}

# ---- create manifest ----
manifest <- do.call(
  rbind,
  lapply(c("classif", "detection", "dynfoot"), function(plot_type) {
    make_manifest_block(dataset, plot_type)
  })
)

manifest <- manifest[order(manifest$series_id, manifest$plot_type), ]

write.csv(manifest, out_file, row.names = FALSE)

message("Manifest written to: ", out_file)
message("Rows: ", nrow(manifest))