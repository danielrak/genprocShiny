#' Function and mapping module
#'
#' @param id Module identifier.
#' @param mask A mask module contract.
#' @return Named reactives `function`, `mapping`, `function_valid`,
#'   `mapping_valid`, and `error`.
#' @noRd
mod_func_code_ui <- function(id) {
  ns <- NS(id)
  tagList(wellPanel(class = "gp-well1", fluidRow(
    tags$h2("2 - Function"),
    tabsetPanel(
      tabPanel("Build function",
        column(6, textAreaInput(ns("egcode"), tags$h3("Write your example code"), width = "100%", height = "100px"),
          actionButton(ns("egok"), "Validate example"),
          textAreaInput(ns("funccode"), tags$h3("Write your function code"), width = "100%", height = "100px"),
          actionButton(ns("funcok"), "Validate function"), wellPanel(verbatimTextOutput(ns("funccheck")))),
        column(6, tags$h3("Function preview"), wellPanel(class = "gp-well2", verbatimTextOutput(ns("functext"))))),
      tabPanel("Arguments mapping",
        column(6, textAreaInput(ns("argmap"), tags$h3("Map function arguments to mask columns"), width = "100%", height = "100px"),
          actionButton(ns("argsok"), "Validate mapping"), wellPanel(verbatimTextOutput(ns("argscheck")))),
        column(6, tags$h3("Mapping preview"), wellPanel(class = "gp-well2", verbatimTextOutput(ns("argtext")))))
    )
  )))
}

mod_func_code_server <- function(id, mask) {
  moduleServer(id, function(input, output, session) {
    current_function <- reactiveVal(NULL)
    current_mapping <- reactiveVal(NULL)
    function_error <- reactiveVal(NULL)
    mapping_error <- reactiveVal(NULL)
    mapping_ok <- reactiveVal(TRUE)

    set_function <- function(value) {
      validate_func(value)
      current_function(value)
      current_mapping(NULL)
      mapping_error(NULL)
      mapping_ok(TRUE)
    }

    observeEvent(input$egok, {
      function_error(NULL)
      tryCatch({
        expression <- parse_single_expression(input$egcode)
        fun <- genproc::from_example_to_function(expression)
        set_function(fun)
        updateTextAreaInput(session, "funccode", value = paste(deparse(fun), collapse = "\n"))
      }, error = function(e) function_error(conditionMessage(e)))
    })

    observeEvent(input$funcok, {
      function_error(NULL)
      tryCatch(set_function(eval_parse(input$funccode)),
               error = function(e) function_error(conditionMessage(e)))
    })

    observeEvent(input$argsok, {
      current_mapping(NULL)
      mapping_error(NULL)
      mapping_ok(FALSE)
      tryCatch({
        req(mask$valid(), current_function())
        value <- eval_parse(input$argmap)
        validate_args(value, mask$data(), current_function())
        current_mapping(value)
        mapping_ok(TRUE)
      }, error = function(e) mapping_error(conditionMessage(e)))
    })

    function_valid <- reactive(!is.null(current_function()) && is.null(function_error()))
    mapping_valid <- reactive(mapping_ok() && is.null(mapping_error()))
    output$functext <- renderPrint({ req(function_valid()); current_function() })
    output$funccheck <- renderText(if (function_valid()) "Function code is valid" else function_error() %||% "No function validated")
    output$argtext <- renderPrint({ req(mapping_valid()); current_mapping() })
    output$argscheck <- renderText(if (mapping_valid()) "Arguments mapping is valid" else mapping_error() %||% "No mapping validated")

    list(
      function = reactive(current_function()), mapping = reactive(current_mapping()),
      function_valid = function_valid, mapping_valid = mapping_valid,
      error = reactive(function_error() %||% mapping_error())
    )
  })
}
