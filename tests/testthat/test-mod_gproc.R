execution_inputs <- function() {
  list(
    mask = list(data = shiny::reactive(data.frame(x = 1:2)), valid = shiny::reactive(TRUE)),
    function_input = list(
      function = shiny::reactive(function(x) x), mapping = shiny::reactive(NULL),
      function_valid = shiny::reactive(TRUE), mapping_valid = shiny::reactive(TRUE)
    )
  )
}

test_that("duplicate runs are ignored and a terminal job is awaited once", {
  inputs <- execution_inputs()
  starts <- 0L
  awaits <- 0L
  statuses <- c("running", "completed")
  status_calls <- 0L

  shiny::testServer(mod_gproc_server, args = list(
    mask = inputs$mask, function_input = inputs$function_input,
    run_job = function(...) { starts <<- starts + 1L; structure(list(), class = "fake_job") },
    status_job = function(job) {
      status_calls <<- status_calls + 1L
      statuses[min(status_calls, length(statuses))]
    },
    await_job = function(job) {
      awaits <<- awaits + 1L
      structure(list(log = data.frame(success = TRUE)), class = "genproc_result")
    }, poll_ms = 100L
  ), {
    session$setInputs(go = 1, parallel = FALSE, workers = 1, nonblocking = TRUE)
    expect_equal(state(), "running")
    session$setInputs(go = 2)
    expect_equal(starts, 1L)
    session$elapse(100)
    expect_equal(state(), "done")
    expect_s3_class(result(), "genproc_result")
    session$elapse(200)
    expect_equal(awaits, 1L)
  })
})

test_that("invalid mapping prevents execution", {
  inputs <- execution_inputs()
  inputs$function_input$mapping_valid <- shiny::reactive(FALSE)
  starts <- 0L
  shiny::testServer(mod_gproc_server, args = list(
    mask = inputs$mask, function_input = inputs$function_input,
    run_job = function(...) starts <<- starts + 1L
  ), {
    session$setInputs(go = 1)
    expect_equal(state(), "error")
    expect_equal(starts, 0L)
  })
})

test_that("changed inputs mark a completed result stale", {
  mask_value <- shiny::reactiveVal(data.frame(x = 1))
  inputs <- execution_inputs()
  inputs$mask$data <- shiny::reactive(mask_value())
  fake_result <- structure(list(log = data.frame(success = TRUE)), class = "genproc_result")

  shiny::testServer(mod_gproc_server, args = list(
    mask = inputs$mask, function_input = inputs$function_input,
    run_job = function(...) fake_result
  ), {
    session$setInputs(go = 1, parallel = FALSE, workers = 1, nonblocking = FALSE)
    expect_equal(state(), "done")
    mask_value(data.frame(x = 2))
    session$flushReact()
    expect_equal(state(), "stale")
    expect_true(stale())
  })
})

test_that("results module presents the in-memory result", {
  result <- shiny::reactive(structure(list(log = data.frame(case = 1, success = TRUE)), class = "genproc_result"))
  execution <- list(result = result, state = shiny::reactive("done"), error = shiny::reactive(NULL))
  shiny::testServer(mod_log_server, args = list(execution = execution), {
    expect_match(output$status, "done")
    expect_false("logs_path_return" %in% names(formals(mod_log_server)))
    expect_false("proc_label_return" %in% names(formals(mod_log_server)))
  })
})
