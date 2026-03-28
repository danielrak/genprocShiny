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
    fileInput(ns("maskfile"), "Mask file"),
    dataTableOutput(ns("maskdata"))

  )
}

#' mask Server Functions
#'
#' @noRd
mod_mask_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    mask_file <- reactive(input$maskfile)
    mask_data <- reactive(rio::import(mask_file()[["datapath"]]))
    output$maskdata <- renderDataTable(mask_data())

  })
}

## To be copied in the UI
# mod_mask_ui("mask_1")

## To be copied in the server
# mod_mask_server("mask_1")
