#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic
  mask_data_return <- mod_mask_server("mask_1")
  mod_gproc_server("gproc_1", mask_data_return = mask_data_return)
}
