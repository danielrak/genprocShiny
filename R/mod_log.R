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

    tags$h3("Logs directory path"),
    shinyDirButton(ns("logspath"), title  = "Logs directory path", label = "Select dir"),
    tags$h5("Selected logs directory:"),
    wellPanel(verbatimTextOutput("logspathout")),
    actionButton(ns("getlogs"), label = "Get logs"),
    tags$h5('Get logs console output'),
    wellPanel(verbatimTextOutput(ns("logmsg"))),
    tags$h3("Process logs"),
    wellPanel(dataTableOutput(ns("log")))
  )
}

#' log Server Functions
#'
#' @noRd
mod_log_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    logs_path <- reactive({
      req(input$logspath)
      parseDirPath(volumes, input$logspath)})

    output$logspathout <- renderPrint({
      req(input$logspath)
      logs_path()
    })

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
