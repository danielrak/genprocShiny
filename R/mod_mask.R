#' Mask module
#'
#' @param id Module identifier.
#' @return The server returns named reactives `data`, `valid`, and `error`.
#' @noRd
mod_mask_ui <- function(id) {
  ns <- NS(id)
  tagList(wellPanel(class = "gp-well1", fluidRow(
    tags$h2("1 - Mask"),
    column(4, fileInput(ns("maskfile"), tags$h3("Upload mask")),
           wellPanel(verbatimTextOutput(ns("validation")))),
    column(8, tags$h3("Mask preview"),
           wellPanel(class = "gp-well2", DT::DTOutput(ns("maskdata"))))
  )))
}

mod_mask_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    mask <- reactiveVal(NULL)
    error <- reactiveVal(NULL)

    observeEvent(input$maskfile, {
      mask(NULL)
      error(NULL)
      tryCatch({
        validate_mask_file(input$maskfile$datapath)
        value <- rio::import(input$maskfile$datapath)
        validate_mask_data(value)
        mask(value)
      }, error = function(e) error(conditionMessage(e)))
    })

    valid <- reactive(!is.null(mask()) && is.null(error()))
    output$validation <- renderText(if (valid()) "Mask data is valid" else error() %||% "No mask loaded")
    output$maskdata <- DT::renderDT({ req(valid()); mask() })

    list(data = reactive(mask()), valid = valid, error = reactive(error()))
  })
}
