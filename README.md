
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `{gprocpoc}`

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## Installation

You can install the development version of `{gprocpoc}` like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

## Run

You can launch the application by running:

``` r
gprocpoc::run_app()
```

## About

You are reading the doc about version : 0.0.0.9000

This README has been compiled on the

``` r
Sys.time()
#> [1] "2026-03-28 02:46:26 CET"
```

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ℹ Loading gprocpoc
#> ── R CMD check results ──────────────────────────────── gprocpoc 0.0.0.9000 ────
#> Duration: 26.7s
#> 
#> ❯ checking tests ...
#>   See below...
#> 
#> ❯ checking package subdirectories ... NOTE
#>   Problems with news in 'NEWS.md':
#>   No news entries found.
#> 
#> ❯ checking dependencies in R code ... NOTE
#>   importations '::' ou ':::' non déclarées depuis : 'rio'
#> 
#> ── Test failures ───────────────────────────────────────────────── testthat ────
#> 
#> > # This file is part of the standard setup for testthat.
#> > # It is recommended that you do not modify it.
#> > #
#> > # Where should you do additional test configuration?
#> > # Learn more about the roles of various files in:
#> > # * https://r-pkgs.org/testing-design.html#sec-tests-files-overview
#> > # * https://testthat.r-lib.org/articles/special-files.html
#> > 
#> > library(testthat)
#> Warning message:
#> package 'testthat' was built under R version 4.5.2 
#> > library(gprocpoc)
#> > 
#> > test_check("gprocpoc")
#> `shiny::dataTableOutput()` is deprecated as of shiny 1.8.1.
#> Please use `DT::DTOutput()` instead.
#> See <https://rstudio.github.io/DT/shiny.html> for more information.
#> Loading required package: shiny
#> `shiny::renderDataTable()` is deprecated as of shiny 1.8.1.
#> Please use `DT::renderDT()` instead.
#> See <https://rstudio.github.io/DT/shiny.html> for more information.
#> Saving _problems/test-golem_utils_ui-99.R
#> Saving _problems/test-golem_utils_ui-105.R
#> `shiny::renderDataTable()` is deprecated as of shiny 1.8.1.
#> Please use `DT::renderDT()` instead.
#> See <https://rstudio.github.io/DT/shiny.html> for more information.
#> `shiny::dataTableOutput()` is deprecated as of shiny 1.8.1.
#> Please use `DT::DTOutput()` instead.
#> See <https://rstudio.github.io/DT/shiny.html> for more information.
#> [ FAIL 2 | WARN 1 | SKIP 1 | PASS 88 ]
#> 
#> ══ Skipped tests (1) ═══════════════════════════════════════════════════════════
#> • rlang_is_interactive() is not TRUE (1): 'test-golem-recommended.R:72:5'
#> 
#> ══ Warnings ════════════════════════════════════════════════════════════════════
#> ── Warning ('test-golem-recommended.R:55:1'): (code run outside of `test_that()`) ──
#> package 'shiny' was built under R version 4.5.3
#> Backtrace:
#>     ▆
#>  1. └─shiny::testServer(...) at test-golem-recommended.R:55:1
#>  2.   └─base::require(shiny)
#>  3.     ├─base::tryCatch(...)
#>  4.     │ └─base (local) tryCatchList(expr, classes, parentenv, handlers)
#>  5.     │   └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
#>  6.     │     └─base (local) doTryCatch(return(expr), name, parentenv, handler)
#>  7.     └─base::library(...)
#>  8.       └─base (local) testRversion(pkgInfo, package, pkgpath)
#> 
#> ══ Failed tests ════════════════════════════════════════════════════════════════
#> ── Failure ('test-golem_utils_ui.R:96:3'): Test undisplay works ────────────────
#> Expected `as.character(b)` to equal "<button id=\"go_filter\" type=\"button\" class=\"btn btn-default action-button\">go</button>".
#> Differences:
#> actual vs expected
#> - "<button id=\"go_filter\" type=\"button\" class=\"btn btn-default action-button\"><span class=\"action-label\">go</span></button>"
#> + "<button id=\"go_filter\" type=\"button\" class=\"btn btn-default action-button\">go</button>"
#> 
#> ── Failure ('test-golem_utils_ui.R:102:3'): Test undisplay works ───────────────
#> Expected `as.character(b_undisplay)` to equal "<button id=\"go_filter\" type=\"button\" class=\"btn btn-default action-button\" style=\"display: none;\">go</button>".
#> Differences:
#> actual vs expected
#> - "<button id=\"go_filter\" type=\"button\" class=\"btn btn-default action-button\" style=\"display: none;\"><span class=\"action-label\">go</span></button>"
#> + "<button id=\"go_filter\" type=\"button\" class=\"btn btn-default action-button\" style=\"display: none;\">go</button>"
#> 
#> 
#> [ FAIL 2 | WARN 1 | SKIP 1 | PASS 88 ]
#> Error:
#> ! Test failures.
#> Execution halted
#> 
#> 1 error ✖ | 0 warnings ✔ | 2 notes ✖
#> Error: R CMD check found ERRORs
```

``` r
covr::package_coverage()
#> Error: Failure in `C:/Users/rheri/AppData/Local/Temp/Rtmp8kFOPz/R_LIBS5b142f081693/gprocpoc/gprocpoc-tests/testthat.Rout.fail`
#> \"go_filter\" type=\"button\" class=\"btn btn-default action-button\" style=\"display: none;\"><span class=\"action-label\">go</span></button>"
#> + "<button id=\"go_filter\" type=\"button\" class=\"btn btn-default action-button\" style=\"display: none;\">go</button>"
#> 
#> 
#> [ FAIL 2 | WARN 1 | SKIP 1 | PASS 88 ]
#> Error:
#> ! Test failures.
#> Exécution arrêtée
```
