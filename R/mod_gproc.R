#' Execution module
#'
#' @param id Module identifier.
#' @param mask Mask module contract.
#' @param function_input Function module contract.
#' @param run_job,status_job,await_job Injectable execution operations.
#' @param poll_ms Job polling interval in milliseconds.
#' @return Named reactives `job`, `result`, `state`, `error`, and `stale`.
#' @noRd
mod_gproc_ui <- function(id) {
  ns <- NS(id)
  tagList(wellPanel(class = "gp-well1", fluidRow(
    tags$h2("3 - Execution"),
    column(4, checkboxInput(ns("parallel"), "Run cases in parallel", FALSE),
           numericInput(ns("workers"), "Workers", 2, min = 1, max = 32, step = 1)),
    column(4, checkboxInput(ns("nonblocking"), "Non-blocking execution", TRUE)),
    column(4, actionButton(ns("go"), "Run"), tags$h5("Execution status"),
           wellPanel(verbatimTextOutput(ns("goout"))))
  )))
}

mod_gproc_server <- function(id, mask, function_input,
                             run_job = run_genproc,
                             status_job = genproc::status,
                             await_job = genproc::await,
                             poll_ms = 750L) {
  moduleServer(id, function(input, output, session) {
    values <- reactiveValues(
      job = NULL, result = NULL, state = "idle", error = NULL,
      stale = FALSE, snapshot = NULL, materialised = FALSE
    )

    inputs_ready <- reactive(
      isTRUE(mask$valid()) && isTRUE(function_input$function_valid()) &&
        isTRUE(function_input$mapping_valid())
    )
    current_snapshot <- reactive(list(
      mask = mask$data(), fun = function_input$fun(),
      mapping = function_input$mapping()
    ))

    observe({
      ready <- inputs_ready()
      snapshot <- if (ready) current_snapshot() else NULL
      if (!is.null(values$result) && !identical(snapshot, values$snapshot)) {
        values$stale <- TRUE
        values$state <- "stale"
      } else if (values$state %in% c("idle", "ready") && ready) {
        values$state <- "ready"
      } else if (!ready && values$state == "ready") {
        values$state <- "idle"
      }
    })

    observeEvent(input$go, {
      if (identical(values$state, "running")) return(invisible(NULL))

      values$error <- NULL
      if (!inputs_ready()) {
        values$state <- "error"
        values$error <- "Validate the mask, function, and optional mapping before running."
        return(invisible(NULL))
      }

      values$result <- NULL
      values$job <- NULL
      values$stale <- FALSE
      values$materialised <- FALSE
      values$snapshot <- current_snapshot()
      values$state <- "running"
      tryCatch({
        started <- run_job(
          f = function_input$fun(), mask = mask$data(),
          mapping = function_input$mapping(),
          use_parallel = isTRUE(input$parallel), workers = input$workers %||% 1L,
          nonblocking = !identical(input$nonblocking, FALSE)
        )
        if (inherits(started, "genproc_result")) {
          values$result <- started
          values$materialised <- TRUE
          values$state <- "done"
        } else {
          values$job <- started
        }
      }, error = function(e) {
        values$state <- "error"
        values$error <- conditionMessage(e)
      })
    })

    observe({
      req(identical(values$state, "running"), !is.null(values$job))
      invalidateLater(poll_ms, session)
      tryCatch({
        status <- status_job(values$job)
        if (job_is_terminal(status) && !values$materialised) {
          values$materialised <- TRUE
          values$result <- await_job(values$job)
          values$state <- if (identical(current_snapshot(), values$snapshot)) "done" else "stale"
          values$stale <- values$state == "stale"
        }
      }, error = function(e) {
        values$state <- "error"
        values$error <- conditionMessage(e)
      })
    })

    output$goout <- renderText(values$error %||% values$state)
    list(
      job = reactive(values$job), result = reactive(values$result),
      state = reactive(values$state), error = reactive(values$error),
      stale = reactive(values$stale)
    )
  })
}
