execution_inputs <- function() {
  list(
    mask = list(data = shiny::reactive(data.frame(x = 1:2)), valid = shiny::reactive(TRUE)),
    function_input = list(
      fun = shiny::reactive(function(x) x), mapping = shiny::reactive(NULL),
      function_valid = shiny::reactive(TRUE), mapping_valid = shiny::reactive(TRUE)
    )
  )
}

test_that("duplicate runs are ignored and a terminal job is awaited once", {
  inputs <- execution_inputs()
  starts <- 0L
  awaits <- 0L
  # Consulted once at launch, once by the first poll, then terminal
  statuses <- c("running", "running", "completed")
  status_calls <- 0L

  shiny::testServer(mod_gproc_server, args = list(
    mask = inputs$mask, function_input = inputs$function_input,
    run_job = function(...) {
      starts <<- starts + 1L
      # Mirrors genproc: a non-blocking job is a `genproc_result` skeleton
      structure(list(log = NULL, status = "running"), class = "genproc_result")
    },
    status_job = function(job) {
      status_calls <<- status_calls + 1L
      statuses[min(status_calls, length(statuses))]
    },
    await_job = function(job) {
      awaits <<- awaits + 1L
      structure(list(log = data.frame(success = TRUE), status = "done"), class = "genproc_result")
    }, poll_ms = 100L
  ), {
    session$setInputs(go = 1, parallel = FALSE, workers = 1, nonblocking = TRUE)
    expect_equal(session$returned$state(), "running")
    session$setInputs(go = 2)
    expect_equal(starts, 1L)
    session$elapse(100)
    expect_equal(session$returned$state(), "done")
    expect_s3_class(session$returned$result(), "genproc_result")
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
    expect_equal(session$returned$state(), "error")
    expect_equal(starts, 0L)
  })
})

test_that("changed inputs mark a completed result stale", {
  mask_value <- shiny::reactiveVal(data.frame(x = 1))
  inputs <- execution_inputs()
  inputs$mask$data <- shiny::reactive(mask_value())
  fake_result <- structure(list(log = data.frame(success = TRUE), status = "done"), class = "genproc_result")

  shiny::testServer(mod_gproc_server, args = list(
    mask = inputs$mask, function_input = inputs$function_input,
    run_job = function(...) fake_result
  ), {
    session$setInputs(go = 1, parallel = FALSE, workers = 1, nonblocking = FALSE)
    expect_equal(session$returned$state(), "done")
    mask_value(data.frame(x = 2))
    session$flushReact()
    expect_equal(session$returned$state(), "stale")
    expect_true(session$returned$stale())
  })
})

test_that("a job that dies is reported as a wrapper-level error", {
  inputs <- execution_inputs()
  shiny::testServer(mod_gproc_server, args = list(
    mask = inputs$mask, function_input = inputs$function_input,
    run_job = function(...) structure(list(log = NULL, status = "running"), class = "genproc_result"),
    status_job = function(job) "error",
    await_job = function(job) structure(
      list(log = NULL, status = "error", error_message = "worker died"),
      class = "genproc_result"
    ), poll_ms = 100L
  ), {
    session$setInputs(go = 1, parallel = FALSE, workers = 1, nonblocking = TRUE)
    session$elapse(100)
    expect_equal(session$returned$state(), "error")
    expect_equal(session$returned$error(), "worker died")
    expect_null(session$returned$result()$log)
  })
})

test_that("a blocking run is materialised immediately through the real genproc API", {
  skip_if_not_installed("genproc", minimum_version = "0.2.0")
  inputs <- execution_inputs()
  shiny::testServer(mod_gproc_server, args = list(
    mask = inputs$mask, function_input = inputs$function_input
  ), {
    session$setInputs(go = 1, parallel = FALSE, workers = 1, nonblocking = FALSE)
    expect_equal(session$returned$state(), "done")
    expect_equal(nrow(session$returned$result()$log), 2L)
  })
})

test_that("a non-blocking run is polled until done through the real genproc API", {
  skip_if_not_installed("genproc", minimum_version = "0.2.0")
  inputs <- execution_inputs()
  # One slow case so the job is still running when the launch checks its status
  inputs$function_input$fun <- shiny::reactive(function(x) { Sys.sleep(1.5); x })
  shiny::testServer(mod_gproc_server, args = list(
    mask = inputs$mask, function_input = inputs$function_input, poll_ms = 100L
  ), {
    session$setInputs(go = 1, parallel = FALSE, workers = 1, nonblocking = TRUE)
    expect_equal(session$returned$state(), "running")
    for (i in 1:100) {
      session$elapse(100)
      if (session$returned$state() != "running") break
      Sys.sleep(0.1)
    }
    expect_equal(session$returned$state(), "done")
    expect_equal(nrow(session$returned$result()$log), 2L)
  })
})
