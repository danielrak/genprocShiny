#' genproc
#'
#' @description The genproc function
#'
#' @param mask data.frame. The mask.
#' @param func function. The function to apply to the mask.
#' @param args_mapping Named vector. Arguments mapping.
#' @param workers Numeric 1L. Number of workers.
#' @param proc_label Character 1L. Process label.
#' @param logs_path Character 1L. Logs path.
#' @return The return value, if any, from executing the function.
#'
#' @noRd
genproc <- function (mask, func, args_mapping, workers = 10, proc_label, logs_path) {

  func_renamed <- rename_function_params(func, mapping = args_mapping)
  func_trycatch_logrow <- add_trycatch_logrow(func_renamed)
  std_err_file <- paste0(proc_label, "_", "_err.log")
  std_out_file <- paste0(proc_label, "_", "_out.log")
  log_file = paste0(proc_label, ".rds")

  dir.create(logs_path, showWarnings = FALSE)

  callr::r_bg(func = \(mask, final_func, res_path, workers) {

    future::plan(future::multisession, workers = workers)
    on.exit(future::plan(future::sequential), add = TRUE)

    logs <- furrr::future_pmap_dfr(mask[, names(formals(final_func)), drop = FALSE], final_func)

    saveRDS(logs, res_path)
    invisible(NULL)
  },
  args = list(mask = mask, final_func = func_trycatch_logrow,
              res_path = file.path(logs_path, log_file), workers = workers),
  stderr = file.path(logs_path, std_err_file),
  stdout = file.path(logs_path, std_out_file))

}

