
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `{genprocShiny}`

<!-- badges: start -->

[![R-CMD-check](https://github.com/danielrak/genprocShiny/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/danielrak/genprocShiny/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## About

You are reading the documentation for version: 0.0.0.9000

This README was generated on:

``` r
Sys.time()
#> [1] "2026-04-06 22:04:31 CEST"
```

------------------------------------------------------------------------

## Overview

`genprocShiny` is a Shiny proof of concept for turning a **single
working data-processing task** into a **batch process over many explicit
input/output cases**.

The concrete idea is simple:

- you already know how to perform one transformation;
- you now need to run that transformation across many files, datasets,
  or parameterized cases;
- you want a structured way to define the cases, validate the function,
  run the process, and recover execution logs.

In this PoC, the process is driven by a **mask**: a table in which each
row defines one task to execute.

------------------------------------------------------------------------

## The concrete problem this project targets

A common practical situation is the following:

1.  you successfully transform one input into one output;
2.  you realize that the same operation must now be repeated dozens or
    hundreds of times;
3.  each case has explicit inputs and outputs;
4.  you need something more robust than copying code or writing an ad
    hoc loop.

For example:

- convert many files from one format to another;
- apply the same cleaning function to many datasets;
- generate many outputs whose paths are already listed in a control
  table;
- run a repeatable administrative or statistical transformation over
  many declared cases.

This is the concrete narrative of `genprocShiny`: **scale input/output
tasks from one validated transformation**.

------------------------------------------------------------------------

## What the current PoC already does

The current app is intentionally minimal, but it already covers the full
logic of a batch run:

- **upload a mask** that declares the cases to run;
- **build a function from example code** or write the function directly;
- **map function arguments to mask column names**;
- **launch execution**;
- **retrieve row-wise logs** describing success or failure.

This means the app is not just about iterating over rows. It is about
making a transformation **operational**:

- the cases are explicit;
- the interface between function and task table is explicit;
- execution is separated from result inspection;
- logging is part of the workflow.

------------------------------------------------------------------------

## Why this is not only a wrapper around `purrr`

Iteration tools are useful, but they do not by themselves define an
execution framework.

`genprocShiny` adds several layers around the actual iteration step:

- a **mask-first** way to declare tasks;
- a **function-to-mask interface** through argument mapping;
- a **from-example-to-function** step for users who can demonstrate one
  task but do not want to parameterize everything by hand;
- **row-wise success/error logging**;
- **background execution** and parallel processing support.

The goal is therefore not only to “map a function” but to help turn one
transformation into a **repeatable batch process with observable
execution**.

------------------------------------------------------------------------

## Installation

You can install the development version with:

``` r
devtools::install_github("danielrak/genprocShiny", build_vignettes = TRUE)
```

------------------------------------------------------------------------

## Main entry points

Launch the Shiny application with:

``` r
genprocShiny::run_app()
```

Create a demo framework oriented toward repeated file processing with:

``` r
genprocShiny::create_demo_framework("path/to/your/folder")
```

Browse available vignettes with:

``` r
browseVignettes("genprocShiny")
```

------------------------------------------------------------------------

## A more concrete example of use

Suppose you have one working transformation that turns one input file
into one output file.

You now want to run it on many cases.

A typical workflow is:

1.  prepare a mask with columns such as input path, input file, output
    path, and output file;
2.  define the transformation function;
3.  map the function arguments to the mask column names;
4.  run the process;
5.  inspect the resulting logs.

This is exactly the kind of use case the current PoC is designed to make
more explicit and more reusable.

------------------------------------------------------------------------

## From example to function

One important part of the current PoC is that the function can be
obtained in two ways:

- **directly**, by writing the function code yourself;
- **indirectly**, by starting from example code and transforming it into
  a function.

This matters for a practical reason: many users know how to perform one
transformation in R, but the step from “working example” to “reusable
function” is often the first barrier to scaling.

`genprocShiny` therefore includes a dedicated interface for building the
function from example code and then validating or editing the resulting
function before execution.

------------------------------------------------------------------------

## Shiny interface

The current interface is organized as four steps:

1.  **Mask**
2.  **Function**
3.  **Execution**
4.  **Results**

This reflects the intended workflow of the PoC:

- declare the tasks;
- validate the transformation;
- run the batch process;
- inspect the logs.

------------------------------------------------------------------------

## Current scope

This repository should be read as a **proof of concept**.

Its value is not yet to cover every industrial case, but to make the
core workflow tangible:

- a task table;
- a reusable function;
- an explicit interface between both;
- scalable execution;
- and structured logs.

That scope is narrower and more concrete than a general-purpose workflow
platform, and that is deliberate.

------------------------------------------------------------------------

## What comes next

Planned improvements include:

- stronger validation of user inputs and code;
- more informative logs, including richer execution metadata;
- better live monitoring during execution;
- easier editing and testing of functions and mappings;
- improved user experience in the Shiny interface;
- more robust support for broader classes of processing tasks.

In other words, the current PoC already demonstrates the main idea,
while the next iterations will make it safer, clearer, and more useful
in real batch-processing contexts.
