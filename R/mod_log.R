#' Results module
#'
#' Presents an existing `genproc_result`. It never runs anything and never
#' looks for a result on disk: everything comes from the execution module.
#'
#' @param id Module identifier.
#' @param execution Execution module contract (`result`, `state`, `error`).
#' @return This presentation-only server has no return value.
#' @noRd
mod_log_ui <- function(id) {
  ns <- NS(id)
  tagList(wellPanel(class = "gp-well1", fluidRow(
    tags$h2("4 - Results"),
    column(4,
      tags$h3("Run status"), wellPanel(verbatimTextOutput(ns("status"))),
      tags$h3("Overview"), wellPanel(verbatimTextOutput(ns("overview")))
    ),
    column(8, tabsetPanel(
      tabPanel("Log",
        wellPanel(class = "gp-well2", DT::DTOutput(ns("log")))),
      tabPanel("Errors",
        wellPanel(class = "gp-well2", DT::DTOutput(ns("errors"))),
        tags$h4("Traceback of the selected case"),
        wellPanel(verbatimTextOutput(ns("traceback")))),
      tabPanel("Summary",
        wellPanel(verbatimTextOutput(ns("summary")))),
      tabPanel("Reproducibility",
        wellPanel(class = "gp-well2", DT::DTOutput(ns("reproducibility"))),
        tags$h4("Packages"),
        wellPanel(class = "gp-well2", DT::DTOutput(ns("packages"))))
    ))
  )))
}

mod_log_server <- function(id, execution) {
  moduleServer(id, function(input, output, session) {
    result <- reactive({
      req(execution$state() %in% c("done", "stale"))
      value <- execution$result()
      req(result_is_materialised(value))
      value
    })

    output$status <- renderText(format_run_status(execution$state(), execution$error()))
    output$overview <- renderText(format_result_overview(result()))
    output$summary <- renderText(format_result_summary(result()))
    output$log <- DT::renderDT(result()$log, selection = "none")
    output$errors <- DT::renderDT(
      result_errors(result(), include_traceback = FALSE), selection = "single"
    )
    output$traceback <- renderText({
      errors <- result_errors(result())
      selected <- input$errors_rows_selected
      details <- if (length(selected) == 1L) {
        case_traceback(result(), errors$case_id[selected])
      }
      format_case_traceback(details)
    })
    output$reproducibility <- DT::renderDT(reproducibility_fields(result()), selection = "none")
    output$packages <- DT::renderDT(reproducibility_packages(result()), selection = "none")
  })
}
