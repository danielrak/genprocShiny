#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  mask <- mod_mask_server("mask_1")
  function_input <- mod_func_code_server("func_1", mask = mask)
  execution <- mod_gproc_server("gproc_1", mask = mask, function_input = function_input)
  mod_log_server("log_1", execution = execution)
}
