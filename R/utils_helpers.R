#' Validate mask file
#'
#' @description Strong validations of mask_file
#'
#' @return User feedback
#' @param mask_path Mask path
#'
#' @noRd
validate_mask_file <- function (mask_path) {

  ext <- tools::file_ext(mask_path)
  if (! ext == "csv") {stop ("Mask file must be a csv")}
  else {"Mask file is valid"}

}


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

