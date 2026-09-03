# A small real genproc run used by several tests: three sequential cases, one
# of which fails. Tests calling it skip when genproc is not installed.
demo_result <- function() {
  skip_if_not_installed("genproc", minimum_version = "0.2.0")
  genproc::genproc(
    f = function(x) { if (x == 2) stop("case failed"); x * 2 },
    mask = data.frame(x = 1:3)
  )
}

fake_execution <- function(result, state = "done", error = NULL) {
  list(
    result = shiny::reactive(result),
    state = shiny::reactive(state),
    error = shiny::reactive(error)
  )
}
