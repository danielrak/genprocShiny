test_that("run status text distinguishes stale and failed runs", {
  expect_equal(format_run_status("done"), "done")
  expect_match(format_run_status("stale"), "^stale - inputs changed")
  expect_equal(format_run_status("error", "worker died"), "error - worker died")
})

test_that("materialised results are recognised", {
  expect_false(result_is_materialised(NULL))
  expect_false(result_is_materialised(structure(list(log = NULL), class = "genproc_result")))
  expect_true(result_is_materialised(demo_result()))
})

test_that("overview and summary expose counts of successful and failed cases", {
  result <- demo_result()
  overview <- format_result_overview(result)
  expect_match(overview, "Status   : done")
  expect_match(overview, "3 \\( 2 ok, 1 error \\)")
  summary_text <- format_result_summary(result)
  expect_match(summary_text, "Cases      : 3 \\(2 ok, 1 error\\)")
  expect_match(summary_text, "case failed")
})

test_that("failed cases and their traceback are retrievable", {
  result <- demo_result()
  errors <- result_errors(result)
  expect_equal(nrow(errors), 1L)
  expect_equal(errors$x, 2L)
  expect_false("traceback" %in% names(result_errors(result, include_traceback = FALSE)))

  failed_id <- errors$case_id[1]
  details <- case_traceback(result, failed_id)
  expect_equal(details$error_message, "case failed")
  expect_match(format_case_traceback(details), "Error: case failed")

  success_id <- setdiff(result$log$case_id, failed_id)[1]
  expect_null(case_traceback(result, success_id))
  expect_null(case_traceback(result, "missing"))
  expect_match(format_case_traceback(NULL), "Select a failed case")
})

test_that("reproducibility metadata is tabulated", {
  result <- demo_result()
  fields <- reproducibility_fields(result)
  expect_equal(fields$value[fields$field == "Execution mode"], "sequential")
  expect_equal(fields$value[fields$field == "Mask rows"], "3")
  expect_equal(fields$value[fields$field == "R version"], R.version.string)

  packages <- reproducibility_packages(result)
  expect_named(packages, c("package", "version"))
  expect_true("genproc" %in% packages$package)
})

test_that("execution mode describes parallel and non-blocking runs", {
  expect_equal(format_execution_mode(list()), "sequential")
  expect_equal(
    format_execution_mode(list(parallel = list(strategy = "multisession", workers = 2L))),
    "multisession (2 workers)"
  )
  expect_equal(
    format_execution_mode(list(parallel = NULL, nonblocking = list(strategy = "multisession"))),
    "non-blocking + sequential"
  )
})
