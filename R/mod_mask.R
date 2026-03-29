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
    wellPanel(
      class = "gp-well1",
      fluidRow(

      column(4,
             fileInput(ns("maskfile"), tags$h3("Mask file")),
             wellPanel(verbatimTextOutput(ns("mskfilecheck")))),
      column(8,
             tags$h3("Mask data"),
             wellPanel(class = "gp-well2",
                       dataTableOutput(ns("maskdata"))),
             wellPanel(verbatimTextOutput(ns("mskdatacheck")))))
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
    output$mskfilecheck <- renderPrint({
      req(mask_file())
      validate_mask_file(mask_file())
    })

    mask_data <- reactive({
      req(mask_file())
      rio::import(mask_file()[["datapath"]])
      })
    output$mskdatacheck <- renderPrint({validate_mask_data(mask_data())})
    output$maskdata <- renderDataTable({
      mask_data()},
      options = list(scrioolY = "300px"))

    mask_data

  })
}

## To be copied in the UI
# mod_mask_ui("mask_1")

## To be copied in the server
# mod_mask_server("mask_1")
