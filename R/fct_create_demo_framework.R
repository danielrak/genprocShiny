#' create_demo_framework
#'
#' @description Given a path, create the necessary framework for PoC demo
#'  (file conversion)
#'
#' @return Create, within the designated path: R datasets, mask, function and args mapping
#' @export
create_demo_framework <- function(demo_path) {

  instant <- format(Sys.time(), format = "%Y-%m-%d_%H-%M-%s")
  demo_folder <- file.path(demo_path, paste0("demo_genprocShiny - ", instant))
  suppressWarnings({dir.create(demo_folder)})

  # R datasets
  datasets_folder <- file.path(demo_folder, "r_built_in_datasets")
  suppressWarnings({dir.create(datasets_folder)})
  dlist <- data()$results[, "Item"]

  purrr::map(dlist, \(x) {
    tryCatch({
      data <- get(x)
      saveRDS(data, file.path(datasets_folder, paste0(x, ".rds")))
    }, error = \(e) e$message)
  })

  # Out
  out_folder <- file.path(demo_folder, "out")
  suppressWarnings({dir.create(out_folder)})

  # Mask
  mask_folder <- file.path(demo_folder, "mask")
  suppressWarnings({dir.create(mask_folder)})
  lfiles <- list.files(datasets_folder, full.names = TRUE)
  lfiles_df <- data.frame(lfiles)
  lfiles_df <- dplyr::mutate(
    lfiles_df,
    input_dir = dirname(lfiles),
    input_file = basename(lfiles),
    output_dir = out_folder,
    output_file = stringr::str_replace(input_file, "\\.rds", ".csv"))

  readr::write_csv(lfiles_df, file.path(mask_folder, "mask.csv"))
  utils::write.table(lfiles_df, file.path(mask_folder, "mask.txt"))

  # func
  func_folder <- file.path(demo_folder, "func")
  suppressWarnings({dir.create(func_folder)})
  func_and_args <- app_sys("demo_assets", "func_and_args_mapping.R")
  file.copy(func_and_args, file.path(func_folder, "func_and_args_mapping.R"))

  message(paste0("Demo framework created at: ", demo_folder))
  invisible()

}
