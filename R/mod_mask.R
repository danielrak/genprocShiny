#' mask UI Function
#'
#' @description Mask module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_mask_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(6,
             fileInput(ns("maskfile"), tags$h3("Mask file"))),
      column(6,
             tags$h3("Mask data"),
             wellPanel(style = "height: 150px; overflow-y: auto;",
                       dataTableOutput(ns("maskdata"))))
      )
  )
}

#' mask Server Functions
#'
#' @noRd
mod_mask_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    mask_file <- reactive(input$maskfile)
    mask_data <- reactive({
      req(mask_file())
      rio::import(mask_file()[["datapath"]])})
    output$maskdata <- renderDataTable({
      DT::datatable(mask_data(),
                    options = list(scrioolY = "300px"))})

    mask_data

  })
}

## To be copied in the UI
# mod_mask_ui("mask_1")

## To be copied in the server
# mod_mask_server("mask_1")
