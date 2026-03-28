test_that("Valid outputs are consistent", {
  expect_equal(rename_function_params(function (x) {x + 1}, c("x" = "y")),
               function (y)
               {
                 y + 1
               })
})
