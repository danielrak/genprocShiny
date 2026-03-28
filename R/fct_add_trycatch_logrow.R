#' add_trycatch_logrow
#'
#' @description Given a normal function, implement a tryCatch wraper around its body.
#'
#' @param f Function 1L. The input function
#' @return function with its initial body wraped into tryCatch
#'
#' @noRd
add_trycatch_logrow <- function(f) {

  arg_names <- names(formals(f))
  old_body <- body(f)

  new_body <- bquote({
    .__args__ <- as.list(environment())
    .__args__ <- .__args__[.(arg_names)]
    .__start__ <- Sys.time()

    tryCatch({
      .(old_body)

      .__log__ <- as.data.frame(.__args__, stringsAsFactors = FALSE)
      .__log__$success <- TRUE
      .__log__$error_message <- NA_character_

      .__log__
    }, error = function(e) {
      .__log__ <- as.data.frame(.__args__, stringsAsFactors = FALSE)
      .__log__$success <- FALSE
      .__log__$error_message <- conditionMessage(e)

      .__log__
    })
  })

  body(f) <- new_body
  f
}
