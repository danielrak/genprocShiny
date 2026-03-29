#' Parse text into code then evaluates it
#'
#' @description Basic helper to transform a text user-input to a code that is then evaluated
#'
#' @return Parsed code output
#' @param text Input text
#'
#' @noRd
eval_parse <- function (text) {
  stopifnot(is.character(text))
  eval(parse(text = text))
}

#' Validate mask file
#'
#' @description Validate mask file
#'
#' @return User feedback
#' @param mask_file Mask file path
#'
#' @noRd
validate_mask_file <- function (mask_file) {

  file <- paste0(mask_file, collapse = "/")
  ext <- tools::file_ext(file)
  if (! ext == "csv") {stop ("Mask file must be a csv")}
  else {"Mask file is valid"}
}
