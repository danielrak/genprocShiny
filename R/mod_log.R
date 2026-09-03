#' Results module
#'
#' @param id Module identifier.
#' @param execution Execution module contract.
#' @return This presentation-only server has no return value.
#' @noRd
mod_log_ui <- function(id) {
  ns <- NS(id)
  tagList(wellPanel(class = "gp-well1", fluidRow(
    tags$h2("4 - Results"),
    column(4, tags$h3("Run status"), wellPanel(verbatimTextOutput(ns("status")))),
    column(8, tags$h3("Execution log"), wellPanel(class = "gp-well2", DT::DTOutput(ns("log"))))
  )))
}

mod_log_server <- function(id, execution) {
  moduleServer(id, function(input, output, session) {
    output$status <- renderText({
      state <- execution$state()
      if (!is.null(execution$error())) paste(state, "-", execution$error()) else state
    })
    output$log <- DT::renderDT({
      req(execution$state() %in% c("done", "stale"), execution$result())
      execution$result()$log
    })
  })
}
