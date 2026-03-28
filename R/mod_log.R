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
    wellPanel(style = "background-color: #ffffe0;",
    fluidRow(
      column(6,
             tags$h3("Get logs"),
             actionButton(ns("getlogs"), label = "Get logs"),
             tags$h5('Get logs console output'),
             wellPanel(verbatimTextOutput(ns("logmsg")))),
      column(6,
             tags$h3("Process logs"),
             wellPanel(style = "height: 150px; overflow-y: auto;",
                       dataTableOutput(ns("log"))))
    )
    )
  )
}

#' log Server Functions
#'
#' @noRd
mod_log_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    file <- reactive(file.path(logs_path(), paste0(proc_label(), ".rds")))

    logs_data <- reactive({

      req(file.exists(file()))
      ldata <- readRDS(file())
      stopifnot(is.data.frame(ldata))
      ldata
    })

    output$logmsg <- renderPrint({
      req(input$getlogs)
      if (file.exists(file())) {
        file()
      } else {paste0(file(), " not found")}
    })

    output$log <- renderDataTable({
      req(input$getlogs)
      logs_data()})

    list("logmsg_return" = logmsg, "log_return" = log)

  })
}

## To be copied in the UI
# mod_log_ui("log_1")

## To be copied in the server
# mod_log_server("log_1")
