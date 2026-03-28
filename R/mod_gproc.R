#' gproc UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_gproc_ui <- function(id) {
  ns <- NS(id)
  tagList(

    textAreaInput(ns("funccode"), label = "Your function code", width = "400px", height = "200px"),
    actionButton(ns("funcok"), label = "Validate function code"),
    "This is your function:",
    verbatimTextOutput(ns("functext")),

    textAreaInput(ns("argmap"), label = "Args mapping", width = "400px", height = "100px"),
    actionButton(ns("argsok"), label = "Validate args map code"),
    "This is your args mapping:",
    verbatimTextOutput(ns("argtext")),

    actionButton(ns("go"), label = "Launch process"),
    "Launch exectution console output:",
    verbatimTextOutput(ns("goout")),

    actionButton(ns("getlogs"), label = "Get logs"),
    'Here is the logs:',
    verbatimTextOutput(ns("logmsg")),
    dataTableOutput(ns("log"))

  )
}

#' gproc Server Functions
#'
#' @noRd
mod_gproc_server <- function(id, mask_data_return){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    func_code <- eventReactive(input$funcok, eval(parse(text = input$funccode)))
    output$functext <- renderPrint(func_code())
    args <- eventReactive(input$argsok, eval(parse(text = input$argmap)))
    output$argtext <- renderPrint(args())

    output$goout <- renderPrint({
      req(input$go)

      tryCatch({
        job <- genproc(mask = mask_data_return(), func = func_code(), args_mapping = args(), workers = 10,
                       proc_label = "first", logs_path = "D:/gprocpoc/out")
        job
      },
      error = function (e) {
        e$message
      })
    })

    observeEvent(input$getlogs, {
      invalidateLater(1000) # re-run l'observer chaque 1000 ms?
      if ("job" %in% ls()) {
        observeEvent({
          ! job$is_alive()},
          {

            logs <- readRDS(file.path(logs_path, paste0(proc_label, ".rds")))
            output$log <- renderDataTable(logs)
            output$logmsg <- renderPrint("Logs successfully read")

          })
      } else {output$logmsg <- renderPrint("No logs produced yet")}
    })


  })
}

## To be copied in the UI
# mod_gproc_ui("gproc_1")

## To be copied in the server
# mod_gproc_server("gproc_1")
