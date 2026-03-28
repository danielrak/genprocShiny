#' gproc UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom shinyFiles shinyDirButton shinyDirChoose parseDirPath
mod_gproc_ui <- function(id) {
  ns <- NS(id)
  tagList(

    fluidRow(
      column(3,
             textInput(ns("proclabel"), label = tags$h3("Proc label"), value = "first"),
             tags$h3("Logs directory path"),
             shinyDirButton(ns("logspath"), title  = "Logs directory path", label = "Select dir")),

      column(3,
             actionButton(ns("go"), label = "Launch process"),
             tags$h5("Launch exectution console output"),
             wellPanel(verbatimTextOutput(ns("goout")))),

      column(6,
             actionButton(ns("getlogs"), label = "Get logs"),
             tags$h5('Get logs console output'),
             wellPanel(verbatimTextOutput(ns("logmsg"))),
             tags$h3("Process logs"),
             wellPanel(dataTableOutput(ns("log")))))
  )
}

#' gproc Server Functions
#'
#' @noRd
mod_gproc_server <- function(id,
                             mask_data_return,
                             func_code_return, args_mapping_return){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    proc_label <- reactive(input$proclabel)

    volumes <- c("Home" = ".", "D:" = "D:/")
    shinyDirChoose(input, "logspath", roots = volumes, session = session)

    logs_path <- reactive({
      req(input$logspath)
      parseDirPath(volumes, input$logspath)})

    output$goout <- renderPrint({
      req(input$go)

      tryCatch({
        job <- genproc(mask = mask_data_return(), func = func_code(), args_mapping = args(), workers = 10,
                       proc_label = proc_label(), logs_path = logs_path())
        job
      },
      error = function (e) {
        e$message
      })
    })

    logs_data <- reactive({
      file <- file.path(logs_path(), paste0(proc_label(), ".rds"))
      req(file.exists(file))
      ldata <- readRDS(file)
      stopifnot(is.data.frame(ldata))
      ldata
    })

    output$log <- renderDataTable({
      req(input$getlogs)
      logs_data()})
  })
}

## To be copied in the UI
# mod_gproc_ui("gproc_1")

## To be copied in the server
# mod_gproc_server("gproc_1")
