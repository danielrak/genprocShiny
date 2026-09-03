test_that("execution inputs are validated before starting", {
  mask <- data.frame(x = 1:2)
  expect_true(validate_execution_inputs(function(x) x, mask, c(x = "x")))
  expect_error(
    validate_execution_inputs(function(x) x, mask, c(x = "missing")),
    "do not match mask names"
  )
})

test_that("execution configuration is bounded", {
  expect_error(
    run_genproc(function(x) x, data.frame(x = 1), workers = 0),
    "between 1 and 32"
  )
})

test_that("terminal genproc statuses are recognised", {
  expect_false(job_is_terminal("running"))
  expect_true(job_is_terminal("completed"))
  expect_true(job_is_terminal(list(status = "finished")))
})

test_that("real genproc processes successful and failing cases", {
  skip_if_not_installed("genproc", minimum_version = "0.2.0")
  result <- run_genproc(
    function(x) { if (x == 2) stop("case failed"); x * 2 },
    data.frame(x = 1:3), nonblocking = FALSE
  )

  expect_s3_class(result, "genproc_result")
  expect_equal(nrow(result$log), 3)
  expect_equal(nrow(genproc::errors(result)), 1)
})
