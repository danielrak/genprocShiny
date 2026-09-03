#' Start a genproc execution
#'
#' This adapter keeps execution policy in the application while delegating all
#' case execution, logging, and reproducibility handling to {genproc}.
#'
#' @param f A validated function.
#' @param mask A validated data frame.
#' @param mapping An optional named character vector mapping function arguments
#'   to mask columns.
#' @param use_parallel Whether cases should be run in parallel.
#' @param workers Number of parallel workers, between 1 and 32.
#' @param nonblocking Whether to return a non-blocking job.
#'
#' @return A `genproc_result`, or a non-blocking genproc job when
#'   `nonblocking` is `TRUE`.
#' @noRd
run_genproc <- function(f, mask, mapping = NULL, use_parallel = FALSE,
                        workers = 1L, nonblocking = TRUE) {
  validate_execution_inputs(f, mask, mapping)

  if (!is.logical(use_parallel) || length(use_parallel) != 1L || is.na(use_parallel)) {
    stop("use_parallel must be TRUE or FALSE", call. = FALSE)
  }
  if (!is.logical(nonblocking) || length(nonblocking) != 1L || is.na(nonblocking)) {
    stop("nonblocking must be TRUE or FALSE", call. = FALSE)
  }
  workers <- as.integer(workers)
  if (length(workers) != 1L || is.na(workers) || workers < 1L || workers > 32L) {
    stop("workers must be an integer between 1 and 32", call. = FALSE)
  }

  args <- list(f = f, mask = mask, f_mapping = mapping)
  if (use_parallel) {
    args$parallel <- genproc::parallel_spec(workers = workers)
  }
  if (nonblocking) {
    args$nonblocking <- genproc::nonblocking_spec()
  }
  do.call(genproc::genproc, args)
}

validate_execution_inputs <- function(f, mask, mapping = NULL) {
  validate_func(f)
  validate_mask_data(mask)
  if (!is.null(mapping)) {
    validate_args(mapping, mask, f)
  }
  invisible(TRUE)
}

normalise_job_status <- function(status) {
  if (is.list(status)) {
    for (name in c("status", "state")) {
      if (!is.null(status[[name]])) return(normalise_job_status(status[[name]]))
    }
  }
  tolower(as.character(status)[1L])
}

job_is_terminal <- function(status) {
  normalise_job_status(status) %in% c(
    "complete", "completed", "done", "error", "failed", "finished", "killed"
  )
}
