test_that("eval_parse valids are consistent", {
  eval_parsed <- eval_parse(text = "function (x) x + 1")
  func <- function (x) x + 1

  expect_true(is.function (eval_parsed))
  expect_equal(names(formals(eval_parsed)), names(formals(func)))
  expect_equal(body(eval_parsed), body(func))
})
