test_that("from_function_to_mask is consistent", {
  expect_error(from_function_to_mask(function (x = list(1), y = 2) x + y),
               "In this PoC version, values in each func argument must be an atomic of length 1 or 0")
  expect_equal(from_function_to_mask(function (x = 1, y) x / y),
               structure(list(x = 1, y = ""),
                         class = "data.frame",
                         row.names = c(NA, -1L)))
})
