#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    golem_add_external_resources(),
    fluidPage(
      tags$div(
        class = "app-header",
        tags$div(
          class = "app-header-text",
          tags$h1("Generalized Processing Helper with R"),
          tags$h3("A minimal Shiny interface for genproc")
        ),
        tags$img(
          src = "www/favicon.png",
          class = "app-logo",
          alt = "genproc logo"
        )
      ),

      mod_mask_ui("mask_1"),
      mod_func_code_ui("func_1"),
      mod_gproc_ui("gproc_1"),
      mod_log_ui("log_1")
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "gprocpoc"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
