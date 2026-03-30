#' From function to mask
#'
#' @description Transform a function into a genproc compatible mask
#'
#' @param func Function 1L. Input function
#' @return data.frame. Corresponding mask
#'
#' @export
from_function_to_mask <- function(func) {

  if (! is.function(func)) stop("func must be a function")
  formals <- formals(func)

  # minimal iteration: values must be atomic
  check_atomic <- unlist(lapply(formals,
                                \(x) (is.atomic(x) & (length(x) == 1)) |
                                  is.name(x)))
  if (! all(check_atomic)) {
    stop("In this PoC version, values in each func argument must be an atomic of length 1 or 0")
  }
  values <- lapply(formals, \(x) if (is.name(x)) as.character(x) else x)
  data.frame(values)
}
