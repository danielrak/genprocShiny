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

    fluidRow(

      column(6,
             textAreaInput(ns("funccode"), label = tags$h3("Your function code"),
                           width = "800px", height = "150px"),
             actionButton(ns("funcok"), label = "Validate function code")),

      column(6,
             tags$h3("This is your function"),
             wellPanel(style = "height: 150px; overflow-y: auto;",
                       verbatimTextOutput(ns("functext"))))),

    fluidRow(
      column(6,
             textAreaInput(ns("argmap"), label = tags$h3("Args mapping"),
                           width = "800px", height = "150px"),
             actionButton(ns("argsok"), label = "Validate args map code")),

      column(6,
             tags$h3("This is your args mapping"),
             wellPanel(style = "height: 150px; overflow-y: auto;",
                       verbatimTextOutput(ns("argtext")))))
  )
}

#' func_code Server Functions
#'
#' @noRd
mod_func_code_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    func_code <- eventReactive(input$funcok, eval(parse(text = input$funccode)))
    output$functext <- renderPrint(func_code())
    args <- eventReactive(input$argsok, eval(parse(text = input$argmap)))
    output$argtext <- renderPrint(args())

    list("func_code_return" = func_code,
         "args_mapping_return" = args)

  })
}

## To be copied in the UI
# mod_func_code_ui("func_code_1")

## To be copied in the server
# mod_func_code_server("func_code_1")
