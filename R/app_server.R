#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic
  mask_data_return <- mod_mask_server("mask_1")
  func_mod_return <- mod_func_code_server("func_1")


  mod_gproc_server("gproc_1",
                   mask_data_return = mask_data_return,
                   func_code_return = func_mod_return[["func_code_return"]],
                   args_mapping_return = func_mod_return[["args_mapping_return"]])
}
