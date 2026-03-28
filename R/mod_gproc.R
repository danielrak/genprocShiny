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
             textInput(ns("proclabel"), label = tags$h3("Proc label"), value = "first")),

      column(3,
             actionButton(ns("go"), label = "Launch process"),
             tags$h5("Launch exectution console output"),
             wellPanel(verbatimTextOutput(ns("goout")))))
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

    output$goout <- renderPrint({
      req(input$go)

      tryCatch({
        job <- genproc(mask = mask_data_return(),
                       func = func_code_return(),
                       args_mapping = args_mapping_return(),
                       workers = 10,
                       proc_label = proc_label(),
                       logs_path = logs_path())
        job
      },
      error = function (e) {
        e$message
      })
    })
  })
}
