#' func_code UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_func_code_ui <- function(id) {
  ns <- NS(id)
  tagList(

    wellPanel(class = "gp-well1",
    fluidRow(

      column(6,
             textAreaInput(ns("funccode"), label = tags$h3("Your function code"),
                           width = "800px", height = "100px"),
             actionButton(ns("funcok"), label = "Validate function code")),

      column(6,
             tags$h3("This is your function"),
             wellPanel(class = "gp-well2",
                       verbatimTextOutput(ns("functext"))))),

    fluidRow(
      column(6,
             textAreaInput(ns("argmap"), label = tags$h3("Args mapping"),
                           width = "800px", height = "100px"),
             actionButton(ns("argsok"), label = "Validate args map code")),

      column(6,
             tags$h3("This is your args mapping"),
             wellPanel(class = "gp-well2",
                       verbatimTextOutput(ns("argtext")))))
    )
  )
}

#' func_code Server Functions
#'
#' @noRd
mod_func_code_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    func_code <- eventReactive(input$funcok, eval_parse(text = input$funccode))
    output$functext <- renderPrint(func_code())
    args <- eventReactive(input$argsok, eval_parse(text = input$argmap))
    output$argtext <- renderPrint(args())

    list("func_code_return" = func_code,
         "args_mapping_return" = args)

  })
}

## To be copied in the UI
# mod_func_code_ui("func_code_1")

## To be copied in the server
# mod_func_code_server("func_code_1")
