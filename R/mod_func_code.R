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

      tags$h2("2 - Function"),

      # function writing
      tabsetPanel(
        tabPanel("From example to function",
                 column(6,
                        textAreaInput(ns("egcode"), label = tags$h3("Write your example code"),
                                         width = "800px", height = "100px"),
                        fluidRow(column(4, actionButton(ns("egok"), label = "Validate example")),
                                 column(6, wellPanel(verbatimTextOutput(ns("egcheck")))))),
                 column(6,
                        tags$h3("Function preview (from example)"),
                        wellPanel(class = "gp-well2",
                                  verbatimTextOutput(ns("egfunctext"))))),
        tabPanel(
          "Write function directly",
          column(6,
                 textAreaInput(ns("funccode"), label = tags$h3("Write your function code"),
                               width = "800px", height = "100px"),
                 fluidRow(column(4, actionButton(ns("funcok"), label = "Validate function")),
                          column(6, wellPanel(verbatimTextOutput(ns("funccheck")))))),

          column(6,
                 tags$h3("Function preview"),
                 wellPanel(class = "gp-well2",
                           verbatimTextOutput(ns("functext"))))),

      tabPanel("Arguments mapping",
               # arguments mapping
               fluidRow(
                 column(6,
                        textAreaInput(ns("argmap"), label = tags$h3("Map your function arguments to mask names"),
                                      width = "800px", height = "100px"),
                        fluidRow(column(4, actionButton(ns("argsok"), label = "Validate mapping")),
                                 column(6, wellPanel(verbatimTextOutput(ns("argscheck")))))),

                 column(6,
                        tags$h3("Arguments mapping preview"),
                        wellPanel(class = "gp-well2",
                                  verbatimTextOutput(ns("argtext"))))))

    ))

    )
  )
}

#' func_code Server Functions
#'
#' @noRd
mod_func_code_server <- function(id, mask_data){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    func_expr <- reactive(eval_parse(text = input$funccode))
    func_code <- eventReactive(input$funcok, func_expr())
    func_check <- eventReactive(input$funcok, validate_func(func_expr()))

    output$funccheck <- renderPrint(func_check())
    output$functext <- renderPrint(func_code())

    args_expr <- reactive(eval_parse(text = input$argmap))
    args_code <- eventReactive(input$argsok, args_expr())
    args_check <- eventReactive(
      input$argsok,
      {
        validate_args(args_expr(),
                      mask_data = mask_data(), func = func_code())})

    output$argscheck <- renderPrint(args_check())
    output$argtext <- renderPrint(args_code())

    # from example to function section
    eg_expr <- reactive(parse(text = input$egcode))
    eg_to_func <- eventReactive(input$egok, from_example_to_function(eg_expr()))

    output$egfunctext <- renderPrint(eg_to_func())


    list("func_code_return" = func_code,
         "args_mapping_return" = args_code)

  })
}

## To be copied in the UI
# mod_func_code_ui("func_code_1")

## To be copied in the server
# mod_func_code_server("func_code_1")
