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

#' Validate mask data
#'
#' @description Validate mask data
#'
#' @return User feedback
#' @param mask_data Mask data
#'
#' @noRd
validate_mask_data <- function (mask_data) {

  if (! is.data.frame(mask_data)) {
    stop("Mask data must be a data.frame")
  }
  if (nrow(mask_data) == 0) {
    stop("Mask data must have at least one row")
  }
  "Mask data is valid"
}

#' Validate function expression
#'
#' @description Make sure the code parsed by the user renders a function and not another R object
#'
#' @return User feedback
#' @param object Object to test
#'
#' @noRd
validate_func <- function (object) {

  if (! is.function(object)) {
    stop("You must code a function and not something of other class")
  }
  "Function code is valid"
}

#' Validate args mapping
#'
#' @description Validate args mapping
#'
#' @return User feedback
#' @param object Object to test
#' @param func Corresponding function
#' @param mask_data Corresponding mask data
#'
#' @noRd
validate_args <- function (object, mask_data, func) {

  if (! is.character(object)) {
    stop("You must code a character vector and not something of other class")
  }

  if (! identical(length(names(object)), length(object))) {
    stop("The character vector must be named (over the function arguments)")
  }

  # args that are not in mask
  args_nomask <- object[! object %in% names(mask_data)]
  if (length(args_nomask) > 0) {
    cat(args_nomask)
    stop("These values doest not match mask names")
  }

  # args names that are not in function formals name
  args_nofunc <- names(object)[! names(object) %in% names(formals(func))]
  if (length(args_nofunc) > 0) {
    cat(args_nofunc)
    stop("These names does not match function arguments")
  }

  "Args mapping code is valid"

}
