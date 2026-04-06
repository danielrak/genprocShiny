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
        tabPanel("Build function",
                 column(6,

                        # From example
                        textAreaInput(ns("egcode"), label = tags$h3("Write your example code"),
                                         width = "800px", height = "100px"),
                        fluidRow(column(4, actionButton(ns("egok"), label = "Validate example")),
                                 column(6, wellPanel(verbatimTextOutput(ns("egcheck"))))),

                        # Direct writing
                        textAreaInput(ns("funccode"), label = tags$h3("Write your function code"),
                                      width = "800px", height = "100px"),
                        fluidRow(column(4, actionButton(ns("funcok"), label = "Validate function")),
                                 column(6, wellPanel(verbatimTextOutput(ns("funccheck")))))),
                 # Preview function
                 column(6,
                        tags$h3("Function preview"),
                        wellPanel(class = "gp-well2",
                                  verbatimTextOutput(ns("functext"))))
                 ),

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
mod_func_code_server <- function(id, mask_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # the unique function
    current_func <- reactiveVal(NULL)
    current_check <- reactiveVal("No function validated yet.")

    # build function from example
    observeEvent(input$egok, {
      tryCatch({
        eg_expr <- parse(text = input$egcode)
        fun <- from_example_to_function(eg_expr)

        # write generated function into the function text area
        fun_txt <- paste(deparse(fun), collapse = "\n")
        updateTextAreaInput(session, "funccode", value = fun_txt)

        # store as current function
        current_func(fun)
        current_check(validate_func(fun))

      }, error = function(e) {
        current_check(paste("Error:", conditionMessage(e)))
      })
    })

    # validate function written directly in funccode
    observeEvent(input$funcok, {
      tryCatch({
        fun <- eval_parse(text = input$funccode)

        current_func(fun)
        current_check(validate_func(fun))

      }, error = function(e) {
        current_check(paste("Error:", conditionMessage(e)))
      })
    })

    # unique preview
    output$functext <- renderPrint({
      req(current_func())
      current_func()
    })

    # unique validation message
    output$funccheck <- renderPrint({
      current_check()
    })

    # arguments mapping
    args_expr <- reactive({
      eval_parse(text = input$argmap)
    })

    args_code <- eventReactive(input$argsok, {
      args_expr()
    })

    args_check <- eventReactive(input$argsok, {
      req(current_func())
      validate_args(
        args_expr(),
        mask_data = mask_data(),
        func = current_func()
      )
    })

    output$argscheck <- renderPrint(args_check())
    output$argtext <- renderPrint(args_code())

    list(
      "func_code_return" = current_func,
      "args_mapping_return" = args_code
    )
  })
}

## To be copied in the UI
# mod_func_code_ui("func_code_1")

## To be copied in the server
# mod_func_code_server("func_code_1")
