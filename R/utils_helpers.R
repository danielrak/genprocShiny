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

