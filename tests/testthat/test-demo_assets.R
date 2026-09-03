test_that("the shipped demo function and mapping run through genproc as installed", {
  skip_if_not_installed("genproc", minimum_version = "0.2.0")
  asset <- app_sys("demo_assets", "func_and_args_mapping.R")
  expect_true(nzchar(asset))
  blocks <- parse(asset, keep.source = FALSE)
  expect_length(blocks, 3L)

  # Evaluate the way the app does: only the package namespace is visible,
  # nothing attached by the user.
  env <- new.env(parent = asNamespace("genprocShiny"))
  f <- eval(blocks[[2]], envir = env)
  mapping <- eval(blocks[[3]], envir = env)
  expect_equal(validate_func(f), "Function code is valid")

  demo <- withr::local_tempdir()
  saveRDS(head(datasets::iris), file.path(demo, "iris.rds"))
  mask <- data.frame(
    input_dir = demo, input_file = "iris.rds",
    output_dir = demo, output_file = "iris.csv",
    stringsAsFactors = FALSE
  )
  expect_equal(validate_args(mapping, mask, f), "Args mapping code is valid")

  result <- run_genproc(f, mask, mapping = mapping, nonblocking = FALSE)
  expect_true(all(result$log$success))
  expect_true(file.exists(file.path(demo, "iris.csv")))
})
