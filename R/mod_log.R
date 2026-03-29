#' log UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_log_ui <- function(id) {
  ns <- NS(id)
  tagList(
    wellPanel(class = "gp-well1",
    fluidRow(
      tags$h2("4 - Results"),
      column(4,
             tags$h3("Execution logs"),
             actionButton(ns("getlogs"), label = "Get logs"),
             tags$h5('Get logs status'),
             wellPanel(verbatimTextOutput(ns("logmsg")))),
      column(8,
             tags$h3("Logs"),
             wellPanel(class = "gp-well2",
                       DT::DTOutput(ns("log"))))
    )
    )
  )
}

#' log Server Functions
#'
#' @noRd
mod_log_server <- function(id, logs_path_return, proc_label_return) {
  moduleServer(id, function(input, output, session) {

    file <- reactive({
      req(logs_path_return())
      req(proc_label_return())
      file.path(logs_path_return(), paste0(proc_label_return(), ".rds"))
    })

    logs_data <- reactive({
      req(file.exists(file()))
      ldata <- readRDS(file())
      stopifnot(is.data.frame(ldata))
      ldata
    })

    output$logmsg <- renderPrint({
      req(input$getlogs)
      if (file.exists(file())) {
        paste("Log file found:", file())
      } else {
        paste("Log file not found:", file())
      }
    })

    output$log <- DT::renderDT({
      req(input$getlogs)
      logs_data()
    })
  })
}

## To be copied in the UI
# mod_log_ui("log_1")

## To be copied in the server
# mod_log_server("log_1")
