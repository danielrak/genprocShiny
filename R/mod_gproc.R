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

    wellPanel(class = "gp-well1",
    fluidRow(
      column(4,
             textInput(ns("proclabel"), label = tags$h3("Proc label"), value = "first")),

      column(4,
             tags$h3("Logs directory path"),
             shinyDirButton(ns("logspath"), title  = "Logs directory path", label = "Select dir"),
             tags$h5("Selected logs directory"),
             wellPanel(verbatimTextOutput(ns("logspathout")))),

      column(4,
             tags$h3("Launch"),
             actionButton(ns("go"), label = "Launch process"),
             tags$h5("Launch exectution console output"),
             wellPanel(verbatimTextOutput(ns("goout")))))
    )
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

    logs_path <- reactive({
      req(input$logspath)
      parseDirPath(volumes, input$logspath)})

    output$logspathout <- renderPrint({
      req(input$logspath)
      logs_path()
    })

    volumes <- c("Home" = ".", "D:" = "D:/")
    shinyDirChoose(input, "logspath", roots = volumes, session = session)

    output$goout <- renderPrint({
      req(input$go)

      tryCatch({
        job <- genproc(mask = mask_data_return(),
                       func = func_code_return(),
                       args_mapping = args_mapping_return(),
                       proc_label = proc_label(),
                       logs_path = logs_path())
        job
      },
      error = function (e) {
        e$message
      })
    })

    list(logs_path_return = logs_path,
         proc_label_return = proc_label)

  })
}
