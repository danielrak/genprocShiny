test_that("eval_parse valids are consistent", {
  eval_parsed <- eval_parse(text = "function (x) x + 1")
  func <- function (x) x + 1

  expect_true(is.function (eval_parsed))
  expect_equal(names(formals(eval_parsed)), names(formals(func)))
  expect_equal(body(eval_parsed), body(func))
})

test_that("validate_mask_file is consistent", {

  file <- "./l1/file.R"
  expect_error(validate_mask_file(file))
})

test_that("validate_mask_data is consistent", {

  data1 <- data.frame("one" = 1:10, "two" = 11:20)
  data2 <- list("one" = 1:10, "two" = 11:20)
  expect_equal(validate_mask_data(data1), "Mask data is valid")
  expect_error(validate_mask_data(data2), "Mask data must be a data.frame")

})

test_that("validate_func is consitent", {

  object1 <- function (x) x + 1
  object2 <- data.frame("one" = 1:10)

  expect_equal(validate_func(object1), "Function code is valid")
  expect_error(validate_func(object2), "You must code a function and not something of other class")
})

test_that("validate_args is consistent", {

  mask <- data.frame("p1" = 1:3, "p2" = 4:6)
  func <- function (x, y) {x + y}

  object1 <- data.frame("one" = 1:10)
  expect_error(validate_args(object1, mask, func),
               "You must code a character vector and not something of other class")

  object2 <- c(as.character(1:3), as.character(4:6))
  expect_error(validate_args(object2, mask, func),
              "The character vector must be named \\(over the function arguments\\)")

  object3 <- c("x" = "param1", "y" = "p2")
  expect_error(validate_args(object3, mask, func),
               "These values doest not match mask names")

  object4 <- c("X" = "p1", "y" = "p2")
  expect_error(validate_args(object4, mask, func),
               "These names does not match function arguments")

  object5 <- c("x" = "p1", "y" = "p2")
  expect_equal(validate_args(object5, mask, func),
               "Args mapping code is valid")
})
