
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `{genprocShiny}`

<!-- badges: start -->

<!-- badges: end -->

## About

You are reading the documentation for version: 0.0.0.9000

This README was generated on:

``` r
Sys.time()
#> [1] "2026-03-30 19:51:33 CEST"
```

------------------------------------------------------------------------

## Overview

The project attempts to build a framework for turning single-case data
processing scripts into **scalable, repeatable batch workflows**.

It enables you to apply a function across many cases defined in a table,
while ensuring **traceability, robustness, and operational control**.

This is the Shiny implementation inherent to the project.

------------------------------------------------------------------------

## Installation

You can install the development version with:

``` r
devtools::install_github("danielrak/genprocShiny")
```

------------------------------------------------------------------------

## A demo vignette

``` r
vignette("genprocShiny", "genprocShiny")
```

------------------------------------------------------------------------

## Why?

In many real-world workflows, processing starts from a single case:

- one file  
- one dataset  
- one transformation

Scaling this often leads to:

- duplicated code  
- fragile loops  
- limited error handling  
- no visibility on execution

While tools like `purrr::pmap()` help iterate, they do not address
**operational concerns**.

**genproc goes beyond iteration by structuring execution.**

------------------------------------------------------------------------

## General features

- **Standardized execution**  
  Functions are adapted to a consistent interface.

- **Flexible parameter mapping**  
  Decouples function logic from input data structure.

- **Execution robustness**  
  Each run is isolated with controlled error handling.

- **Traceable outputs**  
  Structured logs for each execution (success, failure, inputs).

- **Background and parallel execution**  
  Runs independently from the interactive session.

------------------------------------------------------------------------

## Typical use cases

- Batch processing of files or datasets  
- Reproducible data preparation pipelines  
- Administrative or production workflows  
- Scaling a prototype script to industrial execution

------------------------------------------------------------------------

## Shiny interface

You can launch the application with:

``` r
genprocpoc::run_app()
```

The interface allows you to:

- upload an input table  
- define a processing function  
- map parameters  
- launch execution  
- inspect results

------------------------------------------------------------------------

## What’s next

Planned enhancements include:

- stronger input validation and safer code handling  
- improved monitoring and real-time feedback  
- incremental logging during execution  
- more polished user interface  
- configuration management for reproducibility  
- more scalable execution strategies

------------------------------------------------------------------------
