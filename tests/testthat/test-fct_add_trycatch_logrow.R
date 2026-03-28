test_that("Valid outputs are consistent", {
  expect_equal(add_trycatch_logrow(function(x) {x + 1})(2),
               structure(
                 list(
                   x = 2,
                   success = TRUE,
                   error_message = NA_character_
                 ),
                 row.names = c(NA, -1L),
                 class = "data.frame"
               ))

  expect_equal(add_trycatch_logrow(function(x) {x + 1})("2"),
               structure(
                 list(
                   x = "2",
                   success = FALSE,
                   error_message = "non-numeric argument to binary operator"
                 ),
                 row.names = c(NA, -1L),
                 class = "data.frame"
               ))
})
