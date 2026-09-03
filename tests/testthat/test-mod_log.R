test_that("results module presents the in-memory result", {
  result <- demo_result()
  shiny::testServer(mod_log_server, args = list(execution = fake_execution(result)), {
    expect_equal(output$status, "done")
    expect_match(output$overview, "2 ok, 1 error")
    expect_match(output$summary, "case failed")
    expect_match(output$traceback, "Select a failed case")
    session$setInputs(errors_rows_selected = 1L)
    expect_match(output$traceback, "Error: case failed")
  })
})

test_that("results module only reads the execution contract", {
  expect_setequal(names(formals(mod_log_server)), c("id", "execution"))
})

test_that("a stale result is labelled and a running job shows no result", {
  result <- demo_result()
  shiny::testServer(mod_log_server, args = list(execution = fake_execution(result, "stale")), {
    expect_match(output$status, "^stale - inputs changed")
    expect_match(output$overview, "2 ok, 1 error")
  })
  shiny::testServer(mod_log_server, args = list(execution = fake_execution(NULL, "running")), {
    expect_equal(output$status, "running")
    expect_error(output$overview, class = "shiny.silent.error")
  })
})

test_that("a wrapper-level error is shown instead of a result", {
  execution <- fake_execution(NULL, "error", "worker died")
  shiny::testServer(mod_log_server, args = list(execution = execution), {
    expect_equal(output$status, "error - worker died")
    expect_error(output$overview, class = "shiny.silent.error")
  })
})
