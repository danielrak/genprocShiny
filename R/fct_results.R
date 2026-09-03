#' Result presentation helpers
#'
#' Pure functions that turn a `genproc_result` into the pieces the results
#' module displays. They rely only on the public {genproc} API and contain no
#' Shiny code, so they can be tested directly.
#'
#' @param result A `genproc_result`.
#' @noRd
result_is_materialised <- function(result) {
  inherits(result, "genproc_result") && !is.null(result$log)
}

format_run_status <- function(state, error = NULL) {
  if (!is.null(error)) return(paste(state, "-", error))
  if (identical(state, "stale")) {
    return("stale - inputs changed since this result was produced, run again to refresh it")
  }
  state
}

format_result_overview <- function(result) {
  stopifnot(inherits(result, "genproc_result"))
  paste(utils::capture.output(print(result)), collapse = "\n")
}

format_result_summary <- function(result) {
  stopifnot(inherits(result, "genproc_result"))
  paste(utils::capture.output(print(summary(result))), collapse = "\n")
}

#' Failed cases of a result
#'
#' @param include_traceback Whether to keep the traceback column. The table
#'   shown in the app drops it because tracebacks are displayed separately for
#'   the selected case.
#' @noRd
result_errors <- function(result, include_traceback = TRUE) {
  if (!result_is_materialised(result)) return(NULL)
  errors <- genproc::errors(result)
  if (!include_traceback) {
    errors <- errors[, setdiff(names(errors), "traceback"), drop = FALSE]
  }
  errors
}

case_traceback <- function(result, case_id) {
  errors <- result_errors(result)
  if (is.null(errors) || length(case_id) != 1L || !case_id %in% errors$case_id) {
    return(NULL)
  }
  row <- errors[match(case_id, errors$case_id), , drop = FALSE]
  list(
    case_id = case_id,
    error_message = row$error_message,
    traceback = row$traceback
  )
}

format_case_traceback <- function(details) {
  if (is.null(details)) return("Select a failed case to display its traceback")
  traceback <- details$traceback
  if (is.null(traceback) || is.na(traceback) || !nzchar(traceback)) {
    traceback <- "(no traceback captured)"
  }
  paste0(
    "Case ", details$case_id, "\n",
    "Error: ", details$error_message, "\n\n",
    "Traceback:\n", traceback
  )
}

format_execution_mode <- function(reproducibility) {
  parallel <- reproducibility$parallel
  mode <- if (is.null(parallel)) {
    "sequential"
  } else {
    strategy <- parallel$effective_strategy %||% parallel$strategy %||% "parallel"
    workers <- parallel$workers
    if (is.null(workers)) strategy else sprintf("%s (%d workers)", strategy, as.integer(workers))
  }
  if (!is.null(reproducibility$nonblocking)) mode <- paste("non-blocking +", mode)
  mode
}

reproducibility_fields <- function(result) {
  repro <- result$reproducibility
  if (is.null(repro)) return(NULL)
  timestamp <- repro$timestamp
  if (inherits(timestamp, "POSIXt")) timestamp <- format(timestamp, "%Y-%m-%d %H:%M:%S %Z")
  mask_rows <- if (is.data.frame(repro$mask_snapshot)) nrow(repro$mask_snapshot) else NA_integer_
  data.frame(
    field = c("Started", "Execution mode", "R version", "Platform", "OS",
              "Timezone", "Mask rows", "Recorded packages"),
    value = c(as.character(timestamp %||% NA), format_execution_mode(repro),
              as.character(repro$r_version %||% NA), as.character(repro$platform %||% NA),
              as.character(repro$os %||% NA), as.character(repro$timezone %||% NA),
              as.character(mask_rows), as.character(length(repro$packages))),
    stringsAsFactors = FALSE
  )
}

reproducibility_packages <- function(result) {
  packages <- result$reproducibility$packages
  if (is.null(packages) || length(packages) == 0L) {
    return(data.frame(package = character(), version = character(), stringsAsFactors = FALSE))
  }
  packages <- packages[order(names(packages))]
  data.frame(package = names(packages), version = unname(packages), stringsAsFactors = FALSE)
}
